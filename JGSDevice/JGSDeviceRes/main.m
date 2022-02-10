//
//  main.m
//  JGSDeviceRes
//
//  Created by 梅继高 on 2022/2/10.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *FileHandlerProjectDir = @"/Users/meijigao/Desktop/Git•GitHub/Dengni8023/JGSourceBase/JGSDevice";
static NSString *FileHandlerRootPath = @"JGSDeviceRes";

void handleDevicesInfo(void) {
    
    NSString *filePath = [[FileHandlerProjectDir stringByAppendingPathComponent:FileHandlerRootPath] stringByAppendingPathComponent:@"iOSDeviceList.json"];
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
    NSString *newPath = [FileHandlerProjectDir stringByAppendingPathComponent:@"JGSDevice/iOSDeviceList.json"];
    [newJson writeToFile:newPath options:(NSDataWritingAtomic) error:nil] ? NSLog(@"写入成功") : NSLog(@"写入失败");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Handle Devices Info Begin >>>>");
        handleDevicesInfo();
        NSLog(@"Handle Devices Info End >>>>");
    }
    return 0;
}
