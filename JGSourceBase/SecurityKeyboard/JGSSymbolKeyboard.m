//
//  JGSSymbolKeyboard.m
//
//
//  Created by 梅继高 on 2019/5/31.
//

#import "JGSSymbolKeyboard.h"
#import "JGSBase.h"

BOOL JGSKeyboardSymbolFullAngle = NO;
FOUNDATION_EXTERN void JGSKeyboardSymbolFullAngleEnable(BOOL enable) {
    JGSKeyboardSymbolFullAngle = enable;
}

@interface JGSSymbolKeyboard ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showHalfNumSyms;
@property (nonatomic, copy) NSArray<JGSKeyboardKey *> *showHalfNumKeys;

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showHalfSymbols;
@property (nonatomic, copy) NSArray<JGSKeyboardKey *> *showHalfSymKeys;

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showFullNumSyms;
@property (nonatomic, copy) NSArray<JGSKeyboardKey *> *showFullNumKeys;

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showFullSymbols;
@property (nonatomic, copy) NSArray<JGSKeyboardKey *> *showFullSymKeys;

@end

@implementation JGSSymbolKeyboard

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type returnKeyType:(JGSKeyboardReturnType)returnKeyType keyInput:(void (^)(JGSBaseKeyboard * _Nonnull, JGSKeyboardKey * _Nonnull, JGSKeyboardKeyEvents))keyInput {
    
    self = [super initWithFrame:frame type:type returnKeyType:returnKeyType keyInput:keyInput];
    if (self) {
        
        // 按钮
        self.showHalfNumKeys = [self addShowKeys:self.showHalfNumSyms containNum:YES halfAngle:YES hidden:NO];
        self.showHalfSymKeys = [self addShowKeys:self.showHalfSymbols containNum:NO halfAngle:YES hidden:YES];
        self.showFullNumKeys = [self addShowKeys:self.showFullNumSyms containNum:YES halfAngle:NO hidden:YES];
        self.showFullSymKeys = [self addShowKeys:self.showFullSymbols containNum:NO halfAngle:NO hidden:YES];
    }
    return self;
}

- (void)enableHighlightedWhenTap:(BOOL)enable {
    [super enableHighlightedWhenTap:enable];
    
    [self.showHalfNumKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enableHighlighted = enable;
    }];
    
    [self.showHalfSymKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enableHighlighted = enable;
    }];
    
    [self.showFullNumKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enableHighlighted = enable;
    }];
    
    [self.showFullSymKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enableHighlighted = enable;
    }];
}

#pragma mark - View
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

