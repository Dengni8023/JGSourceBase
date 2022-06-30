//
//  JGSIntegrityCheckResourcesHash.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSIntegrityCheckResourcesHash.h"
#import "JGSBase+JGSPrivate.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation JGSIntegrityCheckResourcesHash

+ (instancetype)shareInstance {
	
	static JGSIntegrityCheckResourcesHash *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

- (id)checkInfoPlistNode:(id)usingObject record:(id)recordObject blackKeys:(NSArray<NSString *> *)blackKeys {
	
	if ([recordObject isKindOfClass:[NSString class]]) {
		
		if (!usingObject) {
			return nil;
		}
		
		NSData *recordData = [[NSData alloc] initWithBase64EncodedString:(NSString *)recordObject options:NSDataBase64DecodingIgnoreUnknownCharacters];
		if (recordData.length == 0) {
			return nil;
		}
		
		NSString *recordValue = [[NSString alloc] initWithData:recordData encoding:NSUTF8StringEncoding];
		if (recordValue.length == 0) {
			return nil;
		}
		
		BOOL checkResult = YES;
		if ([usingObject isKindOfClass:[NSString class]]) {
			checkResult = [[(NSString *)usingObject lowercaseString] isEqualToString:recordValue.lowercaseString];
		}
		else if ([usingObject isKindOfClass:[NSNumber class]]) {
			// 数值类型可以同时为Int、Bool，因此判断NSNumber
			// 注意脚本中bool统一处理为0/1
			checkResult = [[(NSNumber *)usingObject stringValue].lowercaseString isEqualToString:recordValue.lowercaseString];
		}
		else {
			JGSPrivateLog(@"校验未进行 \t%@\nUsing:\t<%@>\nRecord:\t<%@>", NSStringFromClass([usingObject class]), usingObject, recordValue);
			return nil;
		}
		
		if (!checkResult) {
			JGSPrivateLog(@"校验不通过 \t%@\nUsing:\t<%@>\nRecord:\t<%@>", NSStringFromClass([usingObject class]), usingObject, recordValue);
		}
		
		return checkResult ? nil : usingObject;
	}
	else if ([recordObject isKindOfClass:[NSArray class]]) {
		
		NSArray *usingArray = (NSArray *)usingObject;
		NSArray *recordArray = (NSArray *)recordObject;
		if (recordArray.count != usingArray.count) {
			JGSPrivateLog(@"校验不通过 \t%@\nUsing:\t<%@>\nRecord:\t<%@>", NSStringFromClass([usingObject class]), usingObject, recordObject);
			return usingObject;
		}
		
		if (usingArray.count == 0) {
			return nil;
		}
		
		NSMutableArray *unpassInfo = @{}.mutableCopy;
		for (NSInteger i = 0; i < recordArray.count; i++) {
			
			id usingItem = [usingArray objectAtIndex:i];
			id recordItem = [recordArray objectAtIndex:i];
			id result = [self checkInfoPlistNode:usingItem record:recordItem blackKeys:blackKeys];
			if (result) {
				[unpassInfo addObject:result];
			}
		}
		
		return unpassInfo.count > 0 ? unpassInfo : nil;
	}
	else if ([recordObject isKindOfClass:[NSDictionary class]]) {
		
		NSDictionary<NSString *, id> *usingMap = (NSDictionary *)usingObject;
		NSDictionary<NSString *, id> *recordMap = (NSDictionary *)recordObject;
		NSMutableDictionary<NSString *, id> *unpassInfoKeys = @{}.mutableCopy;
		[recordMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull recordVlue, BOOL * _Nonnull stop) {
			
			NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
			if (keyData.length == 0) {
				return;
			}
			
			NSString *recordKey = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
			if (recordKey.length == 0) {
				return;
			}
			
			// 黑名单key不做校验
			if ([blackKeys containsObject:recordKey]) {
				JGSPrivateLog(@"Check Plist Black Key: \t%@", recordKey);
				return;
			}
			
			id usingValue = [usingMap objectForKey:recordKey];
			if (!usingValue) {
				return;
			}
			
			// 下一层黑名单key
			NSMutableArray *nextBlackKeys = @[].mutableCopy;
			for (NSString *blackKey in blackKeys) {
				NSMutableArray *subDirs = [blackKey componentsSeparatedByString:@"."].mutableCopy;
				[subDirs removeObjectAtIndex:0];
				NSString *newKey = [subDirs componentsJoinedByString:@"."];
				if (newKey.length > 0) {
					[nextBlackKeys addObject:newKey];
				}
			}
			
			//SAPPLog("Check Plist Key: \t\(recordKey)")
			id mapItemResult = [self checkInfoPlistNode:usingValue record:recordVlue blackKeys:nextBlackKeys.copy];
			//SAPPLog("Check Plist Key: \t\(recordKey)\nCheck Plist Result:\t\(mapItemResult ?? "pass")")
			if (!mapItemResult) {
				return;
			}
			
			unpassInfoKeys[recordKey] = mapItemResult;
		}];
		
		return unpassInfoKeys.count > 0 ? unpassInfoKeys.copy : nil;
	}
	
	return nil;
}

