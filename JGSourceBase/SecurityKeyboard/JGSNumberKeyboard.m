//
//  JGSNumberKeyboard.m
//  
//
//  Created by 梅继高 on 2019/5/31.
//

#import "JGSNumberKeyboard.h"

BOOL JGSKeyboardNumberPadRandom = YES;
FOUNDATION_EXTERN void JGSKeyboardNumberPadRandomEnable(BOOL enable) {
    JGSLog(@"数字键盘随机：%@", @(enable));
    JGSKeyboardNumberPadRandom = enable;
}

@interface JGSNumberKeyboard ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *showNumbers;
@property (nonatomic, copy) NSArray<JGSKeyboardKey *> *showKeys;

@end

@implementation JGSNumberKeyboard

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame type:(JGSKeyboardType)type returnKeyType:(JGSKeyboardReturnType)returnKeyType keyInput:(void (^)(JGSBaseKeyboard * _Nonnull, JGSKeyboardKey * _Nonnull, JGSKeyboardKeyEvents))keyInput {
    
    self = [super initWithFrame:frame type:type returnKeyType:returnKeyType keyInput:keyInput];
    if (self) {
        
        // 按钮
        self.showKeys = [self addShowKeys:self.showNumbers];
    }
    return self;
}

#pragma mark - View
- (NSArray<NSArray<NSString *> *> *)showNumbers {
    
    if (!_showNumbers) {
        
        NSArray<NSString *> *numbers = [@"1,2,3,4,5,6,7,8,9,0" componentsSeparatedByString:@","];
        if (JGSKeyboardNumberPadRandom) {
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

- (NSArray<JGSKeyboardKey *> *)addShowKeys:(NSArray<NSArray<NSString *> *> *)keyTitles {
    
    if (keyTitles.count == 0) {
        return nil;
    }
    
    CGFloat keyboardWidth = CGRectGetWidth(self.frame);
    CGFloat keyboardHeight = CGRectGetHeight(self.frame);
    CGFloat itemHeight = floor((keyboardHeight - JGSKeyboardKeyLineSpacing) / JGSKeyboardLinesNumber - JGSKeyboardKeyLineSpacing);
    CGFloat itemWidth = floor(itemHeight / JGSKeyboardKeyWidthHeightRatio);
    CGFloat numberItemW = itemWidth;// floor((keyboardWidth - JGSKeyboardInteritemSpacing * (JGSKeyboardNumberItemsInLine + 1)) / JGSKeyboardNumberItemsInLine);
    CGFloat numberSpacingX = floor(JGSKeyboardInteritemSpacing);
    while (ceil((numberItemW + numberSpacingX) * JGSKeyboardNumberItemsInLine + numberSpacingX) < keyboardWidth) {
        numberItemW *= 1.2;
        numberSpacingX *= 1.2;
    }
    numberItemW = floor(numberItemW);
    numberSpacingX = floor(numberSpacingX / 1.2);
    
    CGFloat itemsTotalH = (JGSKeyboardKeyLineSpacing + itemHeight) * JGSKeyboardLinesNumber - JGSKeyboardKeyLineSpacing;
    CGFloat beginY = (keyboardHeight - itemsTotalH) * 0.5;
    CGFloat numberMaxW = (numberSpacingX + numberItemW) * JGSKeyboardNumberItemsInLine - numberSpacingX;
    CGFloat minX = (keyboardWidth - numberMaxW) * 0.5f;
    
    NSMutableArray<JGSKeyboardKey *> *tmpKeys = @[].mutableCopy;
    [self.showNumbers enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull line, NSUInteger lineIdx, BOOL * _Nonnull lineStop) {
        
        CGFloat itemsTotalW = (numberSpacingX + numberItemW) * line.count - numberSpacingX;
        CGFloat beginX = (keyboardWidth - itemsTotalW) * 0.5f;
        CGFloat lineY = beginY + lineIdx * (itemHeight + JGSKeyboardKeyLineSpacing);
        
        [line enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat btnX = beginX + idx * (numberItemW + numberSpacingX);
            CGRect btnFrame = CGRectMake(btnX, lineY, numberItemW, itemHeight);
            
            JGSKeyboardKey *itemBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeInput text:obj frame:btnFrame];
            [tmpKeys addObject:itemBtn];
        }];
        
        if (lineIdx == 3) {
            
            // switch
            JGSKeyboardKey *symbolBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeSwitch2Letter text:JGSKeyboardTitleSymbols frame:CGRectMake(minX, lineY, numberItemW, itemHeight)];
            [tmpKeys addObject:symbolBtn];
            
            // delete
            JGSKeyboardKey *deleteBtn = [[JGSKeyboardKey alloc] initWithType:JGSKeyboardKeyTypeDelete text:nil frame:CGRectMake(keyboardWidth - minX - numberItemW, lineY, numberItemW, itemHeight)];
            [tmpKeys addObject:deleteBtn];
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
    }];
    return tmpKeys;
}

@end
