//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "ViewController.h"
#import "JGSCategoryDemoViewController.h"
#import "JGSHUDDemoViewController.h"
#import "JGSKeyboardDemoViewController.h"
#import "JGSEncryptionDemoViewController.h"
#import <AdSupport/ASIdentifierManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        // Section Base
        JGSDemoTableSectionMake(@" Base组件基础",
                                @[
                                    JGSDemoTableRowMakeSelector(@"调试日志控制-Alert扩展", @selector(showLogModeList))
                                ]),
        // Section Category扩展
        JGSDemoTableSectionMake(@" Category",
                                @[
                                    JGSDemoTableRowMakeSelector(@"NSDate", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"NSDictionary", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"NSObject", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"NSString", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"NSURL", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"UIAlertController", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"UIApplication", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"UIColor", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"UIImage", @selector(jumpToCategoryDemo)),
                                ]),
        // Section 扩展功能
        JGSDemoTableSectionMake(@" Other",
                                @[
                                    JGSDemoTableRowMakeSelector(@"DataStorage Demo", @selector(jumpToDataStorageDemo)),
                                    JGSDemoTableRowMakeSelector(@"Device Demo", @selector(jumpToDeviceDemo)),
                                    JGSDemoTableRowMakeSelector(@"Encryption Demo", @selector(jumpToEncryptionDemo)),
                                    JGSDemoTableRowMakeSelector(@"HUD（Loading、Toast）", @selector(jumpToHudDemo)),
                                    JGSDemoTableRowMakeSelector(@"Reachability", @selector(jumpToReachabilityDemo)),
                                    JGSDemoTableRowMakeSelector(@"Security Keyboard", @selector(jumpToKeyboardDemo)),
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        //JGSLog(@"%@", @(JGSLogModeNone));
        //JGSLog(@"%@", @(JGSLogModeLog));
        //JGSLog(@"%@", @(JGSLogModeFunc));
        //JGSLog(@"%@", @(JGSLogModeFile));
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@"（type: %@）", @(JGSEnableLogMode)];
    }
    
    return cell;
}

#pragma mark - Action
- (void)showLogModeList {
    
#ifdef JGS_Category_UIAlertController
    JGSWeakSelf
    NSArray *types = @[@"Log disable", @"Log only", @"Log with function line", @"Log with function line and pretty out", @"Log with file function line"];
    [UIAlertController jg_actionSheetWithTitle:@"选择日志类型" cancel:@"取消" others:types action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
        
        if (idx == alert.jg_cancelIdx) {
            return;
        }
        
        JGSStrongSelf
        NSInteger selIdx = idx - alert.jg_firstOtherIdx;
        JGSEnableLogWithMode(JGSLogModeNone + selIdx);
        [self.tableView reloadData];
        
        [UIAlertController jg_alertWithTitle:@"日志输出设置" message:types[selIdx] cancel:@"确定" action:^(UIAlertController * _Nonnull _alert, NSInteger _idx) {
            JGSLog(@"<%@: %p> %@", NSStringFromClass([_alert class]), _alert, @(_idx));
            
#ifdef JGS_Category_UIApplication
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            JGSLog(@"key: %p", [UIApplication sharedApplication].keyWindow);
            JGSLog(@"window: %p", [UIApplication sharedApplication].delegate.window);
            
#ifdef JGS_Category_UIApplication
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        });
    }];
#endif
}

#pragma mark - Category
- (void)jumpToCategoryDemo {
    
    JGSCategoryDemoViewController *vcT = [[JGSCategoryDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

#pragma mark - Other
- (void)jumpToDataStorageDemo {
    
}

- (void)jumpToDeviceDemo {
    
#ifdef JGS_Device
    // iOS 15不弹窗问题，位置修改到此处
    //dispatch_async(dispatch_get_main_queue(), ^{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    JGSLog(@"idfa: %@", [JGSDevice idfa]);
    JGSLog(@"deviceId: %@", [JGSDevice deviceId]);
    //    JGSLog(@"%@", [JGSDevice idfa]);
    //});
#endif
}

- (void)jumpToEncryptionDemo {
    
#ifdef JGS_Encryption
    JGSEncryptionDemoViewController *vcT = [[JGSEncryptionDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#endif
}

- (void)jumpToHudDemo {
    
    JGSHUDDemoViewController *vcT = [[JGSHUDDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToReachabilityDemo {
    
}

- (void)jumpToKeyboardDemo {
    
    JGSKeyboardDemoViewController *vcT = [[JGSKeyboardDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

@end
