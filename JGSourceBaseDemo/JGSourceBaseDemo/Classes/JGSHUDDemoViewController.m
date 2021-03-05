//
//  JGSHUDDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSHUDDemoViewController.h"
#import "JGDemoTableData.h"

@interface JGSHUDDemoViewController ()

@property (nonatomic, copy) NSArray<JGDemoTableSectionData *> *demoData;

@end

@implementation JGSHUDDemoViewController

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (void)initDatas {
    
    self.demoData = @[
                      // Section 全屏Loading HUD
                      JGDemoTableSectionMake(@">> 全屏Loading HUD",
                                             @[
                                               JGDemoTableRowMakeSelector(@"Default样式", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Default样式 + Message", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Indicator样式", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Indicator样式 + Message", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Custom Image样式", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Custom Image样式 + Message", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Custom Spinning样式", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Custom Spinning样式 + Message", @selector(showLoadingHUD:)),
                                               JGDemoTableRowMakeSelector(@"Custom Spinning样式 + Message_Short", @selector(showLoadingHUD:)),
                                               ]),
                      // Section 全屏Toast HUD
                      JGDemoTableSectionMake(@">> 全屏Toast HUD",
                                             @[
                                               JGDemoTableRowMakeSelector(@"Default样式", @selector(showToastHUD:)),
                                               JGDemoTableRowMakeSelector(@"Top样式", @selector(showToastHUD:)),
                                               JGDemoTableRowMakeSelector(@"Up样式", @selector(showToastHUD:)),
                                               JGDemoTableRowMakeSelector(@"Low样式", @selector(showToastHUD:)),
                                               JGDemoTableRowMakeSelector(@"Bottom样式", @selector(showToastHUD:)),
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
    
    self.title = @"Loading HUD、Toast";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGSReuseIdentifier(UITableViewCell)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
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
    
    //cell.contentView.backgroundColor = JGSColorRGB(arc4random() % (0xff + 1), arc4random() % (0xff + 1), arc4random() % (0xff + 1));
    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    
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
- (void)showLoadingHUD:(NSInteger)rowIndex {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    switch (rowIndex) {
        case 0: {
            [JGSLoadingHUD showLoadingHUD];
        }
            break;
            
        case 1: {
            [JGSLoadingHUD showLoadingHUD:@"加载中..."];
        }
            break;
            
        case 2: {
            [JGSLoadingHUD showIndicatorLoadingHUD];
        }
            break;
            
        case 3: {
            [JGSLoadingHUD showIndicatorLoadingHUD:@"加载中..."];
        }
            break;
            
        case 4: {
            [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoadingHUD"]];
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:nil];
        }
            break;
            
        case 5: {
            [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoadingHUD"]];
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:@"Image:JGSHUDTypeCustomView"];
        }
            break;
            
        case 6: {
            static BOOL show = NO; show = !show;
            [JGSLoadingHUDStyle sharedStyle].spinningShadow = show;
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:nil];
        }
            break;
            
        case 7: {
            static BOOL show = NO; show = !show;
            [JGSLoadingHUDStyle sharedStyle].spinningLineWidth = show ? 2.f : 4.f;
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:@"JGSHUDTypeSpinningCircle"];
        }
            break;
            
        case 8: {
            static BOOL show = NO; show = !show;
            [JGSLoadingHUDStyle sharedStyle].spinningLineColor = show ? JGSColorRGB(128, 100, 72) : nil;
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:@"JGSHUD"];
        }
            break;
            
        default:
            break;
    }
    
    JGSWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JGSStrongSelf
        [self.view jg_hideLoading];
    });
}

- (void)showToastHUD:(NSInteger)rowIndex {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    switch (rowIndex) {
        case 0: {
            [JGSToast showToastWithMessage:@"加载中..."];
        }
            break;
            
        case 1: {
            [JGSToast showToastWithMessage:@"加载中..." position:JGSToastPositionTop];
        }
            break;
            
        case 2: {
            [JGSToast showToastWithMessage:@"加载中..." position:JGSToastPositionUp];
        }
            break;
            
        case 3: {
            [JGSToast showToastWithMessage:@"加载中..." position:JGSToastPositionLow];
        }
            break;
            
        case 4: {
            [JGSToast showToastWithMessage:@"加载中..." position:JGSToastPositionBottom];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - End

@end
