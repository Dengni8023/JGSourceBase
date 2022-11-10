//
//  JGSNumberKeyboard.m
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSNumberKeyboard.h"
#import "JGSBase+JGSPrivate.h"

@interface JGSNumberKeyboard ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showNumbers;
@property (nonatomic, copy) NSArray<NSArray<JGSKeyboardKey *> *> *showKeys;

@end

@implementation JGSNumberKeyboard

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type securityKeyboard:(JGSSecurityKeyboard *)securityKeyboard keyInput:(void (^)(JGSBaseKeyboard * _Nonnull, JGSKeyboardKey * _Nonnull, JGSKeyboardKeyEvents))keyInput {
    
    self = [super initWithFrame:frame type:type securityKeyboard:securityKeyboard keyInput:keyInput];
    if (self) {
        
    }
    return self;
}

#pragma mark - View
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview != nil && self.showKeys == nil) {
        // 按钮
        self.showKeys = [self addShowKeys:self.showNumbers];
    }
}

- (NSArray<NSArray<NSString *> *> *)showNumbers {
    
    if (!_showNumbers) {
        
        NSArray<NSString *> *numbers = [JGSKeyboardKeysForType(self.type, NO, NO) subarrayWithRange:NSMakeRange(0, 10)];
        if (self.securityKeyboard.randomNumPad) {
            numbers = [numbers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                if (arc4random_uniform(2) == 1) {
                    return [obj1 compare:obj2 options:kNilOptions];
                }
                else {
                    return [obj2 compare:obj1 options:kNilOptions];
                }
            }];
        }
        _showNumbers = @[
                         [numbers subarrayWithRange:NSMakeRange(0, 3)],
                         [numbers subarrayWithRange:NSMakeRange(3, 3)],
                         [numbers subarrayWithRange:NSMakeRange(6, 3)],
                         [numbers subarrayWithRange:NSMakeRange(9, 1)],
                         ];
    }
    return _showNumbers;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview == nil) {
        return;
    }
    
    CGFloat keyboardWidth = CGRectGetWidth(self.frame);
    CGFloat keyboardHeight = CGRectGetHeight(self.frame);
    NSInteger linesCnt = JGSKeyboardLinesNumber;
    NSInteger itemsCnt = JGSKeyboardNumberItemsInLine;
    CGFloat lineSpacing = JGSKeyboardKeyLineSpacing();
    CGFloat itemSpacing = JGSKeyboardKeyInterSpacing() * 1.6;
    
    // 水平方向：边距 = 间隔
    CGFloat itemWidth = floor((keyboardWidth - itemSpacing) / itemsCnt - itemSpacing);
    // 垂直方向：边距 = 间隔
    CGFloat itemHeight = floor((keyboardHeight - lineSpacing) / linesCnt - lineSpacing);
    
    CGFloat itemsTotalH = (lineSpacing + itemHeight) * linesCnt - lineSpacing;
    CGFloat beginY = (keyboardHeight - itemsTotalH) * 0.5;
    
    // 数字键盘每行布局按键、大小一致，无需特殊处理
    [self.showKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger lineIdx, BOOL * _Nonnull stop) {
        
        CGFloat itemsTotalW = (itemWidth + itemSpacing) * lineKeys.count - itemSpacing;
        CGFloat beginX = (keyboardWidth - itemsTotalW) * 0.5f;
        CGFloat lineY = beginY + lineIdx * (itemHeight + lineSpacing);
        
        [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat btnX = beginX + idx * (itemWidth + itemSpacing);
            obj.frame = CGRectMake(btnX, lineY, itemWidth, itemHeight);
        }];
    }];
}

- (NSArray<NSArray<JGSKeyboardKey *> *> *)addShowKeys:(NSArray<NSArray<NSString *> *> *)keyTitles {
    
    if (keyTitles.count == 0) {
        return nil;
    }
    
    CGFloat keyboardWidth = CGRectGetWidth(self.frame);
    CGFloat keyboardHeight = CGRectGetHeight(self.frame);
    NSInteger linesCnt = JGSKeyboardLinesNumber;
    NSInteger itemsCnt = JGSKeyboardNumberItemsInLine;
    CGFloat lineSpacing = JGSKeyboardKeyLineSpacing();
    CGFloat itemSpacing = JGSKeyboardKeyInterSpacing() * 1.6;
    
    // 水平方向：边距 = 间隔
    CGFloat itemWidth = floor((keyboardWidth - itemSpacing) / itemsCnt - itemSpacing);
    // 垂直方向：边距 = 间隔
    CGFloat itemHeight = floor((keyboardHeight - lineSpacing) / linesCnt - lineSpacing);
    
    CGFloat itemsTotalH = (lineSpacing + itemHeight) * linesCnt - lineSpacing;
    CGFloat beginY = (keyboardHeight - itemsTotalH) * 0.5;
    CGFloat itemsMaxW = (itemWidth + itemSpacing) * itemsCnt - itemSpacing;
    CGFloat minX = (keyboardWidth - itemsMaxW) * 0.5f;
    
    JGSWeakSelf
    NSMutableArray<NSArray<JGSKeyboardKey *> *> *tmpKeys = @[].mutableCopy;
    [keyTitles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull line, NSUInteger lineIdx, BOOL * _Nonnull lineStop) {
        
        JGSStrongSelf
        CGFloat itemsTotalW = (itemWidth + itemSpacing) * line.count - itemSpacing;
        CGFloat beginX = (keyboardWidth - itemsTotalW) * 0.5f;
        CGFloat lineY = beginY + lineIdx * (itemHeight + lineSpacing);
        
        NSMutableArray<JGSKeyboardKey *> *lineKeys = @[].mutableCopy;
        [line enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat btnX = beginX + idx * (itemWidth + itemSpacing);
            CGRect btnFrame = CGRectMake(btnX, lineY, itemWidth, itemHeight);
            
            JGSKeyboardKey *itemBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:obj frame:btnFrame];
            [lineKeys addObject:itemBtn];
        }];
        
        if (lineIdx < 3) {
            [tmpKeys addObject:lineKeys];
            return;
        }
        
        // 小数点/身份证X
        NSString *keyText = JGSKeyboardKeysForType(self.type, NO, NO).lastObject;
        JGSKeyboardKey *symbolBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:keyText frame:CGRectMake(minX, lineY, itemWidth, itemHeight)];
        [lineKeys insertObject:symbolBtn atIndex:0]; // 该行第一个位置
        
        // delete
        JGSKeyboardKey *deleteBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeDelete text:nil frame:CGRectMake(keyboardWidth - minX - itemWidth, lineY, itemWidth, itemHeight)];
        [lineKeys addObject:deleteBtn];
        
        [tmpKeys addObject:lineKeys];
    }];
    
    [tmpKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger lineIdx, BOOL * _Nonnull stop) {
        
        JGSStrongSelf
        JGSWeakSelf
        [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            JGSStrongSelf
            [self addSubview:obj];
            
            JGSWeakSelf
            obj.action = ^(JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents event) {
                JGSStrongSelf
                [self keyboardKeyAction:key event:event];
            };
        }];
    }];
    return tmpKeys;
}

#pragma mark - End

@end
