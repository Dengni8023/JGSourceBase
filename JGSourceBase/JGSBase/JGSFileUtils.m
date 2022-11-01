//
//  JGSFileUtils.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/11/1.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSFileUtils.h"

@implementation JGSFileUtils

#pragma mark - MIMEType
+ (NSString *)getMIMETypeOfFile:(NSString *)path {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    return [self getMIMETypeOfURL:url];
}

+ (NSString *)getMIMETypeOfURL:(NSURL *)url {
    
    if (url.absoluteString.length == 0) {
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __block NSString *MIMEType = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            MIMEType = (data != nil && error == nil) ? response.MIMEType : nil;
            dispatch_semaphore_signal(semaphore);
        }] resume];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return MIMEType;
}

#pragma mark - SOrt
+ (void)sortPlistFile:(NSString *)path rewrite:(BOOL)rewrite completion:(void (^)(id _Nullable, BOOL))completion {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        completion ? completion(nil, NO) : nil;
        return;
    }
    
    // Plist文件读出为字典再写回，即完成Key升序整理
    BOOL result = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dict != nil) {
        if (rewrite) {
            result = [dict writeToFile:path atomically:YES];
        }
        completion ? completion(dict, result) : nil;
        return;
    }
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    if (array != nil) {
        if (rewrite) {
            result = [array writeToFile:path atomically:YES];
        }
        completion ? completion(array, result) : nil;
        return;
    }
    
    completion ? completion(nil, result) : nil;
}

+ (void)sortJSONFile:(NSString *)path rewrite:(BOOL)rewrite completion:(void (^)(NSString * _Nullable, BOOL, NSError * _Nullable))completion {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        completion ? completion(nil, NO, nil) : nil;
        return;
    }
    
    // 读取文件 Data
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:kNilOptions error:&error];
    if (!data || error) {
        completion ? completion(nil, NO, error) : nil;
        return;
    }
    
    // 文件 Data 转 JSON 对象
    error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!jsonObj || error) {
        completion ? completion(nil, NO, error) : nil;
        return;
    }
    
    // JSON 对象格式化整理
    error = nil;
    data = [NSJSONSerialization dataWithJSONObject:jsonObj options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:&error];
    if (data.length == 0 || error) {
        completion ? completion(nil, NO, error) : nil;
        return;
    }
    
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    content = [content stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    content = [content stringByReplacingOccurrencesOfString:@"\" :" withString:@"\":"];
    content = [content stringByAppendingString:@"\n"]; // 文件结束增加换行
    
    error = nil;
    BOOL result = [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    completion ? completion(content, result, error) : nil;
}

@end
