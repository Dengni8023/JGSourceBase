//
//  JGSCommandLineTool.h
//  JGCommandLineDemo
//
//  Created by 梅继高 on 2022/11/1.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSCommandLineTool : NSObject

+ (void)sortPlistFiles;
+ (void)sortJSONFiles;
+ (void)sortAndAESEncryptDeviceListData;

/// 全局配置文件整理并 Base64 编码
/// base64 编码后分别从首尾每第5位进行首尾替换
+ (void)sortAndBase64EncryptGlobalConfiguration;

@end

NS_ASSUME_NONNULL_END
