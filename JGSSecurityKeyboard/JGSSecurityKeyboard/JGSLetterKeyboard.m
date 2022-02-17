//
//  JGSLetterKeyboard.m
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSLetterKeyboard.h"
#import "JGSBase.h"

@interface JGSLetterKeyboard ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showLetters;
@property (nonatomic, copy) NSArray<NSArray<JGSKeyboardKey *> *> *showKeys;
@property (nonatomic, strong) JGSKeyboardKey *shiftKey;

@end

@implementation JGSLetterKeyboard

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type textField:(UITextField *)textField keyInput:(void (^)(JGSBaseKeyboard * _Nonnull, JGSKeyboardKey * _Nonnull, JGSKeyboardKeyEvents))keyInput {
    
    self = [super initWithFrame:frame type:type textField:textField keyInput:keyInput];
    if (self) {
        
    }
    return self;
}

#pragma mark - View
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview != nil && self.showKeys == nil) {
        // 按钮
        self.showKeys = [self addShowKeys:self.showLetters];
    }
}

- (NSArray<NSArray<NSString *> *> *)showLetters {
    
    if (!_showLetters) {
        _showLetters = @[
            @[@"q", @"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p"],
            @[@"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l"],
            @[@"z", @"x", @"c", @"v", @"b", @"n", @"m"],
        ];
    }
    return _showLetters;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview == nil) {
        return;
    }
    
    CGFloat keyboardWidth = CGRectGetWidth(self.frame);
    CGFloat keyboardHeight = CGRectGetHeight(self.frame);
    NSInteger linesCnt = JGSKeyboardLinesNumber;
    NSInteger maxItemsCnt = JGSKeyboardMaxItemsInLine;
    CGFloat lineSpacing = JGSKeyboardKeyLineSpacing();
    CGFloat itemSpacing = JGSKeyboardKeyInterSpacing();
    
    // 水平方向：边距 = 间隔 * 0.5
    CGFloat itemWidth = floor(keyboardWidth / maxItemsCnt - itemSpacing);
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        // 边距 = 间隔
        itemWidth = floor((keyboardWidth - itemSpacing) / maxItemsCnt - itemSpacing);
    }
    // 垂直方向：边距 = 间隔
    CGFloat itemHeight = floor((keyboardHeight - lineSpacing) / linesCnt - lineSpacing);
    
    CGFloat itemsTotalH = (lineSpacing + itemHeight) * linesCnt - lineSpacing;
    CGFloat beginY = (keyboardHeight - itemsTotalH) * 0.5;
    CGFloat itemsMaxW = (itemSpacing + itemWidth) * maxItemsCnt - itemSpacing;
    CGFloat minX = (keyboardWidth - itemsMaxW) * 0.5f;
    
    [self.showKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger lineIdx, BOOL * _Nonnull stop) {
        
        CGFloat itemsTotalW = (itemSpacing + itemWidth) * maxItemsCnt - itemSpacing;
        if (lineIdx < 3) {
            itemsTotalW = (itemSpacing + itemWidth) * self.showLetters[lineIdx].count - itemSpacing;
        }
        CGFloat beginX = (keyboardWidth - itemsTotalW) * 0.5f;
        CGFloat lineY = beginY + lineIdx * (itemHeight + lineSpacing);
        
        [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (lineIdx < 2) {
                
                CGFloat btnX = beginX + idx * (itemWidth + itemSpacing);
                obj.frame = CGRectMake(btnX, lineY, itemWidth, itemHeight);
            }
            else if (lineIdx == 2) {
                
                if (idx > 0 && idx < lineKeys.count - 1) {
                    
                    CGFloat btnX = beginX + (idx - 1) * (itemWidth + itemSpacing);
                    obj.frame = CGRectMake(btnX, lineY, itemWidth, itemHeight);
                }
                else {
                    
                    CGFloat shiftWidth = round(beginX - itemSpacing - minX);
                    if (idx == 0) {
                        obj.frame = CGRectMake(minX, lineY, shiftWidth, itemHeight);
                    }
                    else if (idx == lineKeys.count - 1) {
                        obj.frame = CGRectMake(keyboardWidth - minX - shiftWidth, lineY, shiftWidth, itemHeight);
                    }
                }
            }
            else if (lineIdx == 3) {
                
                CGFloat switchWidth = round(itemWidth * 2 + itemSpacing);
                switch (idx) {
                    case 0:
                        obj.frame = CGRectMake(minX, lineY, switchWidth, itemHeight);
                        break;
                        
                    case 1: {
                        CGFloat spaceX = minX + switchWidth + itemSpacing;
                        CGFloat spaceWidth = round(keyboardWidth - spaceX * 2);
                        obj.frame = CGRectMake(spaceX, lineY, spaceWidth, itemHeight);
                    }
                        break;
                        
                    case 2:
                        obj.frame = CGRectMake(keyboardWidth - minX - switchWidth, lineY, switchWidth, itemHeight);
                        break;
                        
                    default:
                        break;
                }
            }
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
    NSInteger maxItemsCnt = JGSKeyboardMaxItemsInLine;
    CGFloat lineSpacing = JGSKeyboardKeyLineSpacing();
    CGFloat itemSpacing = JGSKeyboardKeyInterSpacing();
    
    // 水平方向：边距 = 间隔 * 0.5
    CGFloat itemWidth = floor(keyboardWidth / maxItemsCnt - itemSpacing);
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        // 边距 = 间隔
        itemWidth = floor((keyboardWidth - itemSpacing) / maxItemsCnt - itemSpacing);
    }
    // 垂直方向：边距 = 间隔
    CGFloat itemHeight = floor((keyboardHeight - lineSpacing) / linesCnt - lineSpacing);
    
    CGFloat itemsTotalH = (lineSpacing + itemHeight) * linesCnt - lineSpacing;
    CGFloat beginY = (keyboardHeight - itemsTotalH) * 0.5;
    CGFloat itemsMaxW = (itemSpacing + itemWidth) * maxItemsCnt - itemSpacing;
    CGFloat minX = (keyboardWidth - itemsMaxW) * 0.5f;
    
    NSMutableArray<NSArray<JGSKeyboardKey *> *> *tmpKeys = @[].mutableCopy;
    [keyTitles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull line, NSUInteger lineIdx, BOOL * _Nonnull lineStop) {
        
        CGFloat itemsTotalW = (itemSpacing + itemWidth) * line.count - itemSpacing;
        CGFloat beginX = (keyboardWidth - itemsTotalW) * 0.5f;
        CGFloat lineY = beginY + lineIdx * (itemHeight + lineSpacing);
        
        NSMutableArray<JGSKeyboardKey *> *lineKeys = @[].mutableCopy;
        [line enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat btnX = beginX + idx * (itemWidth + itemSpacing);
            CGRect btnFrame = CGRectMake(btnX, lineY, itemWidth, itemHeight);
            
            JGSKeyboardKey *itemBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:obj frame:btnFrame];
            [lineKeys addObject:itemBtn];
        }];
        
        if (lineIdx < 2) {
            [tmpKeys addObject:lineKeys];
            return;
        }
        
        // 第三行功能按键
        CGFloat shiftWidth = floor(beginX - minX - itemSpacing);
        
        // shift
        JGSKeyboardKey *shitBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeShift text:nil frame:CGRectMake(minX, lineY, shiftWidth, itemHeight)];
        [lineKeys insertObject:shitBtn atIndex:0]; // 该行第一个位置
        
        // delete
        JGSKeyboardKey *deleteBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeDelete text:nil frame:CGRectMake(keyboardWidth - minX - shiftWidth, lineY, shiftWidth, itemHeight)];
        [lineKeys addObject:deleteBtn];
        
        // 下一行继续使用 lineKeys，此处需要copy
        [tmpKeys addObject:lineKeys.copy];
        [lineKeys removeAllObjects];
        
        // 第四行功能按键
        lineY += (itemHeight + lineSpacing);
        CGFloat switchWidth = shiftWidth + (itemSpacing + itemWidth) * 0.5;
        
        // switch
        JGSKeyboardKey *switchBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeSwitch2Symbol text:JGSKeyboardTitleSymbolWithNumber frame:CGRectMake(minX, lineY, switchWidth, itemHeight)];
        [lineKeys addObject:switchBtn];
        
        // space
        CGFloat spaceX = minX + switchWidth + itemSpacing;
        CGFloat spaceW = keyboardWidth - spaceX * 2;
        JGSKeyboardKey *spaceBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:@" " frame:CGRectMake(spaceX, lineY, spaceW, itemHeight)];
        [lineKeys addObject:spaceBtn];
        
        // enter
        JGSKeyboardKey *enterBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeEnter text:self.returnKeyTitle frame:CGRectMake(keyboardWidth - minX - switchWidth, lineY, switchWidth, itemHeight)];
        [lineKeys addObject:enterBtn];
        
        [tmpKeys addObject:lineKeys];
    }];
    
    JGSWeakSelf
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
            if (obj.type == JGSKeyboardKeyTypeShift) {
                self.shiftKey = obj;
            }
        }];
    }];
    return tmpKeys;
}

