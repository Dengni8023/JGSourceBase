//
//  JGSNSDateDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/3/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSNSDateDemoVC.h"

@interface JGSNSDateDemoVC ()

@end

@implementation JGSNSDateDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"NSDate";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#ifdef JGSCategory_NSDate_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" Get Field",
		@[
			JGSDemoTableRowMake(@"Base info", nil, @selector(getDateFieldInfo:)),
			JGSDemoTableRowMake(@"Extension info", nil, @selector(getDateFieldInfo:)),
		])
	];
}

#pragma mark - Action
- (void)getDateFieldInfo:(NSIndexPath *)indexPath {
    
    NSDate *now = [NSDate date];
    switch (indexPath.row) {
        case 0: {
            
            JGSDemoShowConsoleLog(self, @"%04d-%02d-%02d %02d:%02d:%02d-%09d", now.jg_year, now.jg_month, now.jg_day, now.jg_hour, now.jg_minute, now.jg_second, now.jg_nanosecond);
        }
            break;
            
        case 1: {
            
            JGSDemoShowConsoleLog(self, @"isLeapYear: %@", now.jg_isLeapYear ? @"YES": @"NO");
            JGSDemoShowConsoleLog(self, @"isLeapMonth: %@", now.jg_isLeapMonth ? @"YES": @"NO");
        }
            break;
            
        default:
            break;
    }
}

#endif

@end
