//
//  JGSKeychainUtils.h
//  JGSourceBase
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSKeychainUtils : NSObject

+ (void)saveToKeychain:(id _Nullable )data forKey:(NSString *)key;
+ (nullable id)readFromKeychain:(NSString *)key;
+ (void)removeFromKeychain:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
