//
//  JGSNSStringDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/3/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSNSStringDemoVC.h"

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
		])
	];
}

#pragma mark - Action
- (void)string2URLString:(NSIndexPath *)indexPath {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
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

#endif

@end
