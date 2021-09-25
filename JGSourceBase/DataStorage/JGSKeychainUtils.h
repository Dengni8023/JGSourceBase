//
//  JGSKeychainUtils.h
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/17.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSKeychainUtils : NSObject

+ (void)saveToKeychain:(id _Nullable )data forKey:(NSString *)key;
+ (id)readFromKeychain:(NSString *)key;
+ (void)removeFromKeychain:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
