//
//  JGSLetterKeyboard.m
//
//
//  Created by 梅继高 on 2019/5/31.
//

#import "JGSLetterKeyboard.h"
#import "JGSBase.h"

@interface JGSLetterKeyboard ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showLetters;
@property (nonatomic, copy) NSArray<JGSKeyboardKey *> *showKeys;
@property (nonatomic, strong) JGSKeyboardKey *shiftKey;

@end

@implementation JGSLetterKeyboard

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type returnKeyType:(JGSKeyboardReturnType)returnKeyType keyInput:(void (^)(JGSBaseKeyboard * _Nonnull, JGSKeyboardKey * _Nonnull, JGSKeyboardKeyEvents))keyInput {
    
    self = [super initWithFrame:frame type:type returnKeyType:returnKeyType keyInput:keyInput];
    if (self) {
        
        // 按钮
        self.showKeys = [self addShowKeys:self.showLetters];
    }
    return self;
}

- (void)enableHighlightedWhenTap:(BOOL)enable {
    [super enableHighlightedWhenTap:enable];
    
    [self.showKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enableHighlighted = enable;
    }];
}

#pragma mark - View
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

- (NSArray<JGSKeyboardKey *> *)addShowKeys:(NSArray<NSArray<NSString *> *> *)keyTitles {
    
    if (keyTitles.count == 0) {
        return nil;
    }
    
    CGFloat keyboardWidth = CGRectGetWidth(self.frame);
    CGFloat keyboardHeight = CGRectGetHeight(self.frame);
    CGFloat itemWidth = floor((keyboardWidth - JGSKeyboardInteritemSpacing * JGSKeyboardMaxItemsInLine) / JGSKeyboardMaxItemsInLine);
    CGFloat itemHeight = floor(itemWidth / JGSKeyboardKeyWidthHeightRatio());
    CGFloat itemsTotalH = (JGSKeyboardKeyLineSpacing + itemHeight) * JGSKeyboardLinesNumber - JGSKeyboardKeyLineSpacing;
    CGFloat beginY = (keyboardHeight - itemsTotalH) * 0.5;
    CGFloat itemsMaxW = (JGSKeyboardInteritemSpacing + itemWidth) * JGSKeyboardMaxItemsInLine - JGSKeyboardInteritemSpacing;
    CGFloat minX = (keyboardWidth - itemsMaxW) * 0.5f;
    
    NSMutableArray<JGSKeyboardKey *> *tmpKeys = @[].mutableCopy;
    [keyTitles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull line, NSUInteger lineIdx, BOOL * _Nonnull lineStop) {
        
        CGFloat itemsTotalW = (JGSKeyboardInteritemSpacing + itemWidth) * line.count - JGSKeyboardInteritemSpacing;
        CGFloat beginX = (keyboardWidth - itemsTotalW) * 0.5f;
        CGFloat lineY = beginY + lineIdx * (itemHeight + JGSKeyboardKeyLineSpacing);
        
        [line enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat btnX = beginX + idx * (itemWidth + JGSKeyboardInteritemSpacing);
            CGRect btnFrame = CGRectMake(btnX, lineY, itemWidth, itemHeight);
            
            JGSKeyboardKey *itemBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:obj frame:btnFrame];
            [tmpKeys addObject:itemBtn];
        }];
        
        if (lineIdx == 2) {
            
            CGFloat funcItemWidth = floor(beginX - minX - JGSKeyboardInteritemSpacing);
            
            // shift
            JGSKeyboardKey *shitBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeShift text:nil frame:CGRectMake(minX, lineY, funcItemWidth, itemHeight)];
            [tmpKeys addObject:shitBtn];
            
            // delete
            JGSKeyboardKey *deleteBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeDelete text:nil frame:CGRectMake(keyboardWidth - minX - funcItemWidth, lineY, funcItemWidth, itemHeight)];
            [tmpKeys addObject:deleteBtn];
            
            lineY += (itemHeight + JGSKeyboardKeyLineSpacing);
            funcItemWidth += (JGSKeyboardInteritemSpacing + itemWidth) * 0.5;
            
            // switch
            JGSKeyboardKey *switchBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeSwitch2Symbol text:JGSKeyboardTitleSymbolWithNumber frame:CGRectMake(minX, lineY, funcItemWidth, itemHeight)];
            [tmpKeys addObject:switchBtn];
            
            // space
            CGFloat spaceX = minX + funcItemWidth + JGSKeyboardInteritemSpacing;
            CGFloat spaceW = keyboardWidth - spaceX * 2;
            JGSKeyboardKey *spaceBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:@" " frame:CGRectMake(spaceX, lineY, spaceW, itemHeight)];
            [tmpKeys addObject:spaceBtn];
            
            // enter
            JGSKeyboardKey *enterBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeEnter text:self.returnKeyTitle frame:CGRectMake(keyboardWidth - minX - funcItemWidth, lineY, funcItemWidth, itemHeight)];
            [tmpKeys addObject:enterBtn];
        }
    }];
    
    JGSWeakSelf
    [tmpKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
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
    return tmpKeys;
}

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
            [self.showKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *curText = obj.text;
                if (curText.length == 1 &&
                    [curText compare:@"a" options:NSCaseInsensitiveSearch] != NSOrderedAscending &&
                    [curText compare:@"z" options:NSCaseInsensitiveSearch] != NSOrderedDescending) {
                    BOOL showUpper = forceUpper || [curText isEqualToString:curText.lowercaseString];
                    obj.text = showUpper ? curText.uppercaseString : curText.lowercaseString;
                }
            }];
        }
            break;
        
        default: {
            
            // 非长按Shifts时，输入一次，清理Shift状态，切换小写键盘
            if (self.shiftKey.shiftStatus == JGSKeyboardShiftKeySelected) {
                
                self.shiftKey.shiftStatus = JGSKeyboardShiftKeyDefault;
                [self.showKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSString *curText = obj.text;
                    if (curText.length == 1 &&
                        [curText compare:@"a" options:NSCaseInsensitiveSearch] != NSOrderedAscending &&
                        [curText compare:@"z" options:NSCaseInsensitiveSearch] != NSOrderedDescending) {
                        
                        obj.text = curText.lowercaseString;
                    }
                }];
            }
        }
            break;
    }
    return YES;
}

@end
