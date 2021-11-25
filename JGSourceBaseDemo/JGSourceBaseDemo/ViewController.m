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
#import "JGSEncryptionDemoViewController.h"
#import <AdSupport/ASIdentifierManager.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface ViewController ()

@end

@implementation ViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        // Section Base
        JGSDemoTableSectionMake(@" 基础功能",
                                @[
                                    JGSDemoTableRowMakeSelector(@"调试日志控制", @selector(showLogModeList))
                                ]),
        // Section 扩展功能
        JGSDemoTableSectionMake(@" 扩展功能",
                                @[
                                    JGSDemoTableRowMakeSelector(@"Category功能", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeSelector(@"HUD（Loading、Toast）", @selector(jumpToHudDemo)),
                                    JGSDemoTableRowMakeSelector(@"Security Keyboard", @selector(jumpToKeyboardDemo)),
                                    JGSDemoTableRowMakeSelector(@"Encryption Demo", @selector(jumpToEncryptionDemo)),
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
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    JGSLog(@"IDFA: %@", idfa);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)eventTest:(EKEventStore *)store {

    EKEvent *event = [EKEvent eventWithEventStore:store];
    event.title = @"这是一个 title";
    event.location = @"这是一个 location";
    event.notes = @"这是一个 notes";
    event.URL = [NSURL URLWithString:@"tpybxsit://app"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *date = [formatter dateFromString:@"2021-11-25 18:00:00"];

    // 提前一个小时开始
    NSDate *startDate = [NSDate dateWithTimeInterval:-1800 sinceDate:date];
    // 提前一分钟结束
    NSDate *endDate = [NSDate dateWithTimeInterval:60 sinceDate:date];
    
    event.startDate = startDate;
    event.endDate = endDate;
    event.allDay = NO;
    [event setCalendar:[store defaultCalendarForNewEvents]];
    
    // 添加闹钟结合（开始前多少秒）若为正则是开始后多少秒。
    NSInteger sec = -20 * 60;
    while (sec < 2 * 60) {

        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:sec];
        [event addAlarm:alarm];
        // 每两分钟提示一次
        sec += 1 * 60;
    }
    
    NSError *error = nil;
    [store saveEvent:event span:EKSpanThisEvent error:&error];

    if (!error) {
        JGSLog(@"添加时间成功");
        //添加成功后需要保存日历关键字
        NSString *iden = event.eventIdentifier;
        // 保存在沙盒，避免重复添加等其他判断
        [[NSUserDefaults standardUserDefaults] setObject:iden forKey:@"my_eventIdentifier"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        JGSLog(@"添加时间失败:%@",error);
    }
}

#pragma mark - Action
- (void)showLogModeList {
    
    // 第一步
    // 生成事件数据库对象
    EKEventStore *store = [[EKEventStore alloc] init];
    
    // 第二步
    // 申请事件类型权限
    // EKEntityTypeEvent 事件类型
    // EKEntityTypeReminder 提醒类型
    JGSWeakSelf
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        
        JGSStrongSelf
        // 第三步
        // 判断时间类型权限结果，有权限情况下，去创建事件
        if (error) {
            JGSLog(@"error: %@", error);
            return;
        }
        else if (!granted) {
            JGSLog(@"No permission !");
            return;
        }
        
        JGSWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            JGSStrongSelf
            [self eventTest:store];
        });
    }];
    return;
    
//    JGSWeakSelf
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

- (void)jumpToEncryptionDemo {
    
#ifdef JGS_Encryption
    JGSEncryptionDemoViewController *vcT = [[JGSEncryptionDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
#endif
}

@end
