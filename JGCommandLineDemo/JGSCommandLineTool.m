//
//  JGSCommandLineTool.m
//  JGCommandLineDemo
//
//  Created by 梅继高 on 2022/11/1.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSCommandLineTool.h"

@implementation NSData (JGSCommandLineTool)

- (NSData *)JGSCommandLine_AESOperation:(CCOperation)operation keyLength:(size_t)keyLength key:(NSString *)key iv:(NSString *)iv options:(CCOptions)options {
    
    if (self == nil) {
        return nil;
    }
    
    NSCAssert(keyLength == kCCKeySizeAES128 || keyLength == kCCKeySizeAES192 || keyLength == kCCKeySizeAES256, @"The keyLength of AES must be (%@、%@、%@)", @(kCCKeySizeAES128), @(kCCKeySizeAES192), @(kCCKeySizeAES256));
    NSCAssert(operation == kCCEncrypt || operation == kCCDecrypt, @"The operation of AES must be (%@、%@)", @(kCCEncrypt), @(kCCDecrypt));
    NSCAssert(key.length == keyLength, @"The key length of AES-%@ must be %@", @(keyLength * 8), @(keyLength));
    
    NSUInteger dataLength = self.length;
    void const *contentBytes = self.bytes;
    void const *keyBytes = [key dataUsingEncoding:NSUTF8StringEncoding].bytes;
    
    // 初始偏移向量，默认全置零，避免iv长度不符合规范情况导致无法解析
    // 便宜向量长度为块大小 BlockSize
    char ivBytes[kCCBlockSizeAES128 + 1];
    memset(ivBytes, 0, sizeof(ivBytes));
    [iv getCString:ivBytes maxLength:sizeof(ivBytes) encoding:NSUTF8StringEncoding];
    
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

@implementation JGSCommandLineTool

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
+ (NSData *)aes256EncryptData:(NSData *)fileData fileName:(NSString *)fileName version:(NSString *)version {
    
    if (fileData.length == 0 || fileName.length == 0) {
        return nil;
    }
    
    size_t keyLen = kCCKeySizeAES256;
    size_t blockSize = kCCBlockSizeAES128;
    
    NSString *key = fileName;
    if (version.length == 0) {
        while (key.length < keyLen) {
            key = [key stringByAppendingString:key];
        }
    }
    else {
        // 2022-11-10修改：加密规则变化，修改信息Commit：
        // Commit ID: 044f0e75684a4b8db57d6cf840bd8beddd541381
        // Commit Info: AES加解密key/iv优化    044f0e7    Dengni8023 <945835664@qq.com>    2022年11月10日 09:05
        while ([[key dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed].length < keyLen) {
            key = [key stringByAppendingString:key];
        }
        key = [[key dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
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
        @"JGSourceBase.bundle/Info.plist",
        @"JGSourceBaseDemo/Info.plist",
        @"JGSourceBaseDemo/JGSourceBaseDemo/Info.plist",
    ];
    
    [sortFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *filePath = [JGSourceRepoLocationDirectory stringByAppendingPathComponent:obj];
        [JGSCommandLineTool sortPlistFile:filePath rewrite:YES completion:^(id  _Nullable contentDictOrArray, BOOL success) {
            NSLog(@"[Sorted: %@] %@", success ? @"success" : @"fail", obj);
        }];
    }];
}

+ (void)sortJSONFiles {
    
    // JSON 文件整理
    NSArray<NSString *> *sortFiles = @[
    ];
    
    [sortFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *filePath = [JGSourceRepoLocationDirectory stringByAppendingPathComponent:obj];
        [JGSCommandLineTool sortJSONFile:filePath rewrite:YES completion:^(NSString * _Nullable contentJSON, BOOL success, NSError * _Nullable error) {
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
    NSArray<NSString *> *versions = @[@"", @"20221110"];
    [versions enumerateObjectsUsingBlock:^(NSString * _Nonnull version, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *secFileName = [destFileName stringByAppendingPathExtension:@"sec"];
        if (version.length > 0) {
            secFileName = [destFileName stringByAppendingFormat:@"-v%@.sec", version];
        }
        
        NSData *secData = [JGSCommandLineTool aes256EncryptData:sortedData fileName:secFileName version:version] ?: [NSData data];
        NSString *secPath = [deviceSourceDir stringByAppendingPathComponent:secFileName];
        BOOL aesResult = [secData writeToFile:secPath options:(NSDataWritingAtomic) error:nil];
        
        NSLog(@"[AES Encrypt %@] %@", aesResult ? @"success" : @"fail", [secPath stringByReplacingOccurrencesOfString:[JGSourceRepoLocationDirectory stringByAppendingString:@"/"] withString:@""]);
    }];
}

+ (void)sortAndBase64EncryptGlobalConfiguration {
    
    NSString *fileName = @"LatestGlobalConfiguration.json";
    NSString *filePath = [JGSourceRepoLocationDirectory stringByAppendingPathComponent:fileName];
    [self sortJSONFile:filePath rewrite:YES completion:^(NSString * _Nullable contentJSON, BOOL success, NSError * _Nullable error) {
        
        NSData *sortedData = [contentJSON dataUsingEncoding:NSUTF8StringEncoding];
        if (contentJSON.length == 0 || error != nil || sortedData.length == 0) {
            return;
        }
        
        // 配置文件Base64加密
        // Baes64替换规则：同时从首尾遍历，每xx位字符串块首尾替换
        NSMutableString *base64String = [sortedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed].mutableCopy;
        NSInteger stringLen = base64String.length;
        NSInteger blockSize = 5;
        for (NSInteger i = 0; i < (stringLen / blockSize) / 2; i++) {
            NSRange headrange = NSMakeRange(i * blockSize, blockSize);
            NSString *headStr = [base64String substringWithRange:headrange];
            NSRange tailRange = NSMakeRange(stringLen - (i + 1) * blockSize, blockSize);
            NSString *tailStr = [base64String substringWithRange:tailRange];
            [base64String replaceCharactersInRange:headrange withString:tailStr];
            [base64String replaceCharactersInRange:tailRange withString:headStr];
        }
        
        NSString *secPath = [filePath stringByAppendingPathExtension:@"sec"];
        [base64String writeToFile:secPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"[Base64 Encrypt and swap %@] %@", base64String.length > 0 ? @"success" : @"fail", [secPath stringByReplacingOccurrencesOfString:[JGSourceRepoLocationDirectory stringByAppendingString:@"/"] withString:@""]);
    }];
}

+ (void)globalConfigurationBase64Decrypt {
    
    NSString *filePath = [JGSourceRepoLocationDirectory stringByAppendingPathComponent:@"LatestGlobalConfiguration.json.sec"];
    NSData *jsonData = [[NSFileManager defaultManager] fileExistsAtPath:filePath] ? [NSData dataWithContentsOfFile:filePath] : nil;
    if (jsonData.length == 0) {
        return;
    }
    
    // 配置文件Base64解密
    // Baes64替换规则：同时从首尾遍历，每xx位字符串块首尾替换
    NSMutableString *base64String = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding].mutableCopy;
    NSInteger stringLen = base64String.length;
    NSInteger blockSize = 5;
    for (NSInteger i = 0; i < (stringLen / blockSize) / 2; i++) {
        NSRange headrange = NSMakeRange(i * blockSize, blockSize);
        NSString *headStr = [base64String substringWithRange:headrange];
        NSRange tailRange = NSMakeRange(stringLen - (i + 1) * blockSize, blockSize);
        NSString *tailStr = [base64String substringWithRange:tailRange];
        [base64String replaceCharactersInRange:headrange withString:tailStr];
        [base64String replaceCharactersInRange:tailRange withString:headStr];
    }
    
    NSLog(@"%s %@", __PRETTY_FUNCTION__, base64String);
    NSData *originData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSError *error = nil;
    NSDictionary *instance = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:originData options:kNilOptions error:&error];
    if (error != nil) {
        //JGSPrivateLog(@"%@", error);
    }
    
    NSLog(@"[Base64 Decrypt and swap %@] %@", instance.count > 0 ? @"success" : @"fail", [filePath stringByReplacingOccurrencesOfString:[JGSourceRepoLocationDirectory stringByAppendingString:@"/"] withString:@""]);
    if (instance.count > 0) {
        NSLog(@"%@", instance);
        NSLog(@"%@", [[NSString alloc] initWithData:originData encoding:NSUTF8StringEncoding]);
    }
}

@end
