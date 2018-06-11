//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/19.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "ViewController.h"
#import <JGSourceBase/JGSourceBase.h>
#import "JGDemoTableData.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray<JGDemoTableSectionData *> *demoData;

@end

@implementation ViewController

#pragma mark - init & dealloc
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initDatas];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        
        [self initDatas];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self initDatas];
    }
    return self;
}

- (void)initDatas {
    
    JGSCWeak(self);
    _demoData = @[
                  JGDemoTableSectionMake(@"日志开关、设置",
                                         @[
                                           JGDemoTableRowMakeBlock(@"Log disable", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeNone);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log only", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeLog);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with function line", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeFunc);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with function line and pretty out", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModePretty);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with file function line", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeFile);
                      [weakself.tableView reloadData];
                  }),
                                           ]),
                  JGDemoTableSectionMake(@"打印日志",
                                         @[
                                           JGDemoTableRowMakeBlock(@"Log with mode setting", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCLog(@"%@", rowData.title);
                  }),
                                           JGDemoTableRowMakeBlock(@"Log only", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCLogOnly(@"%@", rowData.title);
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with function line", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCLogFunc(@"%@", rowData.title);
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with function line and pretty out", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCLogPretty(@"%@", rowData.title);
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with file function line", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCLogFile(@"%@", rowData.title);
                  }),
                                           ]),
                  ];
}

- (void)dealloc {
    
    JGSCLog(@"<%@: %p>, %@", NSStringFromClass([self class]), self, self.title);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGSCReuseIdentifier(UITableViewCell)];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JGSCReuseIdentifier(UITableViewCell) forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return [self.demoData[section].title stringByAppendingFormat:@"(type : %zd)", JGSCEnableLogMode];
    }
    return self.demoData[section].title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    JGSCLogError(@"Error Log");
    JGSCLogWarning(@"Warning Log");
    
    JGDemoTableRowData *rowData = self.demoData[indexPath.section].rows[indexPath.row];
    if (rowData.selectBlock) {
        rowData.selectBlock(rowData);
    }
}

#pragma mark - End

@end
