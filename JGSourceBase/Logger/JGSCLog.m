//
//  JGSCLog.m
//  JGSourceBase
//
//  Created by 梅继高 on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "JGSCLog.h"

JGSCLogMode JGSCEnableLogMode = JGSCLogModeNone;
FOUNDATION_EXTERN void JGSCEnableLogWithMode(JGSCLogMode mode) {
    JGSCEnableLogMode = mode;
}
