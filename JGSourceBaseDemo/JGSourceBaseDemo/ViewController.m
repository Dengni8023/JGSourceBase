//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "ViewController.h"
#import "JGDemoTableData.h"
#import "JGSBaseDemoViewController.h"
#import "JGSHUDDemoViewController.h"
#import "JGSKeyboardDemoViewController.h"

@interface ViewController ()

@property (nonatomic, copy) NSArray<JGDemoTableSectionData *> *demoData;

@end

@implementation ViewController

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (void)initDatas {
    
    self.demoData = @[
                      // Section 日志
                      JGDemoTableSectionMake(nil,
                                             @[
                                               JGDemoTableRowMakeSelector(@"调试日志控制", @selector(showLogModeList)),
                                               JGDemoTableRowMakeSelector(@"通用功能", @selector(jumpToBaseDemo)),
                                               JGDemoTableRowMakeSelector(@"HUD（Loading、Toast）", @selector(jumpToHudDemo)),
                                               JGDemoTableRowMakeSelector(@"Security Keyboard", @selector(jumpToKeyboardDemo)),
                                               ]),
                      ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    [self initDatas];
    
    [[JGSReachability sharedInstance] startMonitor];
    [[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {
        
        JGSEnableLogWithMode(JGSLogModeFunc);
        JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
    }];
    
    JGSLog(@"0x%X", JGSDeviceJailbrokenNone); // 4e6f6e65
    JGSLog(@"0x%X", JGSDeviceJailbrokenIsBroken); // 6f6b656e
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGSReuseIdentifier(UITableViewCell)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.demoData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoData[section].rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JGSReuseIdentifier(UITableViewCell) forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.contentView.backgroundColor = JGSColorHex(arc4random() % 0xffffff);
    //cell.contentView.backgroundColor = JGSColorRGB(arc4random() % (0xff + 1), arc4random() % (0xff + 1), arc4random() % (0xff + 1));
    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@"（type: %@）", @(JGSEnableLogMode)];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.demoData[section].title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    JGDemoTableRowData *rowData = self.demoData[indexPath.section].rows[indexPath.row];
    if (rowData.selectBlock) {
        rowData.selectBlock(rowData);
    }
    else if (rowData.selector && [self respondsToSelector:rowData.selector]) {
        
        // 避免警告
        IMP imp = [self methodForSelector:rowData.selector];
        id (*func)(id, SEL, NSInteger) = (void *)imp;
        func(self, rowData.selector, indexPath.row);
    }
    
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
    if (indexPath.section == 0) {
        
        JGSLogInfo(@"Info Log");
        JGSLogError(@"Error Log");
        JGSLogWarning(@"Warning Log");
    }
}

#pragma mark - Action
- (void)showLogModeList {
    
    JGSWeakSelf
    NSArray *types = @[@"Log disable", @"Log only", @"Log with function line", @"Log with function line and pretty out", @"Log with file function line"];
    [JGSAlertController actionSheetWithTitle:@"选择日志类型" cancel:nil others:types action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
        
        JGSStrongSelf
        NSInteger selIdx = idx - alert.jg_firstOtherIdx;
        JGSEnableLogWithMode(JGSLogModeNone + selIdx);
        [self.tableView reloadData];
        
        [JGSAlertController alertWithTitle:@"日志输出设置" message:types[selIdx] cancel:@"确定" action:^(UIAlertController * _Nonnull _alert, NSInteger _idx) {
            JGSLog(@"<%@: %p> %@", NSStringFromClass([_alert class]), _alert, @(_idx));
            
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            JGSLog(@"key: %p", [UIApplication sharedApplication].keyWindow);
            JGSLog(@"window: %p", [UIApplication sharedApplication].delegate.window);
            
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
        });
    }];
}

- (void)jumpToBaseDemo {
    
    JGSBaseDemoViewController *vcT = [[JGSBaseDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToHudDemo {
    
    JGSHUDDemoViewController *vcT = [[JGSHUDDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToKeyboardDemo {
    
    JGSKeyboardDemoViewController *vcT = [[JGSKeyboardDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

@end
