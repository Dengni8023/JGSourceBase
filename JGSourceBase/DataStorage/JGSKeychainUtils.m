//
//  JGSKeychainUtils.m
//  JGSourceBase
//
//  Created by 梅继高 on 2021/3/17.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSKeychainUtils.h"
#import <Security/Security.h>
#import "JGSourceBase.h"

@implementation JGSKeychainUtils

+ (NSDictionary *)keychainQuery:(NSString *)key {
    return @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: key,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, // 仅当前设备，新设备不可用
    };
}

+ (void)saveToKeychain:(id)data forKey:(NSString *)key {
    
    if (!data) {
        [self removeFromKeychain:key];
        return;
    }
    
    // Get search dictionary
    NSMutableDictionary *keychainQuery = [self keychainQuery:key].mutableCopy;
    // Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    // Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    // Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)readFromKeychain:(NSString *)key {
    
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self keychainQuery:key].mutableCopy;
    // Configure the search setting
    // Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            JGSLog(@"Unarchive of %@ failed: %@", key, e);
        } @finally {
        }
    }
    if (keyData) {
        CFRelease(keyData);
    }
    
    return ret;
}

+ (void)removeFromKeychain:(NSString *)key {
    
    NSDictionary *keychainQuery = [self keychainQuery:key];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

@end
