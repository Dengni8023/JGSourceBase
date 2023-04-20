//
//  JGSBase+JGSPrivate.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/6/7.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSBase+JGSPrivate.h"

@implementation JGSBaseUtils (JGSPrivate)

+ (void)requestGitRepositoryFileContent:(NSString *)filePath retryTimes:(NSInteger)retryTimes completion:(void (^)(NSData * _Nullable))completion {
    
    NSMutableCharacterSet *mutSet = [NSCharacterSet URLPathAllowedCharacterSet].mutableCopy;
    [mutSet formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [mutSet formUnionWithCharacterSet:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    filePath = [filePath stringByAddingPercentEncodingWithAllowedCharacters:mutSet];
    if (filePath.length == 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    static NSMutableDictionary *retryTimesInfo = nil;
    if (retryTimesInfo == nil) {
        retryTimesInfo = @{}.mutableCopy;
    }
    
    __block NSData *fileData = nil;
    __block NSHTTPURLResponse *httpResp = nil;
    __block NSError *httpError = nil;
    
    // 并行从 Gitee、GitHub 获取文件内容
    // 1、任一获取成功，则获取成功
    // 2、两者均失败则重试
    dispatch_queue_t requestQueue = dispatch_queue_create("com.meijigao.JGSourceBase.getGitFileContent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); // 创建信号量
    dispatch_async(requestQueue, ^{
        
        __block int finishCount = 0;
        NSPointerArray *taskPointer = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        
        // 获取 Gitee 文件
        [taskPointer addPointer:(void *)[self requestGiteeRepositoryFileContent:filePath completion:^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
            
            @synchronized (requestQueue) {
                fileData = data;
                httpResp = response;
                httpError = error;
                finishCount += 1;
                
                //JGSPrivateLog(@"\n%@ statusCode: %@, data length: %@, error: %@", filePath, @(httpResp.statusCode), @(fileData.length), httpError);
                if (data.length > 0) {
                    [taskPointer.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [(NSURLSessionDataTask *)obj cancel];
                    }];
                }
                
                if (data.length > 0 || finishCount > 1) {
                    dispatch_semaphore_signal(semaphore);   // 发送信号
                }
            }
        }]];
        
        // 获取 GitHub 文件
        [taskPointer addPointer:(void *)[self requestGitHubRepositoryFileContent:filePath completion:^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
            
            @synchronized (requestQueue) {
                fileData = data;
                httpResp = response;
                httpError = error;
                finishCount += 1;
                
                //JGSPrivateLog(@"\n%@ statusCode: %@, data length: %@, error: %@", filePath, @(httpResp.statusCode), @(fileData.length), httpError);
                if (data.length > 0) {
                    [taskPointer.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [(NSURLSessionDataTask *)obj cancel];
                    }];
                }
                
                if (data.length > 0 || finishCount > 1) {
                    dispatch_semaphore_signal(semaphore);   // 发送信号
                }
            }
        }]];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);  // 一直等待完成
    
    JGSPrivateLog(@"\n%@ statusCode: %@, data length: %@, error: %@", filePath, @(httpResp.statusCode), @(fileData.length), httpError);
    if (httpResp.statusCode == 200 || httpResp.statusCode == 404) {
        if (completion) {
            completion(httpResp.statusCode == 200 && fileData.length > 0 ? fileData : nil);
        }
        return;
    }
    
    switch (httpError.code) {
        case NSURLErrorBadURL: {
            if (completion) {
                completion(nil);
            }
            return;
        }
            break;
            
        default:
            break;
    }
    
    NSInteger retry = [retryTimesInfo[filePath] integerValue] + 1;
    NSInteger maxRetryTimes = MAX(retryTimes, 5); // 为避免网络阻塞，无限重试限制次数
    if (retry > maxRetryTimes) {
        
        // 避免下次无法重试问题
        [retryTimesInfo removeObjectForKey:filePath];
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    retryTimesInfo[filePath] = @(retry);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * (1 + log2(retry)) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [JGSBaseUtils requestGitRepositoryFileContent:filePath retryTimes:retryTimes completion:completion];
    });
}

