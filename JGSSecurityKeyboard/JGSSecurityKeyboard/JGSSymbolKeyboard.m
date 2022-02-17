//
//  JGSSymbolKeyboard.m
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSSymbolKeyboard.h"
#import "JGSBase.h"

@interface JGSSymbolKeyboard ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showHalfNumSyms;
@property (nonatomic, copy) NSArray<NSArray<JGSKeyboardKey *> *> *showHalfNumKeys;

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showHalfSymbols;
@property (nonatomic, copy) NSArray<NSArray<JGSKeyboardKey *> *> *showHalfSymKeys;

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showFullNumSyms;
@property (nonatomic, copy) NSArray<NSArray<JGSKeyboardKey *> *> *showFullNumKeys;

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showFullSymbols;
@property (nonatomic, copy) NSArray<NSArray<JGSKeyboardKey *> *> *showFullSymKeys;

@end

@implementation JGSSymbolKeyboard

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
    
    if (newSuperview != nil) {
        // 按钮
        if (self.showHalfNumKeys == nil) {
            self.showHalfNumKeys = [self addShowKeys:self.showHalfNumSyms containNum:YES halfAngle:YES hidden:NO];
        }
        if (self.showHalfSymKeys == nil) {
            self.showHalfSymKeys = [self addShowKeys:self.showHalfSymbols containNum:NO halfAngle:YES hidden:YES];
        }
        if (self.textField.jg_enableFullAngle && self.showFullNumKeys == nil) {
            self.showFullNumKeys = [self addShowKeys:self.showFullNumSyms containNum:YES halfAngle:NO hidden:YES];
        }
        if (self.textField.jg_enableFullAngle && self.showFullSymKeys == nil) {
            self.showFullSymKeys = [self addShowKeys:self.showFullSymbols containNum:NO halfAngle:NO hidden:YES];
        }
    }
}

- (NSArray<NSArray<NSString *> *> *)showHalfNumSyms {
    
    if (!_showHalfNumSyms) {
        _showHalfNumSyms = @[
                             @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"],
                             @[@"-", @"/", @":", @";", @"(", @")", @"$", @"&", @"@", @"“"],
                             @[@".", @",", @"?", @"!", @"’"],
                             ];
    }
    return _showHalfNumSyms;
}

- (NSArray<NSArray<NSString *> *> *)showHalfSymbols {
    
    if (!_showHalfSymbols) {
        _showHalfSymbols = @[
                             @[@"[", @"]", @"{", @"}", @"#", @"%", @"^", @"*", @"+", @"="],
                             @[@"_", @"\\", @"|", @"~", @"<", @">", @"€", @"£", @"¥", @"•"],
                             @[@".", @",", @"?", @"!", @"’"],
                             ];
    }
    return _showHalfSymbols;
}

- (NSArray<NSArray<NSString *> *> *)showFullNumSyms {
    
    if (!_showFullNumSyms) {
        _showFullNumSyms = @[
                             @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"],
                             @[@"-", @"/", @"：", @"；", @"（", @"）", @"¥", @"@", @"“", @"”"],
                             @[@"。", @"，", @"、", @"？", @"！", @"."],
                             ];
    }
    return _showFullNumSyms;
}

