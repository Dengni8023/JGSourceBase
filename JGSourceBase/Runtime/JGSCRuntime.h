//
//  JGSCRuntime.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 更改方法实现，严谨逻辑实现 */
FOUNDATION_EXPORT void JGSCRuntimeSwizzledMethod(Class cls, SEL originSelector, SEL swizzledSelector);

NS_ASSUME_NONNULL_END
