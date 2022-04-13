//
//  UIColor+JGSBase.h
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 16进制RGB颜色，alpha默认1.0 */
FOUNDATION_EXTERN UIColor *JGSColorHex(uint32_t rgbHex);
FOUNDATION_EXTERN UIColor *JGSColorHexA(uint32_t rgbHex, float alpha);

/** 16进制RGB颜色值，alpha无效时默认1.0，hex兼容 0xff00ff, #ff00ff，数据仅前6位有效 */
FOUNDATION_EXTERN UIColor *JGSColorHexString(NSString *hex);
FOUNDATION_EXTERN UIColor *JGSColorHexStringA(NSString *hex, float alpha);

/** RGB颜色0～255，alpha默认1.0 */
FOUNDATION_EXTERN UIColor *JGSColorRGB(uint8_t red, uint8_t green, uint8_t blue);
FOUNDATION_EXTERN UIColor *JGSColorRGBA(uint8_t red, uint8_t green, uint8_t blue, float alpha);

/** RGB颜色0～1.0，alpha默认1.0 */
FOUNDATION_EXTERN UIColor *JGSColorFRGB(float red, float green, float blue);
FOUNDATION_EXTERN UIColor *JGSColorFRGBA(float red, float green, float blue, float alpha);

/// 随机颜色
FOUNDATION_EXTERN UIColor *JGSRandomColor(void);

@interface UIColor (JGSBase)

/// @see JGSColorHex
+ (instancetype)jg_ColorHex:(uint32_t)rgbHex;
/// @see JGSColorHexA
+ (instancetype)jg_ColorHex:(uint32_t)rgbHex alpha:(float)alpha;
/// @see JGSColorRGB
+ (instancetype)jg_ColorR:(uint8_t)red g:(uint8_t)green b:(uint8_t)blue;
/// @see JGSColorRGBA
+ (instancetype)jg_ColorR:(uint8_t)red g:(uint8_t)green b:(uint8_t)blue alpha:(float)alpha;
/// @see JGSColorFRGB
+ (instancetype)jg_ColorFR:(float)red g:(float)green b:(float)blue;
/// @see JGSColorFRGBA
+ (instancetype)jg_ColorFR:(float)red g:(float)green b:(float)blue alpha:(float)alpha;
/// @see JGSRandomColor
+ (instancetype)jg_RandomColor;
/// 获取反色，透明度一致
- (nullable UIColor *)jg_revertColor;

@end

@interface NSString (JGSBase_Hex)

+ (instancetype)jg_stringWithHex:(uint32_t)hex;
/// 兼容0x、0X、#、无起始字符
- (uint32_t)jg_hex;

@end

NS_ASSUME_NONNULL_END