- (NSArray<NSArray<NSString *> *> *)showFullSymbols {
    
    if (!_showFullSymbols) {
        _showFullSymbols = @[
                             @[@"【", @"】", @"｛", @"｝", @"#", @"%", @"^", @"*", @"+", @"="],
                             @[@"_", @"—", @"\\", @"｜", @"～", @"《", @"》", @"$", @"&", @"·"],
                             @[@"…", @"，", @"^_^", @"？", @"！", @"’"],
                             ];
    }
    return _showFullSymbols;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview == nil) {
        return;
    }
    
    NSMutableArray<NSArray<NSArray<JGSKeyboardKey *> *> *> *showKeyboards = @[].mutableCopy;
    NSMutableArray<NSArray<NSArray<NSString *> *> *> *keyboardLetters = @[].mutableCopy;
    if (self.showHalfNumKeys.firstObject.firstObject.superview != nil) {
        [showKeyboards addObject:self.showHalfNumKeys];
        [keyboardLetters addObject:self.showHalfNumSyms];
    }
    if (self.showHalfSymKeys.firstObject.firstObject.superview != nil) {
        [showKeyboards addObject:self.showHalfSymKeys];
        [keyboardLetters addObject:self.showHalfSymbols];
    }
    if (self.showFullNumKeys.firstObject.firstObject.superview != nil) {
        [showKeyboards addObject:self.showFullNumKeys];
        [keyboardLetters addObject:self.showFullNumSyms];
    }
    if (self.showFullSymKeys.firstObject.firstObject.superview != nil) {
        [showKeyboards addObject:self.showFullSymKeys];
        [keyboardLetters addObject:self.showFullSymbols];
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
    
    for (NSArray<NSArray<JGSKeyboardKey *> *> *showKeys in showKeyboards) {
        
        NSArray<NSArray<NSString *> *> *showLetters = [keyboardLetters objectAtIndex:[showKeyboards indexOfObject:showKeys]];
        [showKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger lineIdx, BOOL * _Nonnull stop) {
            
            CGFloat itemsTotalW = (itemSpacing + itemWidth) * maxItemsCnt - itemSpacing;
            if (lineIdx < 3) {
                itemsTotalW = (itemSpacing + itemWidth) * showLetters[lineIdx].count - itemSpacing;
            }
            CGFloat beginX = (keyboardWidth - itemsTotalW) * 0.5f;
            CGFloat lineY = beginY + lineIdx * (itemHeight + lineSpacing);
            CGFloat scale = 1.f;
            if (lineIdx == 2) {
                
                // 第三行输入按键宽度调整
                CGFloat deleteWidth = floor(MIN(beginX - minX - itemSpacing, itemWidth * 1.5 + itemSpacing));
                beginX = minX + deleteWidth + itemSpacing;
                CGFloat keysW = keyboardWidth - beginX * 2; // = ((itemWidth + itemSpacing) * line.count - itemSpacing) * scale
                scale = keysW / ((itemWidth + itemSpacing) * showLetters[lineIdx].count - itemSpacing);
            }
            
            [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (lineIdx < 2) {
                    
                    CGFloat btnX = beginX + idx * (itemWidth + itemSpacing) * scale;
                    obj.frame = CGRectMake(btnX, lineY, itemWidth * scale, itemHeight);
                }
                else if (lineIdx == 2) {
                    
                    if (idx > 0 && idx < lineKeys.count - 1) {
                        
                        CGFloat btnX = beginX + (idx - 1) * (itemWidth + itemSpacing) * scale;
                        obj.frame = CGRectMake(btnX, lineY, itemWidth * scale, itemHeight);
                    }
                    else {
                        
                        CGFloat deleteWidth = round(beginX - itemSpacing - minX);
                        if (idx == 0) {
                            obj.frame = CGRectMake(minX, lineY, deleteWidth, itemHeight);
                        }
                        else if (idx == lineKeys.count - 1) {
                            obj.frame = CGRectMake(keyboardWidth - minX - deleteWidth, lineY, deleteWidth, itemHeight);
                        }
                    }
                }
                else if (lineIdx == 3) {
                    
                    // 不支持全角时，切换按钮宽度和字母键盘保持一致
                    CGFloat switchWidth = round(itemWidth * 2 + itemSpacing);
                    CGFloat returnWidth = switchWidth;
                    CGFloat spaceX = minX + switchWidth + itemSpacing;
                    if (lineKeys.count == 4) {
                        
                        switchWidth = floor((itemSpacing * 2 + itemWidth * 2.5) * 0.5);
                        returnWidth = switchWidth * 2 + itemSpacing;
                        spaceX = minX + (switchWidth + itemSpacing) * 2;
                    }
                    
                    switch (idx) {
                        case 0:
                            obj.frame = CGRectMake(minX, lineY, switchWidth, itemHeight);
                            break;

                        case 1: {
                            
                            if (lineKeys.count == 4) {
                                obj.frame = CGRectMake(minX + switchWidth + itemSpacing, lineY, switchWidth, itemHeight);
                            }
                            else {
                                CGFloat spaceW = keyboardWidth - spaceX * 2;
                                obj.frame = CGRectMake(spaceX, lineY, spaceW, itemHeight);
                            }
                        }
                            break;

                        case 2: {
                            
                            if (lineKeys.count == 4) {
                                CGFloat spaceW = keyboardWidth - spaceX * 2;
                                obj.frame = CGRectMake(spaceX, lineY, spaceW, itemHeight);
                            }
                            else {
                                obj.frame = CGRectMake(keyboardWidth - minX - returnWidth, lineY, returnWidth, itemHeight);
                            }
                        }
                            break;

                        case 3:
                            obj.frame = CGRectMake(keyboardWidth - minX - returnWidth, lineY, returnWidth, itemHeight);
                            break;

                        default:
                            break;
                    }
                }
            }];
        }];
    }
}

