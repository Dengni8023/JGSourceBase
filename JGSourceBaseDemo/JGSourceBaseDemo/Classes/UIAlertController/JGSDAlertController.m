//
//  JGSDAlertController.m
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/7/14.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "JGSDAlertController.h"

@interface JGSDAlertController ()

@end

@implementation JGSDAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// MARK: - Data
- (void)loadData {
    
    NSString *alertTitle = @"提示";
    NSString *actionTitle = @"选项";
    NSString *cancel = @"取消";
    NSString *destructive = @"警告";
    
    JGSWeakSelf
    NSArray<JGSDTableSectionData *> *sections = @[
        [
            JGSDTableSectionData sectionWithTitle:@"Alert" rows:@[
            [JGSDTableCellData dataWithTitle:@"无按钮" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"无按钮提示";
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:nil destructive:nil others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:nil destructive:nil others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"单取消" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"单取消按钮提示";
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:nil others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:nil others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"单警告" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"单警告按钮提示";
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:nil destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:nil destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+单其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+单其他按钮提示";
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:nil others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:nil others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"警告+单其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"警告+单其他按钮提示";
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:nil destructive:destructive others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:nil destructive:destructive others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+其他按钮提示";
                NSArray<NSString *> *others = @[@"其他-1", @"其他-2", @"其他-3"];
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:nil others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:nil others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"警告+其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"警告+其他按钮提示";
                NSArray<NSString *> *others = @[@"其他-1", @"其他-2", @"其他-3"];
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:nil destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:nil destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+警告" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+警告按钮提示";
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+警告+其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+警告+其他按钮提示";
                NSArray<NSString *> *others = @[@"其他-1", @"其他-2", @"其他-3", @"其他-4", @"其他-5", @"其他-6", @"其他-7", @"其他-8", @"其他-9", @"其他-10", @"其他-11", @"其他-12", @"其他-13", @"其他-14", @"其他-15", @"其他-16", @"其他-17", @"其他-18", @"其他-19", @"其他-20"];
                if (arc4random() % 2 == 0) {
                    [self jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_alertWithTitle:alertTitle message:message cancel:cancel destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
        ]],
        [
            JGSDTableSectionData sectionWithTitle:@"ActionSheet - iOS26开始Phone屏幕居中弹窗" rows:@[
            [JGSDTableCellData dataWithTitle:@"无按钮" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"无按钮选择";
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"单取消" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"单取消按钮选择";
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:cancel others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:cancel others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"单警告" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"单警告按钮选择";
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:nil destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:nil destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+单其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+单其他按钮选择";
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:cancel others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:cancel others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"警告+单其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"警告+单其他按钮选择";
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:nil destructive:destructive others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:nil destructive:destructive others:@[@"其他"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+其他按钮选择";
                NSArray<NSString *> *others = @[@"其他-1", @"其他-2", @"其他-3"];
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:cancel others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:cancel others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"警告+其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"警告+其他按钮选择";
                NSArray<NSString *> *others = @[@"其他-1", @"其他-2", @"其他-3"];
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:nil destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:nil destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+警告" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+警告按钮选择";
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:cancel destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:cancel destructive:destructive others:@[] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
            [JGSDTableCellData dataWithTitle:@"取消+警告+其他" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSStrongSelf
                NSString *message = @"取消+警告+其他按钮选择";
                NSArray<NSString *> *others = @[@"其他-1", @"其他-2", @"其他-3", @"其他-4", @"其他-5", @"其他-6", @"其他-7", @"其他-8", @"其他-9", @"其他-10", @"其他-11", @"其他-12", @"其他-13", @"其他-14", @"其他-15", @"其他-16", @"其他-17", @"其他-18", @"其他-19", @"其他-20"];
                if (arc4random() % 2 == 0) {
                    [self jg_actionSheetWithTitle:actionTitle message:message cancel:cancel destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        JGSLog(@"%@: %@", alert, @(idx))
                    }];
                    return;
                }
                [UIAlertController jg_actionSheetWithTitle:actionTitle message:message cancel:cancel destructive:destructive others:others action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                    JGSLog(@"%@: %@", alert, @(idx))
                }];
            }],
        ]],
    ];
    [self setupData:sections rows:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
