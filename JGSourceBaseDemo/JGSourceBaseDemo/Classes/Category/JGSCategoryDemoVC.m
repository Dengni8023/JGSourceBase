//
//  JGSCategoryDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "JGSCategoryDemoVC.h"
// NS
#import "JGSNSArrayDemoVC.h"
#import "JGSNSDataDemoVC.h"
#import "JGSNSDateDemoVC.h"
#import "JGSNSDictionaryDemoVC.h"
#import "JGSNSObjectDemoVC.h"
#import "JGSNSStringDemoVC.h"
#import "JGSNSURLDemoVC.h"
// UI
#import "JGSUIAlertControllerDemoVC.h"

typedef NS_ENUM(NSInteger, JGSNSCategoryRow) {
    JGSNSCategoryRowArray = 0,
    JGSNSCategoryRowData,
    JGSNSCategoryRowDate,
    JGSNSCategoryRowDict,
    JGSNSCategoryRowObject,
    JGSNSCategoryRowString,
    JGSNSCategoryRowURL,
};

typedef NS_ENUM(NSInteger, JGSUICategoryRow) {
    JGSUICategoryRowAlertController = 0,
};

@interface JGSCategoryDemoVC ()

@end

@implementation JGSCategoryDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Category";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" NS",
		@[
            JGSDemoTableRowMake(@"NSArray", nil, @selector(jumpToNSCategoryDemo:)),
            JGSDemoTableRowMake(@"NSData", nil, @selector(jumpToNSCategoryDemo:)),
			JGSDemoTableRowMake(@"NSDate", nil, @selector(jumpToNSCategoryDemo:)),
			JGSDemoTableRowMake(@"NSDictionary", nil, @selector(jumpToNSCategoryDemo:)),
			JGSDemoTableRowMake(@"NSObject", nil, @selector(jumpToNSCategoryDemo:)),
			JGSDemoTableRowMake(@"NSString", nil, @selector(jumpToNSCategoryDemo:)),
			JGSDemoTableRowMake(@"NSURL", nil, @selector(jumpToNSCategoryDemo:)),
		]),
		JGSDemoTableSectionMake(@" UI",
		@[
			JGSDemoTableRowMake(@"UIAlertController", nil, @selector(jumpToUICategoryDemo:)),
		]),
	];
}

#pragma mark - Action - NS
- (void)jumpToNSCategoryDemo:(NSIndexPath *)indexPath {
    
    switch ((JGSNSCategoryRow)indexPath.row) {
        case JGSNSCategoryRowArray: {
            
            JGSNSArrayDemoVC *vcT = [[JGSNSArrayDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
            
        case JGSNSCategoryRowData: {
            
            JGSNSDataDemoVC *vcT = [[JGSNSDataDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
            
        case JGSNSCategoryRowDate: {
            
            JGSNSDateDemoVC *vcT = [[JGSNSDateDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
            
        case JGSNSCategoryRowDict: {
            
            JGSNSDictionaryDemoVC *vcT = [[JGSNSDictionaryDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
            
        case JGSNSCategoryRowObject: {
            
            JGSNSObjectDemoVC *vcT = [[JGSNSObjectDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
            
        case JGSNSCategoryRowString: {
            
            JGSNSStringDemoVC *vcT = [[JGSNSStringDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
            
        case JGSNSCategoryRowURL: {
            
            JGSNSURLDemoVC *vcT = [[JGSNSURLDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
    }
}

- (void)jumpToUICategoryDemo:(NSIndexPath *)indexPath {
    
    switch ((JGSUICategoryRow)indexPath.row) {
        case JGSUICategoryRowAlertController: {
            
            JGSUIAlertControllerDemoVC *vcT = [[JGSUIAlertControllerDemoVC alloc] init];
            [self.navigationController pushViewController:vcT animated:YES];
        }
            break;
    }
}

#pragma mark - End

@end
