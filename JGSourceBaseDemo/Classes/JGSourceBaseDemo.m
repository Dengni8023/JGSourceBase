//
//  JGSourceBaseDemo.m
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import "JGSourceBaseDemo.h"
#import "JGSourceBase.h"

@interface JGSourceBaseDemo ()

@end

@implementation JGSourceBaseDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGReuseIdentifier(UITableViewCell)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 5;
            break;
            
        case 1:
            return 5;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JGReuseIdentifier(UITableViewCell) forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            
            NSString *titles[5] = {
                @"Log disable",
                @"Log only",
                @"Log with function line",
                @"Log with function line and pretty out",
                @"Log with file function line",
            };
            
            [cell.textLabel setText:titles[indexPath.row]];
        }
            break;
            
        case 1: {
            
            NSString *titles[5] = {
                @"Log with mode setting",
                @"Log only",
                @"Log with function line",
                @"Log with function line and pretty out",
                @"Log with file function line",
            };
            
            [cell.textLabel setText:titles[indexPath.row]];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray<NSString *> *titles = @[@"日志开关、设置", @"打印日志"];
    return section < titles.count ? titles[section] : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case 0: {
            
            switch (indexPath.row) {
                case 0:
                    JGEnableLogWithMode(JGLogModeNone);
                    break;
                    
                case 1:
                    JGEnableLogWithMode(JGLogModeLog);
                    break;
                    
                case 2:
                    JGEnableLogWithMode(JGLogModeFunc);
                    break;
                    
                case 3:
                    JGEnableLogWithMode(JGLogModePretty);
                    break;
                    
                case 4:
                    JGEnableLogWithMode(JGLogModeFile);
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1: {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            switch (indexPath.row) {
                case 0:
                    JGLog(@"%@", cell.textLabel.text);
                    break;
                    
                case 1:
                    JGLogOnly(@"%@", cell.textLabel.text);
                    break;
                    
                case 2:
                    JGLogFunc(@"%@", cell.textLabel.text);
                    break;
                    
                case 3:
                    JGLogPretty(@"%@", cell.textLabel.text);
                    break;
                    
                case 4:
                    JGLogFile(@"%@", cell.textLabel.text);
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - End

@end