+ (NSURLSessionDataTask *)requestGitHubRepositoryFileContent:(NSString *)urlEncodeFilePath completion:(void (^)(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completion {
    
    if (urlEncodeFilePath.length == 0) {
        if (completion) {
            completion(nil, nil, nil);
        }
        return nil;
    }
    
    // GitHub API 文档：获取仓库具体路径下的内容
    // 官方文档：https://docs.github.com/cn/rest/repos/contents#get-repository-content
    // CNBlogs文档：https://www.cnblogs.com/chen-xing/p/14058096.html
    /*
     // API: https://api.github.com/api/v5//repos/{owner}/{repo}/contents/{path}
     // API对应本仓库：https://api.github.com/repos/Dengni8023/JGSourceBase/contents/{path} 获取仓库内容
     // 查看对应文件的信息如下：
     {
     "name":"LatestGlobalConfiguration.json.sec",
     "path":"LatestGlobalConfiguration.json.sec",
     "sha":"8913981d9b86a5080db01b25b4a59ba8e54d7d11",
     "size":124,
     "url":"https://api.github.com/repos/Dengni8023/JGSourceBase/contents/LatestGlobalConfiguration.json.sec?ref=master",
     "html_url":"https://github.com/Dengni8023/JGSourceBase/blob/master/LatestGlobalConfiguration.json.sec",
     "git_url":"https://api.github.com/repos/Dengni8023/JGSourceBase/git/blobs/8913981d9b86a5080db01b25b4a59ba8e54d7d11",
     "download_url":"https://raw.githubusercontent.com/Dengni8023/JGSourceBase/master/LatestGlobalConfiguration.json.sec",
     "type":"file",
     "_links":{
     "self":"https://api.github.com/repos/Dengni8023/JGSourceBase/contents/LatestGlobalConfiguration.json.sec?ref=master",
     "git":"https://api.github.com/repos/Dengni8023/JGSourceBase/git/blobs/8913981d9b86a5080db01b25b4a59ba8e54d7d11",
     "html":"https://github.com/Dengni8023/JGSourceBase/blob/master/LatestGlobalConfiguration.json.sec",
     }
     }
     // 根据文件信息 download_url 获取文件下载地址API: https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{path}
     // API对应本仓库：https://raw.githubusercontent.com/Dengni8023/JGSourceBase/master/{path}
     */
    // 以下地址受限于网络，可能存在请求不到数据情况
    // 同一地址可能4G请求报错，WiFi则正常
    NSString *fileContentAPI = @"https://raw.githubusercontent.com/Dengni8023/JGSourceBase/master";
    NSString *fileURL = [fileContentAPI stringByAppendingPathComponent:urlEncodeFilePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
    request.HTTPMethod = @"GET";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    request.timeoutInterval = 5;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        completion(data, (NSHTTPURLResponse *)response, error);
        
    }];
    [task resume];
    return task;
}

+ (NSURLSessionDataTask *)requestGiteeRepositoryFileContent:(NSString *)urlEncodeFilePath completion:(void (^)(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completion {
    
    if (urlEncodeFilePath.length == 0) {
        if (completion) {
            completion(nil, nil, nil);
        }
        return nil;
    }
    
    // Gitee API 文档：获取仓库具体路径下的内容
    // https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoContents(Path)
    /*
     // API: https://gitee.com/api/v5/repos/{owner}/{repo}/contents(/{path})
     // API对应本仓库：https://gitee.com/api/v5/repos/Dengni8023/JGSourceBase/contents/{path} 获取仓库内容
     // 查看对应文件的信息如下：
     {
     "type":"file",
     "size":null,
     "name":"LatestGlobalConfiguration.json.sec",
     "path":"LatestGlobalConfiguration.json.sec",
     "sha":"8913981d9b86a5080db01b25b4a59ba8e54d7d11",
     "url":"https://gitee.com/api/v5/repos/dengni8023/JGSourceBase/contents/LatestGlobalConfiguration.json.sec",
     "html_url":"https://gitee.com/dengni8023/JGSourceBase/blob/master/LatestGlobalConfiguration.json.sec",
     "download_url":"https://gitee.com/dengni8023/JGSourceBase/raw/master/LatestGlobalConfiguration.json.sec",
     "_links":{
     "self":"https://gitee.com/api/v5/repos/dengni8023/JGSourceBase/contents/LatestGlobalConfiguration.json.sec",
     "html":"https://gitee.com/dengni8023/JGSourceBase/blob/master/LatestGlobalConfiguration.json.sec",
     }
     }
     // 根据文件信息 download_url 获取文件下载地址API: https://gitee.com/{owner}/{repo}/raw/{branch}/{path}
     // API对应本仓库：https://gitee.com/dengni8023/JGSourceBase/raw/master/{path}
     */
    NSString *fileContentAPI = @"https://gitee.com/dengni8023/JGSourceBase/raw/master";
    NSString *fileURL = [fileContentAPI stringByAppendingPathComponent:urlEncodeFilePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
    request.HTTPMethod = @"GET";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    request.timeoutInterval = 5;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        completion(data, (NSHTTPURLResponse *)response, error);
        
    }];
    [task resume];
    
    return task;
}

+ (nullable NSDictionary<NSString *, id> *)decryptedJGSLatestGlobalConfiguration:(NSData *)fileData {
    
    if (fileData.length == 0) {
        return nil;
    }
    
    // 配置文件Base64解密
    // Baes64替换规则：同时从首尾遍历，每xx位字符串块首尾替换
    NSMutableString *base64String = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding].mutableCopy;
    NSInteger stringLen = base64String.length;
    NSInteger blockSize = 5;
    for (NSInteger i = 0; i < (stringLen / blockSize) / 2; i++) {
        NSRange headrange = NSMakeRange(i * blockSize, blockSize);
        NSString *headStr = [base64String substringWithRange:headrange];
        NSRange tailRange = NSMakeRange(stringLen - (i + 1) * blockSize, blockSize);
        NSString *tailStr = [base64String substringWithRange:tailRange];
        [base64String replaceCharactersInRange:headrange withString:tailStr];
        [base64String replaceCharactersInRange:tailRange withString:headStr];
    }
    
    NSData *originData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSError *error = nil;
    NSDictionary<NSString *, id> *instance = [NSJSONSerialization JSONObjectWithData:originData options:kNilOptions error:&error];
    if (error != nil) {
        JGSPrivateLog(@"%@", error);
    }
    
    return [instance isKindOfClass:[NSDictionary class]] ? instance : nil;
}

@end

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

FOUNDATION_EXTERN NSString * const JGSLatestGlobalConfigurationSavedPath(void) {
    
    static NSString *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *dir = JGSPermanentFileSavedDirectory();
        instance = [dir stringByAppendingPathComponent:@"LatestGlobalConfiguration.json.sec"];
    });
    return instance;
}

