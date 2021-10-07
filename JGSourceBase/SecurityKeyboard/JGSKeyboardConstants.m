//
//  JGSKeyboardConstants.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/10/7.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSKeyboardConstants.h"
#import "JGSourceBase.h"

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
CGFloat const JGSKeyboardInteritemSpacing = 4.f;
CGFloat const JGSKeyboardKeyLineSpacing = 8.f;
CGFloat const JGSKeyboardKeyWidthHeightRatio() {
    CGRect rect = [UIScreen mainScreen].bounds;
    return CGRectGetWidth(rect) > CGRectGetHeight(rect) ? 16.f / 9.f : 3.f / 4.f;
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
