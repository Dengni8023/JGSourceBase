//
//  main.m
//  MacFileHandler
//
//  Created by 梅继高 on 2021/1/12.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *FileHandlerRootDir = @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/MacFileHandler/Resources";

void handleDevicesInfo(void) {
    
    NSString *filePath = [FileHandlerRootDir stringByAppendingPathComponent:@"iOSDeviceList.json"];
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
    
    NSData *newJson = [NSJSONSerialization dataWithJSONObject:models options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:nil];
    NSString *newPath = @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSourceBase/Base/Resources/iOSDeviceList-Sorted.json";
    [newJson writeToFile:newPath options:(NSDataWritingAtomic) error:nil];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        handleDevicesInfo();
    }
    return 0;
}
