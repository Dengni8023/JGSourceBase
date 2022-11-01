//
//  JGSFileUtils.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/11/1.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSFileUtils : NSObject

#pragma mark - MIMEType
/// 获取文件 MIMEType
/// - Parameter path: 文件路径
+ (nullable NSString *)getMIMETypeOfFile:(NSString *)path;

/// 获取 URL 对应资源 MIMEType
/// - Parameter url: 资源URL
+ (nullable NSString *)getMIMETypeOfURL:(NSURL *)url;

#pragma mark - Sort
/// Plist 文件整理，Plist 内容为 Dictionary 或 Array
/// - Parameters:
///   - path: 文件路径
///   - rewrite: 是否覆盖写回源文件
///   - completion: 完成回调，(文件内容信息, 回写结果)
+ (void)sortPlistFile:(NSString *)path rewrite:(BOOL)rewrite completion:(void (^)(id _Nullable contentDictOrArray, BOOL success))completion;

/// JSON 文件整理
/// - Parameters:
///   - path: 文件路径
///   - rewrite: 是否覆盖写回源文件
///   - completion: 完成回调，(文件内容信息, 回写结果，错误信息)
+ (void)sortJSONFile:(NSString *)path rewrite:(BOOL)rewrite completion:(void (^)(NSString * _Nullable contentJSON, BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
