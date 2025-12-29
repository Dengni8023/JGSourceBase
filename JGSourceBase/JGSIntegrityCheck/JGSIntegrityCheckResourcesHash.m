//
//  JGSIntegrityCheckResourcesHash.m
//  JGSourceBase
//
//  Created by 梅继高 on 2022/5/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSIntegrityCheckResourcesHash.h"
#import "JGSBase+Private.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSString+JGSBase.h"
#import "NSData+JGSBase.h"
#import "JGSEncryption.h"

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
	
    if ([recordObject isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary<NSString *, id> *usingMap = (NSDictionary *)usingObject;
        NSDictionary<NSString *, id> *recordMap = (NSDictionary *)recordObject;
        NSMutableDictionary<NSString *, id> *unpassInfoKeys = @{}.mutableCopy;
        [recordMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull recordKey, id  _Nonnull recordVlue, BOOL * _Nonnull stop) {
            
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
            
            //JGSPrivateLog("Check Plist Key: \t\(recordKey)")
            id mapItemResult = [self checkInfoPlistNode:usingValue record:recordVlue blackKeys:nextBlackKeys.copy];
            //JGSPrivateLog(@"Check Plist: <%@: %@>", recordKey, mapItemResult ?: @"pass")
            if (!mapItemResult) {
                return;
            }
            
            unpassInfoKeys[recordKey] = mapItemResult;
        }];
        
        return unpassInfoKeys.count > 0 ? unpassInfoKeys.copy : nil;
    } else if ([recordObject isKindOfClass:[NSArray class]]) {
        
        NSArray *usingArray = (NSArray *)usingObject;
        if (usingArray.count == 0) {
            return nil;
        }
        
        NSArray *recordArray = (NSArray *)recordObject;
        if (recordArray.count != usingArray.count) {
            JGSPrivateLog(@"校验不通过 \t%@\nUsing:\t<%@>\nRecord:\t<%@>", NSStringFromClass([usingObject class]), usingObject, recordObject);
            return usingObject;
        }
        
        NSMutableArray *unpassInfo = @[].mutableCopy;
        for (NSInteger i = 0; i < recordArray.count; i++) {
            
            id usingItem = [usingArray objectAtIndex:i];
            id recordItem = [recordArray objectAtIndex:i];
            id result = [self checkInfoPlistNode:usingItem record:recordItem blackKeys:blackKeys];
            if (result) {
                [unpassInfo addObject:result];
            }
        }
        
        return unpassInfo.count > 0 ? unpassInfo : nil;
    } else {
        
        if (!usingObject || !recordObject) {
            return nil;
        }
        
        BOOL checkResult = [usingObject isKindOfClass:[recordObject class]];
        if (checkResult) {
            if ([usingObject isKindOfClass:NSString.class]) {
                checkResult = [(NSString *)usingObject isEqualToString:(NSString *)recordObject];
            }
            else if ([usingObject isKindOfClass:[NSNumber class]]) {
                // 数值类型可以同时为Int、Bool，因此判断NSNumber
                checkResult = [[(NSNumber *)usingObject stringValue].lowercaseString isEqualToString:[(NSNumber *)recordObject stringValue].lowercaseString];
            } else {
                checkResult = [usingObject isEqual:recordObject];
            }
        }
        
        if (!checkResult) {
            JGSPrivateLog(@"校验不通过 \t%@\nUsing:\t<%@>\nRecord:\t<%@>", NSStringFromClass([usingObject class]), usingObject, recordObject);
        }
        
        return checkResult ? nil : usingObject;
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
		NSString *hashFileName = [NSString stringWithUTF8String:JGSAppIntegrityCheckFile];
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
        NSData *chechFileData = [chechFileContentBase64 jg_base64DecodeData];
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
		NSString *hashSalt = [[NSString stringWithUTF8String:JGSAppIntegrityCheckFile] stringByDeletingPathExtension];
        NSString *headerSalt = [hashSalt jg_base64EncodeString];
        NSMutableString *saltRev = @"".mutableCopy;
        for (NSInteger i = headerSalt.length; i > 0 ; i--) {
            [saltRev appendString:[headerSalt substringWithRange:NSMakeRange(i - 1, 1)]];
        }
        headerSalt = headerSalt.jg_sha256String;
        NSString *tailSalt = saltRev.jg_sha256String;
		NSInteger realCheckContentLength = chechFileContent.length - headerSalt.length - tailSalt.length;
		if (realCheckContentLength <= 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// 校验文件内容翻转
		NSString *realCheckFileContent = [chechFileContent substringWithRange:NSMakeRange(headerSalt.length, realCheckContentLength)];
		NSMutableString *reversedContent = @"".mutableCopy;
		for (NSInteger i = realCheckFileContent.length; i > 0 ; i--) {
			[reversedContent appendString:[realCheckFileContent substringWithRange:NSMakeRange(i - 1, 1)]];
		}
		realCheckFileContent = reversedContent.copy;
		
		// 检验文件Base64解密
        NSData *realCheckFileJSONData = [realCheckFileContent jg_base64DecodeData];
		if (realCheckFileJSONData.length <= 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil);
			});
			return;
		}
		
		// 检验文件JSON解析
		NSDictionary<NSString *, id> *realCheckFileMap = [NSJSONSerialization JSONObjectWithData:realCheckFileJSONData options:kNilOptions error:nil];
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
        [realCheckFileMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull base64FileName, id _Nonnull recordContent, BOOL * _Nonnull stop) {
            
			JGSStrongSelf
            NSString *recordFileHash = nil;
            NSDictionary<NSString *, id> *recordPlistMap = nil;
            if ([recordContent isKindOfClass:NSString.class]) {
                // 文件Hash记录空则检查下一文件
                recordFileHash = (NSString *)recordContent;
            } else if([recordContent isKindOfClass:NSDictionary.class]) {
                // Info.plist文件记录
                recordPlistMap = (NSDictionary<NSString *, id> *)recordContent;
            } else {
                return;
            }
            
			// 解析文件名
            NSData *recordNameData = [base64FileName jg_base64DecodeData];
			if (recordNameData.length == 0) {
				return;
			}
			NSString *recordFileName = [[NSString alloc] initWithData:recordNameData encoding:NSUTF8StringEncoding];
			if (recordFileName.length == 0) {
				return;
			}
			
			// Info.plist单独处理
			if ([recordFileName.lowercaseString isEqualToString:@"Info.plist".lowercaseString] && recordPlistMap.count > 0) {
				
				JGSPrivateLog(@"应用完整性校验-Info.plist文件内容校验");
				
				// Plist根结点开始校验，校验方法内部递归校验子节点
				NSDictionary *usingPlist = [[NSBundle mainBundle] infoDictionary];
				NSDictionary *plistResult = [self checkInfoPlistNode:usingPlist record:recordPlistMap blackKeys:self.checkInfoPlistKeyBlacklist];
				if ([plistResult isKindOfClass:[NSDictionary class]] && plistResult.count > 0) {
					[unpassFiles addObject:recordFileName];
					[unpassPlistInfo setDictionary:plistResult];
					JGSPrivateLog(@"校验不通过：%@ =>\n%@)", recordFileName, [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:unpassPlistInfo options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:nil] encoding:NSUTF8StringEncoding]);
				}
                
				return;
			}
            
            // 文件Hash记录空则检查下一文件
            if (recordFileHash.length == 0) {
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
			
			NSString *usingHash = [JGSEncryption sha256WithFile:resPath].lowercaseString;
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

@end
