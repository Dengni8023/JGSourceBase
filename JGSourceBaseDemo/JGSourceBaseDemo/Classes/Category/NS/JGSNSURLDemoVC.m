//
//  JGSNSURLDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/3/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSNSURLDemoVC.h"

@interface JGSNSURLDemoVC ()

@end

@implementation JGSNSURLDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"NSURL";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#ifdef JGSCategory_NSURL_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" Query",
		@[
			JGSDemoTableRowMake(@"URL queries", nil, @selector(getURLQuery:)),
			JGSDemoTableRowMake(@"URL query for key", nil, @selector(getURLQuery:)),
		])
	];
}

#pragma mark - Action
- (void)getURLQuery:(NSIndexPath *)indexPath {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=&key2=Key&key3= &key4=Key4&key1=&key1=好";
            NSURL *URL = urlStr.jg_URL;
            JGSDemoShowConsoleLog(self, @"\n%@", [URL jg_queryParams]);
            
            urlStr = @"https://www.baidu.com/search?key1=%E4%BD%A0%E5%A5%BD";
            URL = urlStr.jg_URL;
            JGSDemoShowConsoleLog(self, @"\n%@", [URL jg_queryParams]);
        }
            break;
            
        case 1: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你 Hello 好%5B中括号%5D";
            NSURL *URL = urlStr.jg_URL;
            JGSDemoShowConsoleLog(self, @"\nkey1: %@", [URL jg_queryForKey:@"key1"]);
        }
            break;
            
        default:
            break;
    }
}

#endif

@end
