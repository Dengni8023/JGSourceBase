//
//  JGSCategoryDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "JGSCategoryDemoVC.h"
// NS
#import "JGSNSDictionaryDemoVC.h"
#import "JGSNSDateDemoVC.h"
#import "JGSNSObjectDemoVC.h"
#import "JGSNSStringDemoVC.h"
#import "JGSNSURLDemoVC.h"
// UI
#import "JGSUIAlertControllerDemoVC.h"

#ifdef JGS_Category
@interface JGSCategoryDemoVC ()

@end

@implementation JGSCategoryDemoVC

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        JGSDemoTableSectionMake(@" NS",
                                @[
                                    JGSDemoTableRowMake(@"NSDate", nil, @selector(jumpToDateDemo:)),
                                    JGSDemoTableRowMake(@"NSDictionary", nil, @selector(jumpToDictionaryDemo:)),
                                    JGSDemoTableRowMake(@"NSObject", nil, @selector(jumpToObjectDemo:)),
                                    JGSDemoTableRowMake(@"NSString", nil, @selector(jumpToStringDemo:)),
                                    JGSDemoTableRowMake(@"NSURL", nil, @selector(jumpToURLDemo:)),
                                ]),
        JGSDemoTableSectionMake(@" UI",
                                @[
                                    JGSDemoTableRowMake(@"UIAlertController", nil, @selector(jumpToCategoryAlert:)),
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Category";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Action - NS
- (void)jumpToDateDemo:(NSIndexPath *)indexPath {
    
#ifdef JGSCategory_NSDictionary
    JGSNSDateDemoVC *vcT = [[JGSNSDateDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(self, @"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToDictionaryDemo:(NSIndexPath *)indexPath {
    
#ifdef JGSCategory_NSDictionary
    JGSNSDictionaryDemoVC *vcT = [[JGSNSDictionaryDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(self, @"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToObjectDemo:(NSIndexPath *)indexPath {
    
#ifdef JGSCategory_NSDictionary
    JGSNSObjectDemoVC *vcT = [[JGSNSObjectDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(self, @"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToStringDemo:(NSIndexPath *)indexPath {
    
#ifdef JGSCategory_NSDictionary
    JGSNSStringDemoVC *vcT = [[JGSNSStringDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(self, @"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToURLDemo:(NSIndexPath *)indexPath {
    
#ifdef JGSCategory_NSDictionary
    JGSNSURLDemoVC *vcT = [[JGSNSURLDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(self, @"Unimplemented or dependencies not founded !");
#endif
}

#pragma mark - Action - UI
- (void)jumpToCategoryAlert:(NSIndexPath *)indexPath {
    
#ifdef JGSCategory_UIAlertController
    JGSUIAlertControllerDemoVC *vcT = [[JGSUIAlertControllerDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(self, @"Unimplemented or dependencies not founded !");
#endif
}

#pragma mark - Category - NSDate
- (void)jumpToCategoryDate {
    
#ifdef JGSCategory_UIAlertController
    JGSNSDateDemoVC *vcT = [[JGSNSDateDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(self, @"Unimplemented or dependencies not founded !");
#endif
}

#pragma mark - End

@end
#endif
