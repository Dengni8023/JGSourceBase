//
//  main.m
//  JGSResourceHandler
//
//  Created by 梅继高 on 2022/4/13.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+JGSAES.h"

/// 获取文件MIMEType
/// @param path 文件全路径
static NSString * _Nullable getMIMEType(NSString * _Nonnull path) {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    
    __block NSString *MIMEType = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        MIMEType = response.MIMEType;
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return MIMEType;
}

/// Plist文件内容key排序整理
/// @param path 文件全路径
static void sortPlistFileContent(NSString * _Nonnull path, void (^completion)(BOOL result, NSError * _Nullable error)) {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        completion ? completion(NO, nil) : nil;
        return;
    }
    
    // Plist文件读出为字典再写回，即完成Key升序整理
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    BOOL result = [dict writeToFile:path atomically:YES];
    
    completion ? completion(result, nil) : nil;
}

/// JSON文件key排序整理
/// @param path 文件全路径
static void sortJsonFileContent(NSString * _Nonnull path, void (^completion)(BOOL result, NSError * _Nullable error)) {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        completion ? completion(NO, nil) : nil;
        return;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:kNilOptions error:&error];
    if (!data || error) {
        completion ? completion(NO, error) : nil;
        return;
    }
    
    error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!jsonObj || error) {
        completion ? completion(NO, error) : nil;
        return;
    }
    
    error = nil;
    data = [NSJSONSerialization dataWithJSONObject:jsonObj options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:&error];
    if (data.length == 0 || error) {
        completion ? completion(NO, error) : nil;
        return;
    }
    
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    content = [content stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    content = [content stringByReplacingOccurrencesOfString:@"\" :" withString:@"\":"];
    content = [content stringByAppendingString:@"\n"]; // 文件结束增加换行
    
    error = nil;
    BOOL result = [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    completion ? completion(result, error) : nil;
}

NSData * _Nullable aesEncryptData(NSData *fileData, NSString *fileName) {
	
	if (fileData.length == 0 || fileName.length == 0) {
		return nil;
	}
	
	size_t keyLen = kCCKeySizeAES256;
	size_t blockSize = kCCBlockSizeAES128;
	
	NSString *key = fileName;
	while (key.length < keyLen) {
		key = [key stringByAppendingString:key];
	}
	
	NSString *iv = [key substringFromIndex:key.length - blockSize];
	key = [key substringToIndex:keyLen];
	
	return [fileData jg_AES256EncryptWithKey:key iv:iv];
}

NSData * _Nullable aesEncryptFile(NSString *filePath) {
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		return nil;
	}
	
	NSData *fileData = [NSData dataWithContentsOfFile:filePath];
	NSString *fileName = filePath.lastPathComponent;
	fileData = aesEncryptData(fileData, fileName);
	return fileData;
}

// JGSDevice 资源文件处理
static NSString *JGSDeviceSourceDir = @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSourceBase/JGSDevice/Resources";
void handleDevicesInfo(void) {
	
	NSString *filePath = [JGSDeviceSourceDir stringByAppendingPathComponent:@"JGSiOSDeviceList-Origin.json"];
	NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
	NSDictionary<NSString *, NSArray<NSDictionary *> *> *devices = [dict objectForKey:@"devices"];
	
	NSMutableDictionary<NSString *, NSDictionary*> *models = @{}.mutableCopy;
	[devices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSDictionary *> * _Nonnull type, BOOL * _Nonnull stop) {
		
		[type enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			
			NSMutableDictionary *tmpObj = obj.mutableCopy;
			NSArray<NSString *> *identifiers = tmpObj[@"Identifier"];
			[tmpObj removeObjectForKey:@"Identifier"];
			[identifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
				[models setObject:tmpObj forKey:identifier];
			}];
		}];
	}];
    
    NSData *sortedData = [NSJSONSerialization dataWithJSONObject:models options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:nil];
    
    // 整理后源JSON文件
    NSString *destFileName = @"JGSiOSDeviceList.json";
    NSString *jsonPath = [JGSDeviceSourceDir stringByAppendingPathComponent:destFileName];
    [sortedData writeToFile:jsonPath options:(NSDataWritingAtomic) error:nil] ? NSLog(@"写入成功") : NSLog(@"写入失败");
    
    // 加密-整理后源JSON文件
    NSString *secFileName = [destFileName stringByAppendingPathExtension:@"sec"];
	sortedData = aesEncryptData(sortedData, secFileName) ?: [NSData data];
    NSString *secPath = [JGSDeviceSourceDir stringByAppendingPathComponent:secFileName];
	[sortedData writeToFile:secPath options:(NSDataWritingAtomic) error:nil] ? NSLog(@"写入成功") : NSLog(@"写入失败");
}

