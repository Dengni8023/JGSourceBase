//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "ViewController.h"
#import "JGSCategoryDemoViewController.h"
#import "JGSDataStorageDemoViewController.h"
#import "JGSEncryptionDemoViewController.h"
#import "JGSHUDDemoViewController.h"
#import "JGSKeyboardDemoViewController.h"
#import <AdSupport/ASIdentifierManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        // 基础组件
        JGSDemoTableSectionMake(@" 基础组件",
                                @[
                                    JGSDemoTableRowMake(@"调试日志控制-Alert扩展", nil, @selector(showLogModeList:))
                                ]),
        // 功能组
        JGSDemoTableSectionMake(@" 功能组件",
                                @[
                                    JGSDemoTableRowMake(@"Category Demo", nil, @selector(jumpToCategoryDemo:)),
                                    JGSDemoTableRowMake(@"DataStorage Demo", nil, @selector(jumpToDataStorageDemo:)),
                                    JGSDemoTableRowMake(@"Device Demo", nil, @selector(jumpToDeviceDemo:)),
                                    JGSDemoTableRowMake(@"Encryption Demo", nil, @selector(jumpToEncryptionDemo:)),
                                    JGSDemoTableRowMake(@"HUD（Loading、Toast）", nil, @selector(jumpToHudDemo:)),
                                    JGSDemoTableRowMake(@"Reachability", nil, @selector(jumpToReachabilityDemo:)),
                                    JGSDemoTableRowMake(@"Security Keyboard", nil, @selector(jumpToKeyboardDemo:)),
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.showTextView = YES;
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
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@"（type: %@）", @(JGSEnableLogMode)];
    }
    
    return cell;
}

#pragma mark - Action
- (void)showLogModeList:(NSIndexPath *)indexPath {
    
    JGSDemoShowConsoleLog();
#ifdef JGSCategory_UIAlertController
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
        
        JGSWeakSelf
        [UIAlertController jg_alertWithTitle:@"日志输出设置" message:types[selIdx] cancel:@"确定" action:^(UIAlertController * _Nonnull _alert, NSInteger _idx) {
            
            JGSStrongSelf
            JGSDemoShowConsoleLog(@"<%@: %p> %@", NSStringFromClass([_alert class]), _alert, @(_idx));
            
#ifdef JGSCategory_UIApplication
            JGSDemoShowConsoleLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSDemoShowConsoleLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            JGSStrongSelf
            JGSDemoShowConsoleLog(@"key: %p", [UIApplication sharedApplication].keyWindow);
            JGSDemoShowConsoleLog(@"window: %p", [UIApplication sharedApplication].delegate.window);
            
#ifdef JGSCategory_UIApplication
            JGSDemoShowConsoleLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSDemoShowConsoleLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        });
    }];
#endif
}

- (void)jumpToCategoryDemo:(NSIndexPath *)indexPath {
#ifdef JGS_Category
    JGSCategoryDemoViewController *vcT = [[JGSCategoryDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(@"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToDataStorageDemo:(NSIndexPath *)indexPath {

#ifdef JGS_DataStorage
    JGSDataStorageDemoViewController *vcT = [[JGSDataStorageDemoViewController alloc] init];
    vcT.title = @"Data Storage";
    vcT.tableSectionData = @[
        JGSDemoTableSectionMake(@" UserDefaults",
                                @[
                                ]),
    ];

    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(@"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToDeviceDemo:(NSIndexPath *)indexPath {

#ifdef JGS_Device
    JGSDemoShowConsoleLog(@"设备越狱检测：%d\n", [JGSDevice isDeviceJailbroken] == JGSDeviceJailbrokenIsBroken);
    JGSDemoShowConsoleLog(@"%d\n", [JGSDevice isAPPResigned:@[@"Z28L6TKG58"]]);
    JGSDemoShowConsoleLog(@"%d\n", [JGSDevice isSimulator]);

    JGSDemoShowConsoleLog(@"sysUserAgent: %@", [JGSDevice sysUserAgent]);
    JGSDemoShowConsoleLog(@"%@", [JGSDevice appInfo]);
    //JGSDemoShowConsoleLog(@"%@", [JGSDevice deviceInfo]);
    JGSDemoShowConsoleLog(@"%@", [JGSDevice deviceMachine]);
    JGSDemoShowConsoleLog(@"%@", [JGSDevice deviceModel]);
    JGSDemoShowConsoleLog(@"%@", [JGSDevice appUserAgent]);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    JGSDemoShowConsoleLog(@"%@", [JGSDevice idfa]);
    //});

    // iOS 15不弹窗问题，位置修改到此处
    //dispatch_async(dispatch_get_main_queue(), ^{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    JGSDemoShowConsoleLog(@"idfa: %@", [JGSDevice idfa]);
    JGSDemoShowConsoleLog(@"deviceId: %@", [JGSDevice deviceId]);
    //    JGSDemoShowConsoleLog(@"%@", [JGSDevice idfa]);
    //});
#else
    JGSDemoShowConsoleLog(@"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToEncryptionDemo:(NSIndexPath *)indexPath {

#ifdef JGS_Encryption
    JGSEncryptionDemoViewController *vcT = [[JGSEncryptionDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(@"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToHudDemo:(NSIndexPath *)indexPath {

    JGSHUDDemoViewController *vcT = [[JGSHUDDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToReachabilityDemo:(NSIndexPath *)indexPath {

#ifdef JGS_Reachability
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [[JGSReachability sharedInstance] startMonitor];

        JGSWeakSelf
        [[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {

            JGSStrongSelf
            NSString *statusString = [[JGSReachability sharedInstance] reachabilityStatusString];
            JGSDemoShowConsoleLog(@"Network status: %@", statusString);
#ifdef JGSCategory_UIAlertController
            [UIAlertController jg_alertWithTitle:@"网络变了" message:statusString cancel:@"确定"];
#endif
        }];
    });

    NSDictionary *netInfo = @{
        @"Reachable": [[JGSReachability sharedInstance] reachable] ? @"YES": @"NO",
        @"WiFi": [[JGSReachability sharedInstance] reachableViaWiFi] ? @"YES": @"NO",
        @"WWAN": [[JGSReachability sharedInstance] reachableViaWWAN] ? @"YES": @"NO",
        @"Network Type": [[JGSReachability sharedInstance] reachabilityStatusString],
    };

#ifdef JGSCategory_NSObject
    NSString *netJSON = [netInfo jg_JSONStringWithOptions:NSJSONWritingPrettyPrinted error:nil];
#else
    NSData *data = [NSJSONSerialization dataWithJSONObject:netInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *netJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#endif

    JGSDemoShowConsoleLog(@"%@", netJSON);
    
#else
    JGSDemoShowConsoleLog(@"Unimplemented or dependencies not founded !");
#endif
}

- (void)jumpToKeyboardDemo:(NSIndexPath *)indexPath {

#ifdef JGS_SecurityKeyboard
    JGSKeyboardDemoViewController *vcT = [[JGSKeyboardDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#else
    JGSDemoShowConsoleLog(@"Unimplemented or dependencies not founded !");
#endif
}

#pragma mark - End

@end