- (NSArray<NSArray<JGSKeyboardKey *> *> *)addShowKeys:(NSArray<NSArray<NSString *> *> *)keyTitles containNum:(BOOL)containNum halfAngle:(BOOL)isHalf hidden:(BOOL)hidden  {
    
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
        CGFloat scale = 1.f;
        if (lineIdx == 2) {
            
            // 第三行输入按键宽度调整
            CGFloat deleteWidth = floor(MIN(beginX - minX - itemSpacing, itemWidth * 1.5 + itemSpacing));
            beginX = minX + deleteWidth + itemSpacing;
            CGFloat keysW = keyboardWidth - beginX * 2; // = ((itemWidth + itemSpacing) * line.count - itemSpacing) * scale
            scale = keysW / ((itemWidth + itemSpacing) * line.count - itemSpacing);
        }
        
        NSMutableArray<JGSKeyboardKey *> *lineKeys = @[].mutableCopy;
        [line enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat btnX = beginX + idx * (itemWidth + itemSpacing) * scale;
            CGRect btnFrame = CGRectMake(btnX, lineY, itemWidth * scale, itemHeight);
            
            JGSKeyboardKey *itemBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:obj frame:btnFrame];
            [lineKeys addObject:itemBtn];
        }];
        
        if (lineIdx < 2) {
            [tmpKeys addObject:lineKeys];
            return;
        }
    
        // 第三行功能按键
        // 与键盘按键第三行按钮宽度计算保持一致，第三行计算修改了beginX值，此处只需直接处理间隔
        CGFloat deleteWidth = floor(beginX - itemSpacing - minX);
        
        // switch
        JGSKeyboardKeyType numberSymbolType = containNum ? JGSKeyboardKeyTypeSymbolSwitch2Symbols : JGSKeyboardKeyTypeSymbolSwitch2Numbers;
        NSString *numberSymbolTitle = numberSymbolType == JGSKeyboardKeyTypeSymbolSwitch2Symbols ? JGSKeyboardTitleSymbols : JGSKeyboardTitleNumbers;
        JGSKeyboardKey *numberSymbol = [[JGSKeyboardKey alloc] initWithType:numberSymbolType text:numberSymbolTitle frame:CGRectMake(minX, lineY, deleteWidth, itemHeight)];
        [lineKeys insertObject:numberSymbol atIndex:0];
        
        // delete
        JGSKeyboardKey *deleteBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeDelete text:nil frame:CGRectMake(keyboardWidth - minX - deleteWidth, lineY, deleteWidth, itemHeight)];
        [lineKeys addObject:deleteBtn];
        
        // 下一行继续使用 lineKeys，此处需要copy
        [tmpKeys addObject:lineKeys.copy];
        [lineKeys removeAllObjects];
        
        lineY += (itemHeight + lineSpacing);
        CGFloat switchWidth = floor((itemSpacing * 2 + itemWidth * 2.5) * 0.5);
        CGFloat returnWidth = switchWidth * 2 + itemSpacing;
        CGFloat spaceX = minX + (switchWidth + itemSpacing) * 2;
        
        if (self.textField.jg_enableFullAngle) {
            
            // switch
            JGSKeyboardKey *switchBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeSwitch2Letter text:JGSKeyboardTitleLetters frame:CGRectMake(minX, lineY, switchWidth, itemHeight)];
            [lineKeys addObject:switchBtn];
            
            // angle
            CGFloat angleX = minX + switchWidth + itemSpacing;
            JGSKeyboardKeyType angleType = isHalf ? JGSKeyboardKeyTypeSymbolSwitch2Full : JGSKeyboardKeyTypeSymbolSwitch2Half;
            JGSKeyboardKey *angleSwitch = [[JGSKeyboardKey alloc] initWithType:angleType text:nil frame:CGRectMake(angleX, lineY, switchWidth, itemHeight)];
            [lineKeys addObject:angleSwitch];
        }
        else {
            
            // 不支持全角时，切换按钮宽度和字母键盘保持一致
            switchWidth = round(itemWidth * 2 + itemSpacing);
            returnWidth = switchWidth;
            spaceX = minX + switchWidth + itemSpacing;

            // switch
            JGSKeyboardKey *switchBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeSwitch2Letter text:JGSKeyboardTitleLetters frame:CGRectMake(minX, lineY, switchWidth, itemHeight)];
            [lineKeys addObject:switchBtn];
        }
        
        // space
        CGFloat spaceW = keyboardWidth - spaceX * 2;
        JGSKeyboardKey *spaceBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:@" " frame:CGRectMake(spaceX, lineY, spaceW, itemHeight)];
        [lineKeys addObject:spaceBtn];
        
        // enter
        JGSKeyboardKey *enterBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeEnter text:self.returnKeyTitle frame:CGRectMake(spaceX + spaceW + itemSpacing, lineY, returnWidth, itemHeight)];
        [lineKeys addObject:enterBtn];
        
        [tmpKeys addObject:lineKeys];
    }];
    
    JGSWeakSelf
    [tmpKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger keyIdx, BOOL * _Nonnull stop) {
        
        JGSStrongSelf
        JGSWeakSelf
        [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            JGSStrongSelf
            obj.hidden = hidden;
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

#pragma mark - Action
- (BOOL)keyboardKeyAction:(JGSKeyboardKey *)key event:(JGSKeyboardKeyEvents)event {
    
    if (![super keyboardKeyAction:key event:event]) {
        return NO;
    }
    
    // 回调通过调用super在父类中处理
    // 此处处理不同键盘的内部切换展示逻辑
    switch (key.type) {
        case JGSKeyboardKeyTypeSymbolSwitch2Symbols: {
            
            if (!self.showHalfNumKeys.firstObject.firstObject.isHidden) {
                [self switchShowKeys:self.showHalfSymKeys hideKeys:self.showHalfNumKeys];
            }
            else {
                [self switchShowKeys:self.showFullSymKeys hideKeys:self.showFullNumKeys];
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Numbers: {
            
            if (!self.showHalfSymKeys.firstObject.firstObject.isHidden) {
                [self switchShowKeys:self.showHalfNumKeys hideKeys:self.showHalfSymKeys];
            }
            else {
                [self switchShowKeys:self.showFullNumKeys hideKeys:self.showFullSymKeys];
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Half: {
            
            if (!self.showFullNumKeys.firstObject.firstObject.isHidden) {
                [self switchShowKeys:self.showHalfNumKeys hideKeys:self.showFullNumKeys];
            }
            else {
                [self switchShowKeys:self.showHalfSymKeys hideKeys:self.showFullSymKeys];
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Full: {
            
            if (!self.showHalfNumKeys.firstObject.firstObject.isHidden) {
                [self switchShowKeys:self.showFullNumKeys hideKeys:self.showHalfNumKeys];
            }
            else {
                [self switchShowKeys:self.showFullSymKeys hideKeys:self.showHalfSymKeys];
            }
        }
            break;
            
        default:
            break;
    }
    return YES;
}

- (void)switchShowKeys:(NSArray<NSArray<JGSKeyboardKey *> *> *)showKeys hideKeys:(NSArray<NSArray<JGSKeyboardKey *> *> *)hideKeys {
    
    [hideKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger keyIdx, BOOL * _Nonnull stop) {
        [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
        }];
    }];
    
    [showKeys enumerateObjectsUsingBlock:^(NSArray<JGSKeyboardKey *> * _Nonnull lineKeys, NSUInteger keyIdx, BOOL * _Nonnull stop) {
        [lineKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = NO;
        }];
    }];
}

#pragma mark - End

@end
