//
//  JGSIgnoreWarning.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/27.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#ifndef JGSIgnoreWarning_h
#define JGSIgnoreWarning_h

// 常用警告消除宏定义
#pragma mark - 常用警告消除宏定义
// 消除performSelector的警告
#define JGSSuppressWarning_PerformSelector(PerformCoding) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
}

// 消除方法弃用(过时)的警告
#define JGSSuppressWarning_DeprecatedDeclarations(PerformCoding) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
}

// 消除未声明的选择器的警告
#define JGSSuppressWarning_UndeclaredSelector(PerformCoding) \
{ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
PerformCoding \
_Pragma("clang diagnostic pop") \
}

#endif /* JGSIgnoreWarning_h */
