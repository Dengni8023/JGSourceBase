//
//  JGSCCommon.h
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#ifndef JGSCCommon_h
#define JGSCCommon_h

// Reuse identifier
#pragma mark - Reuse
#define JGSCReuseIdentifier(Class) [NSStringFromClass([self class]) stringByAppendingFormat:@"_%@", NSStringFromClass([Class class])]

#endif /* JGSCCommon_h */
