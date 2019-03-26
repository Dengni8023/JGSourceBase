//
//  JGSLogFunction.m
//  JGSourceBase
//
//  Created by 梅继高 on 2019/3/25.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSLogFunction.h"

JGSLogMode JGSEnableLogMode = JGSLogModeNone; //默认不输出日志
FOUNDATION_EXTERN void JGSEnableLogWithMode(JGSLogMode mode) {
    JGSEnableLogMode = mode;
}

@implementation JGSLogFunction

@end
