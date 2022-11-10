//
//  JGSKeyboardConstants.m
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSKeyboardConstants.h"
#import "JGSCategory+UIColor.h"

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarColor(void) {
    return JGSColorRGB(253, 253, 253); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarTitleColor(void) {
    return [UIColor lightGrayColor];
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemTitleColor(void) {
    return JGSColorRGB(66, 66, 66); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardToolBarItemSelectedTitleColor(void) {
    return JGSColorRGB(68, 121, 251); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardBackgroundColor(void) {
    return JGSColorRGB(209, 213, 217); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyInputColor(void) {
    return JGSColorRGB(255, 255, 255); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyFuncColor(void) {
    return JGSColorRGB(173, 178, 188); // 系统键盘截图取色
}

FOUNDATION_EXTERN UIColor * const JGSKeyboardKeyTitleColor(void) {
    return JGSColorRGB(0, 0, 0);// 系统键盘截图取色
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarTitleFont(void) {
    return [UIFont systemFontOfSize:16];
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardToolBarItemTitleFont(void) {
    return [UIFont boldSystemFontOfSize:16];
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyInputTitleFont(void) {
    return [UIFont systemFontOfSize:20];
}

FOUNDATION_EXTERN UIFont * const JGSKeyboardKeyFuncTitleFont(void) {
    return [UIFont systemFontOfSize:16];
}

CGFloat const JGSKeyboardHighlightedColorAlpha = 0.6;
CGFloat const JGSKeyboardToolbarHeight = 40.f;
NSInteger const JGSKeyboardLinesNumber = 4;
NSInteger const JGSKeyboardMaxItemsInLine = 10;
NSInteger const JGSKeyboardNumberItemsInLine = 3;

NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *JGSKeyboardInterItemSpacing(void) {
    
    static NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *spacingInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spacingInfo = @{
            @"iPad": @{
                    @"Portrait": @(12.f),
                    @"Landscape": @(16.f),
            },
            @"iPhone": @{
                    @"Portrait": @(4.f),
                    @"Landscape": @(8.f),
            }
        };
    });
    
    return spacingInfo;
};

NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *JGSKeyboardLineSpacing(void) {
    
    static NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *spacingInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spacingInfo = @{
            @"iPad": @{
                    @"Portrait": @(9.f),
                    @"Landscape": @(12.f),
            },
            @"iPhone": @{
                    @"Portrait": @(8.f),
                    @"Landscape": @(6.f),
            }
        };
    });
    
    return spacingInfo;
}

NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *JGSKeyboardKeyWHRatio(void) {
    
    static NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *whRatioInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whRatioInfo = @{
            @"iPad": @{
                    @"Portrait": @(60.f / 55.f),
                    @"Landscape": @(85.f / 75.f),
            },
            @"iPhone": @{
                    @"Portrait": @(3.f / 4.f),
                    @"Landscape": @(32.f / 15.f),
            }
        };
    });
    
    return whRatioInfo;
}

CGFloat const JGSKeyboardKeyInterSpacing() {
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
    NSString *device = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    
    NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *spacingInfo = JGSKeyboardInterItemSpacing();
    NSNumber *spacing = spacingInfo[device][orientation];
    
    return [spacing floatValue];
};

CGFloat const JGSKeyboardKeyLineSpacing() {
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
    NSString *device = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    
    NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *spacingInfo = JGSKeyboardLineSpacing();
    NSNumber *spacing = spacingInfo[device][orientation];
    
    return [spacing floatValue];
}

CGFloat const JGSKeyboardKeyWidthHeightRatio() {
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
    NSString *device = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    
    NSDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *whRatioInfo = JGSKeyboardKeyWHRatio();
    NSNumber *ratio = whRatioInfo[device][orientation];
    
    return [ratio floatValue];
}

NSDictionary *JGSKeyboardSizeInfo() {
    
    static NSMutableDictionary<NSString *, NSString *> *sizeInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
            safeAreaInsets = window.safeAreaInsets;
        }
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        NSString *device = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
        NSDictionary *itemSpacingInfo = JGSKeyboardInterItemSpacing();
        NSDictionary *lineSpacingInfo = JGSKeyboardLineSpacing();
        NSDictionary *whRatioInfo = JGSKeyboardKeyWHRatio();
        
        CGFloat protraitWidth = MIN(screenSize.width, screenSize.height); // 竖屏左右不做处理
        CGFloat landscapeWidth = MAX(screenSize.width, screenSize.height); // 竖屏左右安全区处理
        if (UIInterfaceOrientationIsPortrait(statusBarOrientation)) {
            landscapeWidth -= (safeAreaInsets.top + safeAreaInsets.bottom);
        }
        else {
            landscapeWidth -= (safeAreaInsets.left + safeAreaInsets.right);
        }
        NSDictionary<NSString *, NSNumber *> *keyboardWidthInfo = @{
            @"Portrait": @(protraitWidth),
            @"Landscape": @(landscapeWidth)
        };
        
        sizeInfo = @{}.mutableCopy;
        [keyboardWidthInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *orientation = key;
            CGFloat itemSpacing = [itemSpacingInfo[device][orientation] floatValue];
            CGFloat lineSpacing = [lineSpacingInfo[device][orientation] floatValue];
            CGFloat whRatio = [whRatioInfo[device][orientation] floatValue];
            
            CGFloat keyboardWidth = obj.floatValue;
            CGFloat itemWidth = floor((keyboardWidth - itemSpacing * JGSKeyboardMaxItemsInLine) / JGSKeyboardMaxItemsInLine);
            CGFloat itemHeight = floor(itemWidth / whRatio);
            CGFloat keyboardHeight = lineSpacing + (itemHeight + lineSpacing) * JGSKeyboardLinesNumber;
            //if ([orientation isEqualToString:@"Portrait"]) {
            //    if (UIInterfaceOrientationIsPortrait(statusBarOrientation)) {
            //        keyboardHeight += safeAreaInsets.bottom * 0.5;
            //    }
            //}
            
            CGSize size = CGSizeMake(keyboardWidth, ceil(keyboardHeight));
            sizeInfo[orientation] = NSStringFromCGSize(size);
        }];
    });
    
    return sizeInfo;
}

