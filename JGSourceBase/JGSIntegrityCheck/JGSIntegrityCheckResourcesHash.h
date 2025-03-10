//
//  JGSIntegrityCheckResourcesHash.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSIntegrityCheckResourcesHash : NSObject

/// Info.plist文件key黑名单，多层级对象黑名单层级间使用"."分隔，数组元素黑名单针对数组元素设置
/// 如：{key: [{key1: value1, key2: value2}]} 设置：key.key1，对数组内元素key1值将不进行校验
/// 使用时请注意添加如下特殊配置：
/// "MinimumOSVersion", // Xcode 13 上传商店该字段会被修改
@property (nonatomic, copy) NSArray<NSString *> *checkInfoPlistKeyBlacklist;

/// 需要检验的子目录白名单，该属性不为空时，非白名单子目录均不做校验；文件夹路径全匹配，区分大小写；支持多层目录，路径需从起始目录开始
@property (nonatomic, copy) NSArray<NSString *> *checkFileSubDirectoryWhitelist;

/// 文件Hash校验文件名黑名单，文件名称全匹配，区分大小写
@property (nonatomic, copy) NSArray<NSString *> *checkFileNameBlacklist;

/// 文件Hash校验文件夹黑名单，文件夹路径全匹配，区分大小写；支持多层目录，路径需从起始目录开始
@property (nonatomic, copy) NSArray<NSString *> *checkFileDirectoryBlacklist;

/// 文件Hash校验文件扩展名黑名单，扩展名配置不需要包括"."，支持配置多级扩展，如：“a.b” 表示形如 name.a.b 的文件
/// 使用时请注意添加如下特殊配置：
/// "dylib", // Xcode 16 调试会添加预览相关 dylib
@property (nonatomic, copy) NSArray<NSString *> *checkFileExtesionBlacklist;

+ (instancetype)shareInstance;

/// 检测资源文件Hash、Info.plist文件内容是否发生变化，检测仅针对文件、Info.plist文件Key对应Value内容变化，无法检测文件增删、Info.plist文件Key增删
/// @param completion 检测结果响应
/// unpassFiles 检测未通过的资源文件文件名，包含相对路径
/// unpassPlistInfo Info.plist文件检测未通过内容的Key信息
- (void)checkAPPResourcesHash:(nullable void (^)(NSArray<NSString *> * _Nullable unpassFiles, NSDictionary * _Nullable unpassPlistInfo))completion;

@end

NS_ASSUME_NONNULL_END
