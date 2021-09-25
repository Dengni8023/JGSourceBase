//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "ViewController.h"
#import "JGSDemoTableData.h"
#import "JGSCategoryDemoViewController.h"
#import "JGSHUDDemoViewController.h"
#import "JGSKeyboardDemoViewController.h"
#import <sys/time.h>

@interface ViewController ()

@end

@implementation ViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        // Section Base
        JGSDemoTableSectionMake(@"基础功能",
                                @[
                                    JGSDemoTableRowMakeSelector(@"调试日志控制", @selector(showLogModeList))
                                ]),
        // Section 扩展功能
        JGSDemoTableSectionMake(@"扩展功能",
                                @[
                                    JGSDemoTableRowMakeSelector(@"Category功能", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"HUD（Loading、Toast）", @selector(jumpToHudDemo)),
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)showLogModeList {
    
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
            
#ifdef JGS_Category
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            JGSLog(@"key: %p", [UIApplication sharedApplication].keyWindow);
            JGSLog(@"window: %p", [UIApplication sharedApplication].delegate.window);
            
#ifdef JGS_Category
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        });
    }];
}

- (void)jumpToCategoryDemo {
    
#ifdef JGS_Category
    JGSCategoryDemoViewController *vcT = [[JGSCategoryDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#endif
}

- (void)jumpToHudDemo {
    
#ifdef JGS_HUD
    JGSHUDDemoViewController *vcT = [[JGSHUDDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#endif
}

- (void)jumpToKeyboardDemo {
    
#ifdef JGS_SecurityKeyboard
    JGSKeyboardDemoViewController *vcT = [[JGSKeyboardDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#endif
}

@end