NSString * const JGSKeyboardTitleLetters = @"Abc";
NSString * const JGSKeyboardTitleSymbolWithNumber = @".?123";
NSString * const JGSKeyboardTitleSymbols = @"#+=";
NSString * const JGSKeyboardTitleNumbers = @"123";
NSString * const JGSKeyboardTitleIDCard = @"身份证";
FOUNDATION_EXTERN NSString * const JGSKeyboardTitleForType(JGSKeyboardType type) {
    
    //JGSKeyboardTypeLetter = 0, // 英文字母键盘
    //JGSKeyboardTypeSymbol, // 符号键盘
    //JGSKeyboardTypeNumber, // 数字键盘
    NSArray *titles = @[JGSKeyboardTitleLetters, JGSKeyboardTitleSymbols, JGSKeyboardTitleNumbers, JGSKeyboardTitleIDCard];
    NSInteger typeIdx = type - JGSKeyboardTypeLetter;
    if (typeIdx >= 0 && typeIdx < titles.count) {
        return titles[typeIdx];
    }
    return titles.firstObject;
}

FOUNDATION_EXTERN NSArray<NSString *> * const JGSKeyboardKeysForType(JGSKeyboardType type, BOOL fullAngle, BOOL symbolWithNum) {
    
    switch (type) {
        case JGSKeyboardTypeLetter:
            return @[
                @"q", @"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p",
                @"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l",
                @"z", @"x", @"c", @"v", @"b", @"n", @"m",
            ];
            break;
            
        case JGSKeyboardTypeSymbol:
            if (fullAngle) {
                
                if (symbolWithNum) {
                    return @[
                        @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0",
                        // 系统键盘按键，系统输入 UIKeyboardTypeNumbersAndPunctuation 类型时切换到中文输入时获取
                        // 中文左、右引号差别较小，肉眼容易当成一个符号
                        // 电脑键盘输入中文单、双引号为同一按键，自动配对识别成左、右引号
                        @"-", @"/", @"：", @"；", @"（", @"）", @"¥", @"@", @"“", @"”",
                        @"。", @"，", @"、", @"？", @"！", @".",
                    ];
                }
                else {
                    return @[
                        // 系统键盘按键，系统输入 UIKeyboardTypeNumbersAndPunctuation 类型时切换到中文输入时获取
                        // 系统键盘获取缺失右单引号，因此删除最后一行第三个字符 "^_^" ，行末增加右单引号 "’"
                        // 中文左、右引号差别较小，肉眼容易当成一个符号
                        // 电脑键盘输入中文单、双引号为同一按键，自动配对识别成左、右引号
                        @"【", @"】", @"｛", @"｝", @"#", @"%", @"^", @"*", @"+", @"=",
                        @"_", @"—", @"\\", @"｜", @"～", @"《", @"》", @"$", @"&", @"·",
                        @"…", @"，", /*@"^_^", */@"？", @"！", @"‘", @"’",
                    ];
                }
            } else {
                
                if (symbolWithNum) {
                    return @[
                        @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0",
                        // 系统键盘按键，系统输入 UIKeyboardTypeASCIICapable 键盘类型时获取
                        @"-", @"/", @":", @";", @"(", @")", @"$", @"&", @"@", @"\"",
                        @".", @",", @"?", @"!", @"'",
                    ];
                }
                else {
                    return @[
                        // 系统键盘按键，系统输入 UIKeyboardTypeASCIICapable 键盘类型时获取
                        @"[", @"]", @"{", @"}", @"#", @"%", @"^", @"*", @"+", @"=",
                        @"_", @"\\", @"|", @"~", @"<", @">", @"€", @"£", @"¥", @"•",
                        @".", @",", @"?", @"!", @"'",
                    ];
                }
            }
            break;
            
        case JGSKeyboardTypeNumber:
        case JGSKeyboardTypeIDCard: {
            // 身份证输入"."在功能按键上
            // 身份证输入X在功能按键上
            return @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
        }
            break;
    }
}

FOUNDATION_EXTERN NSString * const JGSKeyboardReturnTitleForType(UIReturnKeyType type) {
    
    switch (type) {
        case UIReturnKeyDone:
            return @"完成";
            break;
            
        case UIReturnKeyNext:
            return @"下一项";
            break;
            
        default:
            return @"完成";
            break;
    }
}

@implementation JGSKeyboardConstants

#pragma mark - End

@end
