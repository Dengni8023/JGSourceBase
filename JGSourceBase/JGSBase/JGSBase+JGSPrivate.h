//
//  JGSBase+JGSPrivate.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/6/7.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#if __has_include(<JGSourceBase/JGSBase.h>)
#import <JGSourceBase/JGSBase.h>
#else
#import "JGSBase.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface JGSBaseUtils (JGSPrivate)

/// 从git仓库加载文件内容
/// - Parameters:
///   - urlString: 文件路径，相对于仓库的根目录
///   - retryTimes: 重试次数，0表示始终重试
///   - completion: 加载结果回调
+ (void)requestGitRepositoryFileContent:(NSString *)filePath retryTimes:(NSInteger)retryTimes completion:(void (^)(NSData * _Nullable fileData))completion;

@end

/// 是否开启内部调试日志，默认不开启打印日志
FOUNDATION_EXTERN BOOL JGSPrivateLogEnable;
#define JGSPrivateLogWithModeLevel(level, fmt, ...) {\
    if (JGSPrivateLogEnable) { \
        NSDictionary *map = JGSLogLevelMap()[@(level)]; \
        NSString *lvStr = [NSString stringWithFormat:@"%@ [%@]", map[@"emoji"], map[@"level"]]; \
        JGSLogWithFormat((@"%@ %s Line: %@ " fmt ""), lvStr, __PRETTY_FUNCTION__, @(__LINE__), ##__VA_ARGS__); \
    } \
}

#define JGSPrivateLog(fmt, ...)     JGSPrivateLogD(fmt, ##__VA_ARGS__)
#define JGSPrivateLogD(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelDebug, fmt, ##__VA_ARGS__)
#define JGSPrivateLogI(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelInfo, fmt, ##__VA_ARGS__)
#define JGSPrivateLogW(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelWarn, fmt, ##__VA_ARGS__)
#define JGSPrivateLogE(fmt, ...)    JGSPrivateLogWithModeLevel(JGSLogLevelError, fmt, ##__VA_ARGS__)

@interface JGSLogFunction (JGSPrivate)

@end

// 临时存储文件路径文件夹
FOUNDATION_EXTERN NSString * const JGSTemporaryFileSavedDirectory(void);
// 永久存储文件路径文件夹
FOUNDATION_EXTERN NSString * const JGSPermanentFileSavedDirectory(void);

// 远程仓库最新资源配置信息
FOUNDATION_EXTERN NSDictionary<NSString *, id> * const _Nullable JGSLatestGlobalConfiguration(void);

NS_ASSUME_NONNULL_END
