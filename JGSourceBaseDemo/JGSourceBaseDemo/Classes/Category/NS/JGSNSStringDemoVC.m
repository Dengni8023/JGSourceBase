//
//  JGSNSStringDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/3/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSNSStringDemoVC.h"
@import JGSourceBase;

@interface JGSNSStringDemoVC ()

@end

@implementation JGSNSStringDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"NSString";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#ifdef JGSCategory_NSString_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" URL",
		@[
			JGSDemoTableRowMake(@"URL Encode", nil, @selector(string2URLString:)),
			JGSDemoTableRowMake(@"URL String", nil, @selector(string2URLString:)),
            JGSDemoTableRowMake(@"URL String", nil, @selector(stringHexSwap:)),
		])
	];
}

#pragma mark - Action
- (void)string2URLString:(NSIndexPath *)indexPath {
    
    [JGSLogger enableLogWithMode:JGSLogModeFunc level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            JGSWeakSelf
            NSArray<NSString *> *oriStrs = @[@":", @"#", @"[", @"]", @"@", @"!", @"$", @"&", @"'", @"(", @")", @"*", @"+", @",", @";", @"="];
            [oriStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSStrongSelf
                JGSDemoShowConsoleLog(self, @"Encode %@ -> %@", obj, obj.jg_URLEncodeString);
            }];
        }
            break;
            
        case 1: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSDemoShowConsoleLog(self, @"\n%@\n%@", urlStr, urlStr.jg_URLString);
            
            urlStr = @"https://www.baidu.com/search&key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSDemoShowConsoleLog(self, @"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        default:
            break;
    }
}

- (void)stringHexSwap:(NSIndexPath *)indexPath {
    
    JGSLog(@"%@", @"0x7248".jg_hexToString);
    JGSLog(@"%@", @"0X7248".jg_hexToString.jg_hexString);
    
    JGSLog(@"%@", @"6b6132686a6732653136386873366734".jg_hexToString); // ka2hjg2e168hs6g4
    JGSLog(@"%@", @"ka2hjg2e168hs6g4".jg_hexString);
    
    NSInteger i = 0;
    while (i++ < 20) {
        NSString *hex = [@"ka2hjg2e168hs6g4" jg_hexString:JGSStringRandomCase];
        JGSLog(@"%@", hex);
        JGSLog(@"%@", hex.jg_hexToString); // ka2hjg2e168hs6g4
        JGSLog();
    }
    
    JGSLog(@"%@", @"63766231327876627835766234786166".jg_hexToString); // cvb12xvbx5vb4xaf
    JGSLog(@"%@", @"cvb12xvbx5vb4xaf".jg_hexString);
    
    JGSLog(@"%@", @"6b6132686a6732653136384853364734".jg_hexToString); // ka2hjg2e168HS6G4
    JGSLog(@"%@", @"ka2hjg2e168HS6G4".jg_hexString);
    JGSLog(@"%@", @"43564231327856427835766234786166".jg_hexToString); // CVB12xVBx5vb4xaf
    JGSLog(@"%@", @"CVB12xVBx5vb4xaf".jg_hexString);
    
    NSData *data = [@"CVB12xVBx5vb4xaf" dataUsingEncoding:NSUTF8StringEncoding];
    JGSLog(@"%@", data);
    JGSLog(@"%@", data.jg_hex.jg_hexToData);
}

#endif

@end
