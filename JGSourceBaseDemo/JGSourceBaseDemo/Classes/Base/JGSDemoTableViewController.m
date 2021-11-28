//
//  JGSDemoTableViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2021/9/15.
//  Copyright © 2021 MeiJigao. All rights reserved.
//

#import "JGSDemoTableViewController.h"

@interface JGSDemoTableViewController ()

@property (nonatomic, copy) NSArray<JGSDemoTableSectionData *> *demoData;

@end

@implementation JGSDemoTableViewController

#pragma mark - Life Cycle
- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef JGS_Reachability
    [[JGSReachability sharedInstance] startMonitor];
    [[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {
        
        JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
    }];
#endif
    
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.f];
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGSReuseIdentifier(UITableViewCell)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
#ifdef JGS_Category_UIColor
    self.navigationController.navigationBar.tintColor = JGSColorHex(0xffffff);
    self.navigationController.navigationBar.barTintColor = JGSDemoNavigationBarColor;
#endif
    
#ifdef JGS_Reachability
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
#endif
}

- (NSArray<JGSDemoTableSectionData *> *)demoData {
    
    _demoData = _demoData ?: [self tableSectionData];
    
    return _demoData;
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
    
#ifdef JGS_Category_UIColor
    cell.backgroundColor = JGSColorHex(arc4random() % 0x01000000);
    cell.contentView.backgroundColor = JGSColorHex(0xffffff);
#endif

    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.demoData[section].title.length > 0 ? 32 : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *header = [[UILabel alloc] init];
    header.text = self.demoData[section].title;
    header.textColor = [UIColor colorWithWhite:0.36 alpha:1.f];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    JGsDemoTableRowData *rowData = self.demoData[indexPath.section].rows[indexPath.row];
    if (rowData.selector && [self respondsToSelector:rowData.selector]) {
        
        // 避免警告
        IMP imp = [self methodForSelector:rowData.selector];
        id (*func)(id, SEL, NSIndexPath *) = (void *)imp;
        func(self, rowData.selector, indexPath);
    }
    
#ifdef JGS_Reachability
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
#endif
    if (indexPath.section == 0) {
        
        JGSLogInfo(@"Info Log");
        JGSLogError(@"Error Log");
        JGSLogWarning(@"Warning Log");
    }
}

@end
