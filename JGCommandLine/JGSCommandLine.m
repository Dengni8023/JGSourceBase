//
//  JGSCommandLine.m
//  JGCommandLine
//
//  Created by 梅继高 on 2022/11/1.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSCommandLine.h"

@implementation NSData (JGSCommandLine)

- (NSData *)JGSCommandLine_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    
    if (self.length == 0) {
        return nil;
    }
    
    if (options == kNilOptions) {
        options = kCCOptionPKCS7Padding;
    }
    
    NSCAssert(keyLength == kCCKeySizeAES128 || keyLength == kCCKeySizeAES192 || keyLength == kCCKeySizeAES256, @"The keyLength of AES must be (%@、%@、%@)", @(kCCKeySizeAES128), @(kCCKeySizeAES192), @(kCCKeySizeAES256));
    NSCAssert(operation == kCCEncrypt || operation == kCCDecrypt, @"The operation of AES must be (%@、%@)", @(kCCEncrypt), @(kCCDecrypt));
    NSCAssert(key.length == keyLength, @"The key length of AES-%@ must be %@", @(keyLength * 8), @(keyLength));
    if (options & kCCOptionECBMode) {
        // 屏蔽ECB校验IV，系统能够正常加解密
        //NSCAssert(iv.length != 0, @"The AES-CBC mode must have iv params");
    }
    
    NSUInteger dataLength = self.length;
    void const *contentBytes = self.bytes;
    void const *keyBytes = [key dataUsingEncoding:NSUTF8StringEncoding].bytes;
    
    // 初始偏移向量，默认全置零，避免iv长度不符合规范情况导致无法解析
    // 便宜向量长度为块大小 BlockSize
    char ivBytes[kCCBlockSizeAES128 + 1];
    memset(ivBytes, 0, sizeof(ivBytes));
    if (iv.length > 0) {
        [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    }
    
    size_t operationSize = dataLength + kCCBlockSizeAES128; // 密文长度 <= 明文长度 + BlockSize
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    
    size_t actualOutSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES, options, keyBytes, keyLength, ivBytes, contentBytes, dataLength, operationBytes, operationSize, &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // operationBytes 自动释放
        NSData *cryptData = [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
        return cryptData;
    }
    
    free(operationBytes); operationBytes = NULL;
    
    return nil;
}

@end

@implementation JGSCommandLine

#pragma mark - Sort
+ (void)sortPlistFile:(NSString *)path rewrite:(BOOL)rewrite completion:(void (^)(id _Nullable contentDictOrArray, BOOL success))completion {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        completion ? completion(nil, NO) : nil;
        return;
    }
    
    // Plist文件读出为字典再写回，即完成Key升序整理
    BOOL result = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dict != nil) {
        if (rewrite) {
            result = [dict writeToFile:path atomically:YES];
        }
        completion ? completion(dict, result) : nil;
        return;
    }
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    if (array != nil) {
        if (rewrite) {
            result = [array writeToFile:path atomically:YES];
        }
        completion ? completion(array, result) : nil;
        return;
    }
    
    completion ? completion(nil, result) : nil;
}