// JGSDevice 资源文件处理
static NSString *JGSLatestGlobalConfigurationFileDir = @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase";
void handleLatestGlobalConfiguration(void) {
    
    NSString *fileName = @"LatestGlobalConfiguration.json";
    NSString *filePath = [JGSLatestGlobalConfigurationFileDir stringByAppendingPathComponent:fileName];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    // 配置文件Base64加密
    // Baes64替换规则：同时从首尾遍历，每xx位字符串块首尾替换
    NSMutableString *base64String = [jsonData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed].mutableCopy;
    //NSLog(@"\n%@", base64String);
    NSInteger stringLen = base64String.length;
    NSInteger blockSize = 5;
    for (NSInteger i = 0; i < (stringLen / blockSize) * 0.5; i++) {
        NSRange headrange = NSMakeRange(i * blockSize, blockSize);
        NSString *headStr = [base64String substringWithRange:headrange];
        NSRange tailRange = NSMakeRange(stringLen - (i + 1) * blockSize, blockSize);
        NSString *tailStr = [base64String substringWithRange:tailRange];
        [base64String replaceCharactersInRange:headrange withString:tailStr];
        [base64String replaceCharactersInRange:tailRange withString:headStr];
    }
    //NSLog(@"\n%@", base64String);
    NSString *secPath = [filePath stringByAppendingPathExtension:@"sec"];
    [base64String writeToFile:secPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void testLatestGlobalConfiguration(void) {
    
    NSString *path = [JGSLatestGlobalConfigurationFileDir stringByAppendingPathComponent:@"LatestGlobalConfiguration.json.sec"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    if (jsonData.length == 0) {
        return;
    }
    
    // 配置文件Base64解密
    // Baes64替换规则：同时从首尾遍历，每xx位字符串块首尾替换
    NSMutableString *base64String = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding].mutableCopy;
    NSInteger stringLen = base64String.length;
    NSInteger blockSize = 5;
    for (NSInteger i = 0; i < (stringLen / blockSize) * 0.5; i++) {
        NSRange headrange = NSMakeRange(i * blockSize, blockSize);
        NSString *headStr = [base64String substringWithRange:headrange];
        NSRange tailRange = NSMakeRange(stringLen - (i + 1) * blockSize, blockSize);
        NSString *tailStr = [base64String substringWithRange:tailRange];
        [base64String replaceCharactersInRange:headrange withString:tailStr];
        [base64String replaceCharactersInRange:tailRange withString:headStr];
    }
    
    NSData *originData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSLog(@"\n%@", [[NSString alloc] initWithData:originData encoding:NSUTF8StringEncoding]);
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
        
        NSLog(@"Sort plist file >>>>");
        NSArray<NSString *> *plistFiles = @[
            @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSourceBase/Info.plist",
            @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSourceBase.bundle/Info.plist",
            @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSourceBaseDemo/Info.plist",
            @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSourceBaseDemo/JGSourceBaseDemo/Info.plist",
        ];
        [plistFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sortPlistFileContent(obj, ^(BOOL result, NSError * _Nullable error) {
                NSLog(@"Sort %@, %@", obj, result ? @"success" : [NSString stringWithFormat:@"fail: %@", error]);
            });
        }];
        NSLog(@"");
        
        NSLog(@"Sort json file >>>>");
        NSArray<NSString *> *jsonFiles = @[
            @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/LatestGlobalConfiguration.json",
        ];
        [jsonFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sortJsonFileContent(obj, ^(BOOL result, NSError * _Nullable error) {
                NSLog(@"Sort %@, %@", obj, result ? @"success" : [NSString stringWithFormat:@"fail: %@", error]);
            });
        }];
        NSLog(@"");
        
		NSLog(@"Handle Devices Info Begin >>>>");
		handleDevicesInfo();
        NSLog(@"");
        
        NSLog(@"Handle Latest Global Config Begin >>>>");
        handleLatestGlobalConfiguration();
        testLatestGlobalConfiguration();
        NSLog(@"");
	}
	return 0;
}