- (NSArray<JGSKeyboardKey *> *)addShowKeys:(NSArray<NSArray<NSString *> *> *)keyTitles containNum:(BOOL)containNum halfAngle:(BOOL)isHalf hidden:(BOOL)hidden  {
    
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
            if (lineIdx == 2) {
                
                // 与键盘按键第三行功能键看度计算保持一致
                CGFloat funcItemWidth = floor(MIN(beginX - minX - JGSKeyboardInteritemSpacing, (itemWidth + JGSKeyboardInteritemSpacing) * 1.5));
                CGFloat btnBeginX = minX + funcItemWidth + JGSKeyboardInteritemSpacing;
                CGFloat scale = (keyboardWidth - btnBeginX * 2) / line.count / (itemWidth + JGSKeyboardInteritemSpacing);
                btnBeginX = minX + funcItemWidth + JGSKeyboardInteritemSpacing * scale;
                CGFloat btnWidth = (keyboardWidth - btnBeginX * 2 + JGSKeyboardInteritemSpacing * scale) / line.count - JGSKeyboardInteritemSpacing * scale;
                btnX = btnBeginX + idx * (btnWidth + JGSKeyboardInteritemSpacing * scale);
                btnFrame = CGRectMake(btnX, lineY, btnWidth, itemHeight);
            }
            
            JGSKeyboardKey *itemBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:obj frame:btnFrame];
            [tmpKeys addObject:itemBtn];
        }];
        
        if (lineIdx == 2) {
            
            // 与键盘按键第三行按钮宽度计算保持一致
            CGFloat funcItemWidth = floor(MIN(beginX - minX - JGSKeyboardInteritemSpacing, (itemWidth + JGSKeyboardInteritemSpacing) * 1.5));
            
            // switch
            JGSKeyboardKeyType numberSymbolType = containNum ? JGSKeyboardKeyTypeSymbolSwitch2Symbols : JGSKeyboardKeyTypeSymbolSwitch2Numbers;
            NSString *numberSymbolTitle = numberSymbolType == JGSKeyboardKeyTypeSymbolSwitch2Symbols ? JGSKeyboardTitleSymbols : JGSKeyboardTitleNumbers;
            JGSKeyboardKey *numberSymbol = [[JGSKeyboardKey alloc] initWithType:numberSymbolType text:numberSymbolTitle frame:CGRectMake(minX, lineY, funcItemWidth, itemHeight)];
            [tmpKeys addObject:numberSymbol];
            
            // delete
            JGSKeyboardKey *deleteBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeDelete text:nil frame:CGRectMake(keyboardWidth - minX - funcItemWidth, lineY, funcItemWidth, itemHeight)];
            [tmpKeys addObject:deleteBtn];
            
            lineY += (itemHeight + JGSKeyboardKeyLineSpacing);
            CGFloat switchWidth = MIN(floor((JGSKeyboardInteritemSpacing + itemWidth) * 1.5), itemHeight);
            funcItemWidth = switchWidth * 2 + JGSKeyboardInteritemSpacing;
            CGFloat spaceX = minX + (switchWidth + JGSKeyboardInteritemSpacing) * 2;
            
            if (JGSKeyboardSymbolFullAngle) {
                // switch
                JGSKeyboardKey *switchBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeSwitch2Letter text:JGSKeyboardTitleLetters frame:CGRectMake(minX, lineY, switchWidth, itemHeight)];
                [tmpKeys addObject:switchBtn];
                
                // angle
                CGFloat angleX = minX + switchWidth + JGSKeyboardInteritemSpacing;
                JGSKeyboardKeyType angleType = isHalf ? JGSKeyboardKeyTypeSymbolSwitch2Full : JGSKeyboardKeyTypeSymbolSwitch2Half;
                JGSKeyboardKey *angleSwitch = [[JGSKeyboardKey alloc] initWithType:angleType text:nil frame:CGRectMake(angleX, lineY, switchWidth, itemHeight)];
                [tmpKeys addObject:angleSwitch];
            }
            else {

                switchWidth = switchWidth * 2;
                funcItemWidth = switchWidth;
                spaceX = minX + switchWidth + JGSKeyboardInteritemSpacing;

                // switch
                JGSKeyboardKey *switchBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeSwitch2Letter text:JGSKeyboardTitleLetters frame:CGRectMake(minX, lineY, switchWidth, itemHeight)];
                [tmpKeys addObject:switchBtn];
            }
            
            // space
            CGFloat spaceW = keyboardWidth - minX - spaceX - funcItemWidth - JGSKeyboardInteritemSpacing;
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
        obj.hidden = hidden;
        [self addSubview:obj];
        
        JGSWeakSelf
        obj.action = ^(JGSKeyboardKey * _Nonnull key, JGSKeyboardKeyEvents event) {
            JGSStrongSelf
            [self keyboardKeyAction:key event:event];
        };
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
        case JGSKeyboardKeyTypeSymbolSwitch2Symbols: {
            
            if (!self.showHalfNumKeys.firstObject.isHidden) {
                [self switchShowKeys:self.showHalfSymKeys hideKeys:self.showHalfNumKeys];
            }
            else {
                [self switchShowKeys:self.showFullSymKeys hideKeys:self.showFullNumKeys];
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Numbers: {
            
            if (!self.showHalfSymKeys.firstObject.isHidden) {
                [self switchShowKeys:self.showHalfNumKeys hideKeys:self.showHalfSymKeys];
            }
            else {
                [self switchShowKeys:self.showFullNumKeys hideKeys:self.showFullSymKeys];
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Half: {
            
            if (!self.showFullNumKeys.firstObject.isHidden) {
                [self switchShowKeys:self.showHalfNumKeys hideKeys:self.showFullNumKeys];
            }
            else {
                [self switchShowKeys:self.showHalfSymKeys hideKeys:self.showFullSymKeys];
            }
        }
            break;
            
        case JGSKeyboardKeyTypeSymbolSwitch2Full: {
            
            if (!self.showHalfNumKeys.firstObject.isHidden) {
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

- (void)switchShowKeys:(NSArray<JGSKeyboardKey *> *)showKeys hideKeys:(NSArray<JGSKeyboardKey *> *)hideKeys {
    
    [hideKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    [showKeys enumerateObjectsUsingBlock:^(JGSKeyboardKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = NO;
    }];
}

@end
