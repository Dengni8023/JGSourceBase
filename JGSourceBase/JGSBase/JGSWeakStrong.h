//
//  JGSWeakStrong.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#ifndef JGSWeakStrong_h
#define JGSWeakStrong_h

/**
 block循环引用处理宏定义
 */

// 使用形如：JGSWeak(object)
#ifndef JGSWeak
#if DEBUG
#if __has_feature(objc_arc)
#define JGSWeak(object) @autoreleasepool{} __weak __typeof__(object) weak##object = object;
#else
#define JGSWeak(object) @autoreleasepool{} __block __typeof__(object) block##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define JGSWeak(object) @try{} @finally{} {} __weak __typeof__(object) weak##object = object;
#else
#define JGSWeak(object) @try{} @finally{} {} __block __typeof__(object) block##object = object;
#endif
#endif
#endif

// 声明局部变量，默认为strong引用，可以不写__strong关键字
#ifndef JGSStrong
#if DEBUG
#if __has_feature(objc_arc)
#define JGSStrong(object) @autoreleasepool{} __typeof__(weak##object) object = weak##object;
#else
#define JGSStrong(object) @autoreleasepool{} __typeof__(block##object) object = block##object;
#endif
#else
#if __has_feature(objc_arc)
#define JGSStrong(object) @try{} @finally{} {} __typeof__(weak##object) object = weak##object;
#else
#define JGSStrong(object) @try{} @finally{} {} __typeof__(block##object) object = block##object;
#endif
#endif
#endif

// weakself, self
#ifndef JGSWeakSelf
#define JGSWeakSelf JGSWeak(self)
#endif
#ifndef JGSStrongSelf
#define JGSStrongSelf JGSStrong(self)
#endif

// weakself, self
#ifndef JGSWS
#define JGSWS JGSWeakSelf
#endif
#ifndef JGSSS
#define JGSSS JGSStrongSelf
#endif

#endif /* JGSWeakStrong_h */
