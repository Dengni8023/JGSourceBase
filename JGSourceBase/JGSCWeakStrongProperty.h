//
//  JGSCWeakStrongProperty.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#ifndef JGSCWeakStrongProperty_h
#define JGSCWeakStrongProperty_h

// block循环引用处理宏定义
// 使用形如：JGSCWeak(object)

#ifndef JGSCWeakSelf
#define JGSCWeakSelf JGSCWeak(self)
#endif

#ifndef JGSCStrongSelf
#define JGSCStrongSelf JGSCStrong(self)
#endif

#ifdef DEBUG

// weak
#define JGSCWeak(object) \
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Wunused-variable\"")\
_Pragma("clang diagnostic ignored \"-Wshadow\"")\
@autoreleasepool{}\
__weak __typeof__(object) weak##object = object;\
_Pragma("clang diagnostic pop")

// strong
#define JGSCStrong(object) \
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Wunused-variable\"")\
_Pragma("clang diagnostic ignored \"-Wshadow\"")\
@autoreleasepool{}\
__strong __typeof__(weak##object) object = weak##object;\
_Pragma("clang diagnostic pop")

#else

// weak
#define JGSCWeak(object) \
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Wunused-variable\"")\
_Pragma("clang diagnostic ignored \"-Wshadow\"")\
@try{} @finally{}\
__weak __typeof__(object) weak##object = object;\
_Pragma("clang diagnostic pop")

// strong
#define JGSCStrong(object) \
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Wunused-variable\"")\
_Pragma("clang diagnostic ignored \"-Wshadow\"")\
@try{} @finally{}\
__strong __typeof__(weak##object) object = weak##object;\
_Pragma("clang diagnostic pop")

#endif

#endif /* JGSCWeakStrongProperty_h */