#pragma mark - Action
- (BOOL)keyboardKeyAction:(JGSKeyboardKey *)key event:(JGSKeyboardKeyEvents)event {
    
    if (![super keyboardKeyAction:key event:event]) {
        return NO;
    }
    
    // 回调通过调用super在父类中处理
    // 此处处理不同键盘的内部切换展示逻辑
    switch (key.type) {
        case JGSKeyboardKeyTypeShift: {
            
            // 键盘大小写切换
            BOOL forceUpper = event == JGSKeyboardKeyEventDoubleTap;
            [self.showKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger lineIdx, BOOL * _Nonnull stop) {
                
                [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSString *curText = obj.text;
                    if (curText.length == 1 &&
                        [curText compare:@"a" options:NSCaseInsensitiveSearch] != NSOrderedAscending &&
                        [curText compare:@"z" options:NSCaseInsensitiveSearch] != NSOrderedDescending) {
                        BOOL showUpper = forceUpper || [curText isEqualToString:curText.lowercaseString];
                        obj.text = showUpper ? curText.uppercaseString : curText.lowercaseString;
                    }
                }];
            }];
        }
            break;
            
        default: {
            
            // 非长按Shifts时，输入一次，清理Shift状态，切换小写键盘
            if (self.shiftKey.shiftStatus == JGSKeyboardShiftKeySelected) {
                
                self.shiftKey.shiftStatus = JGSKeyboardShiftKeyDefault;
                [self.showKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger lineIdx, BOOL * _Nonnull stop) {
                    
                    [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        NSString *curText = obj.text;
                        if (curText.length == 1 &&
                            [curText compare:@"a" options:NSCaseInsensitiveSearch] != NSOrderedAscending &&
                            [curText compare:@"z" options:NSCaseInsensitiveSearch] != NSOrderedDescending) {
                            
                            obj.text = curText.lowercaseString;
                        }
                    }];
                }];
            }
        }
            break;
    }
    return YES;
}

#pragma mark - End

@end
