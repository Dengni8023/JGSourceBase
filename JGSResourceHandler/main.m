//
//  main.m
//  JGSResourceHandler
//
//  Created by 梅继高 on 2022/4/13.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+JGSAES.h"

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
static NSString *JGSDeviceSourceDir = @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSDevice/Resources";
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
	
	NSString *destFileName = @"JGSiOSDeviceList.json.sec";
	NSString *newPath = [JGSDeviceSourceDir stringByAppendingPathComponent:destFileName];
	
	NSData *sortedData = [NSJSONSerialization dataWithJSONObject:models options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:nil];
	sortedData = aesEncryptData(sortedData, destFileName) ?: [NSData data];
	
	[sortedData writeToFile:newPath options:(NSDataWritingAtomic) error:nil] ? NSLog(@"写入成功") : NSLog(@"写入失败");
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		
		NSLog(@"Handle Devices Info Begin >>>>");
		handleDevicesInfo();
		NSLog(@"Handle Devices Info End >>>>");
	}
	return 0;
}
