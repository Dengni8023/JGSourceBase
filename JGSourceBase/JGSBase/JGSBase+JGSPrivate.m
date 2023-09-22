//
//  JGSBase+JGSPrivate.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/6/7.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSBase+JGSPrivate.h"

BOOL JGSPrivateLogEnable = NO; // 默认不打印日志
@implementation JGSLogFunction (JGSPrivate)

@end

FOUNDATION_EXTERN NSString * const JGSTemporaryFileSavedDirectory(void) {
    
    static NSString *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *directory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        directory = [directory stringByAppendingPathComponent:@"com.meijigao.JGSoureBase"];
        BOOL isDir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir] || !isDir) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        instance = directory;
    });
    return instance;
}

FOUNDATION_EXTERN NSString * const JGSPermanentFileSavedDirectory(void) {
    
    static NSString *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        directory = [directory stringByAppendingPathComponent:@"com.meijigao.JGSoureBase"];
        BOOL isDir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir] || !isDir) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        instance = directory;
    });
    return instance;
}