+ (void)sortJSONFile:(NSString *)path rewrite:(BOOL)rewrite completion:(void (^)(NSString * _Nullable contentJSON, BOOL success, NSError * _Nullable error))completion {
    
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        completion ? completion(nil, NO, nil) : nil;
        return;
    }
    
    // 读取文件 Data
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:kNilOptions error:&error];
    if (!data || error) {
        completion ? completion(nil, NO, error) : nil;
        return;
    }
    
    // 文件 Data 转 JSON 对象
    error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!jsonObj || error) {
        completion ? completion(nil, NO, error) : nil;
        return;
    }
    
    // JSON 对象格式化整理
    error = nil;
    data = [NSJSONSerialization dataWithJSONObject:jsonObj options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:&error];
    if (data.length == 0 || error) {
        completion ? completion(nil, NO, error) : nil;
        return;
    }
    
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    content = [content stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    content = [content stringByReplacingOccurrencesOfString:@"\" :" withString:@"\":"];
    content = [content stringByAppendingString:@"\n"]; // 文件结束增加换行
    
    error = nil;
    BOOL result = [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    completion ? completion(content, result, error) : nil;
}

#pragma mark - AES
+ (NSData *)aes256EncryptData:(NSData *)fileData fileName:(NSString *)fileName {
    
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
    
    return [fileData JGSCommandLine_AESOperation:kCCEncrypt keyLength:keyLen key:key iv:iv options:kCCOptionPKCS7Padding];
}

#pragma mark - main
/// 代码仓库本地存放路径地址
static NSString * const JGSourceRepoLocationDirectory = @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase";
+ (void)sortPlistFiles {
    
    // Plist 文件整理
    NSArray<NSString *> *sortFiles = @[
        @"JGSourceBase/Info.plist",
        @"JGSourceBase/PrivacyInfo.xcprivacy",
        @"JGSourceBase.bundle/Info.plist",
        @"JGSourceBaseDemo/Info.plist",
        @"JGSourceBaseDemo/JGSourceBaseDemo/Info.plist",
    ];
    
    [sortFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *filePath = [JGSourceRepoLocationDirectory stringByAppendingPathComponent:obj];
        [JGSCommandLine sortPlistFile:filePath rewrite:YES completion:^(id  _Nullable contentDictOrArray, BOOL success) {
            NSLog(@"[Sorted: %@] %@", success ? @"success" : @"fail", obj);
        }];
    }];
}

+ (void)sortJSONFiles {
    
    // JSON 文件整理
    NSArray<NSString *> *sortFiles = @[
        @"JGSourceBase/JGSDevice/Resources/JGSiOSDeviceList-Origin.json"
    ];
    
    [sortFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *filePath = [JGSourceRepoLocationDirectory stringByAppendingPathComponent:obj];
        [JGSCommandLine sortJSONFile:filePath rewrite:YES completion:^(NSString * _Nullable contentJSON, BOOL success, NSError * _Nullable error) {
            NSLog(@"[Sorted: %@] %@%@", success ? @"success" : @"fail", obj, error ? [NSString stringWithFormat:@", error: %@", error] : @"");
        }];
    }];
}

+ (void)sortAndAESEncryptDeviceListData {
    
    // JGSDevice 资源文件处理
    NSString *deviceSourceDir = [JGSourceRepoLocationDirectory stringByAppendingPathComponent:@"JGSourceBase/JGSDevice/Resources"];
    NSString *filePath = [deviceSourceDir stringByAppendingPathComponent:@"JGSiOSDeviceList-Origin.json"];
    
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
    NSString *jsonPath = [deviceSourceDir stringByAppendingPathComponent:destFileName];
    BOOL sortResult = [sortedData writeToFile:jsonPath options:(NSDataWritingAtomic) error:nil];
    
    NSLog(@"[Formatted %@] %@", sortResult ? @"success" : @"fail", [jsonPath stringByReplacingOccurrencesOfString:[JGSourceRepoLocationDirectory stringByAppendingString:@"/"] withString:@""]);
    
    // AES加密：整理后源JSON文件
    NSString *secFileName = [destFileName stringByAppendingPathExtension:@"sec"];
    NSData *secData = [JGSCommandLine aes256EncryptData:sortedData fileName:secFileName] ?: [NSData data];
    NSString *secPath = [deviceSourceDir stringByAppendingPathComponent:secFileName];
    BOOL aesResult = [secData writeToFile:secPath options:(NSDataWritingAtomic) error:nil];
    
    NSLog(@"[AES Encrypt %@] %@", aesResult ? @"success" : @"fail", [secPath stringByReplacingOccurrencesOfString:[JGSourceRepoLocationDirectory stringByAppendingString:@"/"] withString:@""]);
}

@end
