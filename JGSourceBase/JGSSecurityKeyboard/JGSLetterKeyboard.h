//
//  JGSLetterKeyboard.h
//  JGSSecurityKeyboard
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#if __has_include(<JGSourceBase/JGSBaseKeyboard.h>)
#import <JGSourceBase/JGSBaseKeyboard.h>
#else
#import "JGSBaseKeyboard.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JGSLetterKeyboard : JGSBaseKeyboard

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
