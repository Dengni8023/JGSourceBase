//
//  JGSKeyboardConstants.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/10/7.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSKeyboardConstants.h"
#import "UIColor+JGSBase.h"

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

CGFloat const JGSKeyboardInteritemSpacing() {
    
    static NSDictionary <NSString *, NSDictionary <NSString *, NSNumber *> *> *spacingInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spacingInfo = @{
            @"iPad": @{
                    @"Portrait": @(12.f),
                    @"Landscape": @(16.f),
            },
            @"iPhone": @{
                    @"Portrait": @(4.f),
                    @"Landscape": @(4.f),
            }
        };
    });
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
    NSString *device = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    NSNumber *spacing = spacingInfo[device][orientation];
    
    return [spacing floatValue];
};

CGFloat const JGSKeyboardKeyLineSpacing() {
    
    static NSDictionary <NSString *, NSDictionary <NSString *, NSNumber *> *> *spacingInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spacingInfo = @{
            @"iPad": @{
                    @"Portrait": @(9.f),
                    @"Landscape": @(12.f),
            },
            @"iPhone": @{
                    @"Portrait": @(8.f),
                    @"Landscape": @(4.f),
            }
        };
    });
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
    NSString *device = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    NSNumber *spacing = spacingInfo[device][orientation];
    
    return [spacing floatValue];
}

CGFloat const JGSKeyboardKeyWidthHeightRatio() {
    
    static NSDictionary <NSString *, NSDictionary <NSString *, NSNumber *> *> *whRatioInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whRatioInfo = @{
            @"iPad": @{
                    @"Portrait": @(60.f / 55.f),
                    @"Landscape": @(85.f / 75.f),
            },
            @"iPhone": @{
                    @"Portrait": @(3.f / 4.f),
                    @"Landscape": @(16.f / 9.f),
            }
        };
    });
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    NSString *orientation = isPortrait ? @"Portrait" : @"Landscape";
    NSString *device = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    NSNumber *ratio = whRatioInfo[device][orientation];
    
    return [ratio floatValue];
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

FOUNDATION_EXTERN NSString * const JGSKeyboardReturnTitleForType(JGSKeyboardReturnType type) {
    
    //JGSKeyboardReturnTypeDone = 0, // 完成
    //JGSKeyboardReturnTypeNext, // 下一项
    NSArray *titles = @[@"完成", @"下一项"];
    NSInteger typeIdx = type - JGSKeyboardReturnTypeDone;
    if (typeIdx >= 0 && typeIdx < titles.count) {
        return titles[typeIdx];
    }
    return titles.firstObject;
}

@implementation JGSKeyboardConstants

@end