- (void)checkAPPResourcesHash:(void (^)(NSArray<NSString *> * _Nullable, NSDictionary * _Nullable))completion {
	
	// 内部存在文件读取等耗时操作，所以需要使用异步逻辑处理
	// 文件校验参考 JGSIntegrityCheckRecordResourcesHash.sh 脚本生成校验内容规则进行处理
	
	JGSWeakSelf
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		JGSStrongSelf
		
		// 校验文件
		NSString *hashFileName = [NSString stringWithUTF8String:JGSApplicationIntegrityCheckFileHashFile];
		NSString *hashFilePath = [[NSBundle mainBundle] pathForResource:hashFileName ofType:nil];
		if (![[NSFileManager defaultManager] fileExistsAtPath:hashFilePath]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		JGSPrivateLog(@"应用完整性校验-资源文件校验");
		
		// 获取校验文件Base64字符串内容
		NSString *chechFileContentBase64 = [NSString stringWithContentsOfFile:hashFilePath encoding:NSUTF8StringEncoding error:nil];
		if (chechFileContentBase64.length == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// 校验文件Base64解密
		NSData *chechFileData = [[NSData alloc] initWithBase64EncodedString:chechFileContentBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
		if (chechFileData.length == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// Base64解密后字符串
		NSString *chechFileContent = [[NSString alloc] initWithData:chechFileData encoding:NSUTF8StringEncoding];
		if (chechFileContentBase64.length == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// 校验文件移除混淆头，后进行翻转获取校验文件真实内容
		// 该步骤请与 JGSIntegrityCheckRecordResourcesHash.sh 保持逆过程的一致性
		NSString *hashSalt = [NSString stringWithUTF8String:JGSResourcesCheckFileHashSecuritySalt];
		NSInteger hashSaltLen = [[hashSalt dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed].length;
		NSInteger realCheckContentLength = chechFileContent.length - hashSaltLen * 2;
		if (realCheckContentLength <= 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// 校验文件内容翻转
		NSString *realCheckFileContent = [chechFileContent substringWithRange:NSMakeRange(hashSaltLen, realCheckContentLength)];
		NSMutableString *reversedContent = @"".mutableCopy;
		for (NSInteger i = realCheckFileContent.length; i > 0 ; i--) {
			[reversedContent appendString:[realCheckFileContent substringWithRange:NSMakeRange(i - 1, 1)]];
		}
		realCheckFileContent = reversedContent.copy;
		
		// 检验文件Base64解密
		NSData *realCheckFileJSONData = [[NSData alloc] initWithBase64EncodedString:realCheckFileContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
		if (realCheckFileJSONData.length <= 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// 检验文件JSON解析
		NSDictionary<NSString *, NSString *> *realCheckFileMap = [NSJSONSerialization JSONObjectWithData:realCheckFileJSONData options:NSJSONReadingFragmentsAllowed error:nil];
		if (realCheckFileMap.count == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// 根据校验文件记录的文件、及hash查找资源文件并比对hash
		NSMutableArray<NSString *> *unpassFiles = @[].mutableCopy;
		NSMutableDictionary<NSString *, id> *unpassPlistInfo = @{}.mutableCopy;
		JGSWeakSelf
		[realCheckFileMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull base64FileName, NSString * _Nonnull recordFileHash, BOOL * _Nonnull stop) {
			
			JGSStrongSelf
			// 文件Hash记录空则检查下一文件
			if (recordFileHash.length == 0) {
				return;
			}
			
			// 解析文件名
			NSData *recordNameData = [[NSData alloc] initWithBase64EncodedString:base64FileName options:NSDataBase64DecodingIgnoreUnknownCharacters];
			if (recordNameData.length == 0) {
				return;
			}
			NSString *recordFileName = [[NSString alloc] initWithData:recordNameData encoding:NSUTF8StringEncoding];
			if (recordFileName.length == 0) {
				return;
			}
			
			// Info.plist单独处理
			if ([recordFileName.lowercaseString isEqualToString:@"Info.plist".lowercaseString]) {
				
				JGSPrivateLog(@"应用完整性校验-Info.plist文件内容校验");
				
				// Plist记录Base64内容解密
				NSData *recordPlistData = [[NSData alloc] initWithBase64EncodedString:recordFileHash options:NSDataBase64DecodingIgnoreUnknownCharacters];
				if (recordPlistData.length == 0) {
					return;
				}
				
				// Plist记录内容解析为Dictionary
				NSDictionary *recordPlistMap = [NSJSONSerialization JSONObjectWithData:recordPlistData options:NSJSONReadingFragmentsAllowed error:nil];
				if (![recordPlistMap isKindOfClass:[NSDictionary class]] || recordPlistMap.count == 0) {
					return;
				}
				
				// Plist根结点开始校验，校验方法内部递归校验子节点
				NSDictionary *usingPlist = [[NSBundle mainBundle] infoDictionary];
				NSDictionary *plistResult = [self checkInfoPlistNode:usingPlist record:recordPlistMap blackKeys:self.checkInfoPlistKeyBlacklist];
				if ([plistResult isKindOfClass:[NSDictionary class]] && plistResult.count > 0) {
					[unpassFiles addObject:recordFileName];
					[unpassPlistInfo setDictionary:plistResult];
					JGSPrivateLog(@"校验不通过：%@ =>\n%@)", recordFileName, [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:unpassPlistInfo options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
				}
				
				return;
			}
			
			// 非白名单子目录不做校验
			if (self.checkFileSubDirectoryWhitelist.count > 0 && [recordFileName containsString:@"/"] && [self.checkFileSubDirectoryWhitelist containsObject:recordFileName.stringByDeletingLastPathComponent]) {
				return;
			}
			
			// 文件名黑名单
			if ([self.checkFileNameBlacklist containsObject:recordFileName.lastPathComponent]) {
				return;
			}
			
			// 文件夹黑名单
			if ([self.checkFileDirectoryBlacklist containsObject:recordFileName.stringByDeletingLastPathComponent]) {
				return;
			}
			//for (NSString *blackDir in self.checkFileDirectoryBlacklist) {
			//
			//	NSString *prefixDir = [blackDir stringByAppendingString:@"/"];
			//	NSString *subDir = [NSString stringWithFormat:@"/%@/", blackDir];
			//	NSString *suffixDir = [@"/" stringByAppendingString:blackDir];
			//	if ([recordFileName hasPrefix:prefixDir] || [recordFileName containsString:subDir] || [recordFileName hasSuffix:suffixDir]) {
			//		return;
			//	}
			//}
			
			// 文件扩展名黑名单
			if ([self.checkFileExtesionBlacklist containsObject:recordFileName.pathExtension]) {
				return;
			}
			
			// 文件扩展名黑名单，容错支持多级扩展名
			for (NSString *blackExt in self.checkFileExtesionBlacklist) {
				
				NSString *suffixDir = [@"." stringByAppendingString:blackExt];
				if ([recordFileName hasSuffix:suffixDir]) {
					return;
				}
			}
			
			// 校验文件Hash
			NSString *resPath = [[NSBundle mainBundle] pathForResource:recordFileName ofType:nil];
			if (resPath.length == 0) {
				return;
			}
			
			NSString *usingHash = [self fileHashWithPath:resPath].lowercaseString;
			if ([usingHash.lowercaseString isEqualToString:recordFileHash.lowercaseString]) {
				return;
			}
			
			// 文件Hash校验不通过
			[unpassFiles addObject:recordFileName];
			JGSPrivateLog(@"校验不通过：%@ =>\nUsing:\t<%@>\nRecord:\t<%@>", recordFileName, usingHash, recordFileHash);
		}];
		dispatch_async(dispatch_get_main_queue(), ^{
			completion(unpassFiles.count > 0 ? unpassFiles.copy : nil, unpassPlistInfo.count > 0 ? unpassPlistInfo.copy : nil);
		});
	});
}

- (NSString *)fileHashWithPath:(NSString *)path {
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return nil;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	uint8_t digest[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	
	return output;
}

@end
