//
//  UIColor+JGSBase.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "UIColor+JGSBase.h"

FOUNDATION_EXTERN UIColor *JGSColorHex(uint32_t rgbHex) {
    return JGSColorHexA(rgbHex, 1.f);
}

FOUNDATION_EXTERN UIColor *JGSColorHexA(uint32_t rgbHex, float alpha) {
    
    uint32_t rgb = rgbHex;
    while (rgb > 0xFFFFFF) {
        rgb = rgb >> 4;
    }
    
    uint8_t r = (rgb & 0xFF0000) >> 16;
    uint8_t g = (rgb & 0xFF00) >> 8;
    uint8_t b = (rgb & 0xFF) >> 0;
    
    return JGSColorRGBA(r, g, b, alpha);
}

FOUNDATION_EXTERN UIColor *JGSColorHexString(NSString *hex) {
    return JGSColorHexStringA(hex, 1.f);
}

FOUNDATION_EXTERN UIColor *JGSColorHexStringA(NSString *hex, float alpha) {
    
    //JGSColorHexString(@"0xff00ff");
    //JGSColorHexString(@"0xff00ffee");
    //JGSColorHexString(@"#ff00ff");
    //JGSColorHexString(@"#ff00ffee");
    //JGSColorHexString(@"ff00ff");
    //JGSColorHexString(@"ff00ffee");
    //JGSColorHexString(@"ff00ffe");
    
    NSString *regTags = @"^((0x|#){0,1})([0-9a-f]{6,})$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:hex options:0 range:NSMakeRange(0, hex.length)];
    NSCAssert(matches.count != 0, @"颜色字符串 %@ 不符合规范，起始前缀（如有）须以\"0x\"、\"0X\"、\"#\"开头，颜色值最少6位", hex);
    
    NSString *real = hex;
    if ([hex hasPrefix:@"#"]) {
        real = [hex substringFromIndex:1];
    }
    else if ([hex.lowercaseString hasPrefix:@"0x"]) {
        real = [hex substringFromIndex:2];
    }
    
    NSString *rgb = real;
    if (rgb.length > 6) {
        rgb = [rgb substringToIndex:6];
    }
    
    unsigned int rgbNum;
    [[NSScanner scannerWithString:real] scanHexInt:&rgbNum];
    
    return JGSColorHexA(rgbNum, alpha);
}

FOUNDATION_EXTERN UIColor *JGSColorRGB(uint8_t red, uint8_t green, uint8_t blue) {
    return JGSColorRGBA(red, green, blue, 1.f);
}

FOUNDATION_EXTERN UIColor *JGSColorRGBA(uint8_t red, uint8_t green, uint8_t blue, float alpha) {
    return JGSColorFRGBA(red / 255.f, green / 255.f, blue / 255.f, alpha);
}

FOUNDATION_EXTERN UIColor *JGSColorFRGB(float red, float green, float blue) {
    return JGSColorFRGBA(red, green, blue, 1.f);
}

FOUNDATION_EXTERN UIColor *JGSColorFRGBA(float red, float green, float blue, float alpha) {
    alpha = MIN(1.0, MAX(0, alpha));
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

FOUNDATION_EXTERN UIColor *JGSRandomColor(void) {
    return JGSColorRGBA(arc4random() % 256, arc4random() % 256, arc4random() % 256, 1.f);
}

@implementation UIColor (JGSBase)

+ (instancetype)jg_ColorHex:(uint32_t)rgbHex {
    return JGSColorHex(rgbHex);
}

+ (instancetype)jg_ColorHex:(uint32_t)rgbHex alpha:(float)alpha {
    return JGSColorHexA(rgbHex, alpha);
}

+ (instancetype)jg_ColorR:(uint8_t)red g:(uint8_t)green b:(uint8_t)blue {
    return JGSColorRGB(red, green, blue);
}

+ (instancetype)jg_ColorR:(uint8_t)red g:(uint8_t)green b:(uint8_t)blue alpha:(float)alpha {
    return JGSColorRGBA(red, green, blue, alpha);
}

+ (instancetype)jg_ColorFR:(float)red g:(float)green b:(float)blue {
    return JGSColorFRGB(red, green, blue);
}

+ (instancetype)jg_ColorFR:(float)red g:(float)green b:(float)blue alpha:(float)alpha {
    return JGSColorFRGBA(red, green, blue, alpha);
}

+ (instancetype)jg_RandomColor {
    return JGSRandomColor();
}

- (UIColor *)jg_revertColor {
    CGColorSpaceModel spaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    if (spaceModel == kCGColorSpaceModelRGB) {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        return JGSColorRGBA((1.0 - components[0]), (1.0 - components[1]), (1.0 - components[2]), components[3]);
    }
    return nil;
}

@end

@implementation NSString (JGSBase_Hex)

+ (instancetype)jg_stringWithHex:(uint32_t)hex {
    NSMutableString *str = @"".mutableCopy;
    while (hex > 0) {
        uint8_t t = (hex & 0xff);
        hex = hex >> 8;
        [str insertString:[NSString stringWithFormat:@"%02x", t] atIndex:0];
    }
    return str.copy;
}

- (uint32_t)jg_hex {
    
    if (self.length == 0) {
        return 0x00;
    }
    
    NSString *regTags = @"^((0x|#){0,1})([0-9a-f]{0,})$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    NSCAssert(matches.count > 0, @"%@ 不符合十六进制字符串规范，起始前缀（如有）须以\"0x\"、\"0X\"、\"#\"开头", self);
    
    NSString *real = self;
    if ([self hasPrefix:@"#"]) {
        real = [self substringFromIndex:1];
    }
    else if ([self.lowercaseString hasPrefix:@"0x"]) {
        real = [self substringFromIndex:2];
    }
    
    NSString *rgb = real;
    if (rgb.length > 6) {
        rgb = [rgb substringToIndex:6];
    }
    
    unsigned int rgbNum;
    [[NSScanner scannerWithString:real] scanHexInt:&rgbNum];
    
    return rgbNum;
}

@end
