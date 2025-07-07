//
//  JGSCommandLine.h
//  JGCommandLine
//
//  Created by 梅继高 on 2022/11/1.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSCommandLine : NSObject

+ (void)sortPlistFiles;
+ (void)sortJSONFiles;
+ (void)sortAndAESEncryptDeviceListData;

@end

NS_ASSUME_NONNULL_END