FOUNDATION_EXTERN NSDictionary<NSString *, id> * const JGSLatestGlobalConfiguration(void) {
    
    static NSDictionary<NSString *, id> *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            // 已存储配置
            NSString *path = JGSLatestGlobalConfigurationSavedPath();
            NSData *jsonData = [[NSFileManager defaultManager] fileExistsAtPath:path] ? [NSData dataWithContentsOfFile:path] : nil;
            if (jsonData.length > 0) {
                
                // 配置文件Base64解密
                // Baes64替换规则：同时从首尾遍历，每xx位字符串块首尾替换
                NSMutableString *base64String = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding].mutableCopy;
                NSInteger stringLen = base64String.length;
                NSInteger blockSize = 5;
                for (NSInteger i = 0; i < (stringLen / blockSize) / 2; i++) {
                    NSRange headrange = NSMakeRange(i * blockSize, blockSize);
                    NSString *headStr = [base64String substringWithRange:headrange];
                    NSRange tailRange = NSMakeRange(stringLen - (i + 1) * blockSize, blockSize);
                    NSString *tailStr = [base64String substringWithRange:tailRange];
                    [base64String replaceCharactersInRange:headrange withString:tailStr];
                    [base64String replaceCharactersInRange:tailRange withString:headStr];
                }
                
                NSData *originData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                NSError *error = nil;
                instance = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:originData options:kNilOptions error:&error];
                if (error != nil) {
                    JGSPrivateLog(@"%@", error);
                }
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                // 因版本问题，版本内置资源不一定为最新，需要读取网络仓库最新资源
                NSString *gitFilePath = @"LatestGlobalConfiguration.json.sec";
                [JGSBaseUtils requestGitRepositoryFileContent:gitFilePath retryTimes:0 completion:^(NSData * _Nullable fileData) {
                    
                    if (fileData.length > 0) {
                        //JGSPrivateLog(@"Use remote git file: %@", [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding]);
                        NSError *error = nil;
                        [fileData writeToFile:path options:(NSDataWritingAtomic) error:&error];
                        if (error) {
                            JGSPrivateLog(@"%@", error);
                        }
                        // 更新配置
                        error = nil;
                        instance = [JGSBaseUtils decryptedJGSLatestGlobalConfiguration:fileData];
                        if (error != nil) {
                            JGSPrivateLog(@"%@", error);
                        }
                    }
                }];
            });
            
            dispatch_semaphore_signal(semaphore);   //发送信号
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);  //等待
    });
    
    return instance;
}
