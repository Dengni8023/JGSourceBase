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
// 定义一个弱引用变量，避免在block中产生循环引用
#ifndef JGSWeak
#if DEBUG
#if __has_feature(objc_arc)
#define JGSWeak(object) @autoreleasepool{} __weak __typeof__(object) weak##object = object;
// 在DEBUG模式下，如果启用了ARC，则使用__weak关键字创建弱引用
#else
#define JGSWeak(object) @autoreleasepool{} __block __typeof__(object) block##object = object;
// 在DEBUG模式下，如果没有启用ARC，则使用__block关键字创建弱引用
#endif
#else
#if __has_feature(objc_arc)
#define JGSWeak(object) @try{} @finally{} {} __weak __typeof__(object) weak##object = object;
// 在非DEBUG模式下，如果启用了ARC，则使用__weak关键字创建弱引用，并用@try和@finally确保安全
#else
#define JGSWeak(object) @try{} @finally{} {} __block __typeof__(object) block##object = object;
// 在非DEBUG模式下，如果没有启用ARC，则使用__block关键字创建弱引用，并用@try和@finally确保安全
#endif
#endif
#endif

// 声明局部变量，默认为strong引用，可以不写__strong关键字
// 将弱引用转换为强引用，确保在block内部使用时对象不会被释放
#ifndef JGSStrong
#if DEBUG
#if __has_feature(objc_arc)
#define JGSStrong(object) @autoreleasepool{} __typeof__(weak##object) object = weak##object;
// 在DEBUG模式下，如果启用了ARC，则将弱引用转换为强引用
#else
#define JGSStrong(object) @autoreleasepool{} __typeof__(block##object) object = block##object;
// 在DEBUG模式下，如果没有启用ARC，则将弱引用转换为强引用
#endif
#else
#if __has_feature(objc_arc)
#define JGSStrong(object) @try{} @finally{} {} __typeof__(weak##object) object = weak##object;
// 在非DEBUG模式下，如果启用了ARC，则将弱引用转换为强引用，并用@try和@finally确保安全
#else
#define JGSStrong(object) @try{} @finally{} {} __typeof__(block##object) object = block##object;
// 在非DEBUG模式下，如果没有启用ARC，则将弱引用转换为强引用，并用@try和@finally确保安全
#endif
#endif
#endif

// weakself, self
// 定义一个弱引用的self，避免在block中产生循环引用
#ifndef JGSWeakSelf
#define JGSWeakSelf JGSWeak(self)
#endif
// 定义一个强引用的self，确保在block内部使用时对象不会被释放
#ifndef JGSStrongSelf
#define JGSStrongSelf JGSStrong(self)
#endif

// weakself, self
// 简化版的弱引用self宏定义
#ifndef JGSWS
#define JGSWS JGSWeakSelf
#endif
// 简化版的强引用self宏定义
#ifndef JGSSS
#define JGSSS JGSStrongSelf
#endif

#endif /* JGSWeakStrong_h */
