//
//  JGSHUDDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSHUDDemoViewController.h"
#import "JGSDemoTableData.h"

#ifdef JGS_HUD
@interface JGSHUDDemoViewController ()

@end

@implementation JGSHUDDemoViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        // Section 全屏Loading
        JGSDemoTableSectionMake(@" 全屏Loading",
                                @[
                                    JGSDemoTableRowMakeSelector(@"Default样式", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Default样式 + Message", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Indicator样式", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Indicator样式 + Message", @selector(showLoadingHUD:)),
                                ]),
        // Section 全屏Loading-Custom
        JGSDemoTableSectionMake(@" 全屏Loading-Custom",
                                @[
                                    JGSDemoTableRowMakeSelector(@"Custom Spinning样式", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Custom Spinning样式 + Message", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Custom Spinning样式 + Message_Short", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Custom Icon 样式", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Custom Icon 样式 + Message", @selector(showLoadingHUD:)),
                                ]),
        // Section 全屏Loading-Custom
        JGSDemoTableSectionMake(@" 全屏Loading-无边框",
                                @[
                                    JGSDemoTableRowMakeSelector(@"Default 无边框", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Indicator 无边框", @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Custom Icon 无边框", @selector(showLoadingHUD:)),
                                ]),
        // Section 全屏Toast
        JGSDemoTableSectionMake(@" 全屏Toast",
                                @[
                                    JGSDemoTableRowMakeSelector(@"Default样式", @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Top样式", @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Up样式", @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Low样式", @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeSelector(@"Bottom样式", @selector(showToastHUD:)),
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"HUD Loading&Toast";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Action
- (void)showLoadingHUD:(NSIndexPath *)indexPath {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
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
                    
                default:
                    break;
            }
        }
            break;
            
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    static BOOL show = NO; show = !show;
                    [JGSLoadingHUDStyle sharedStyle].spinningShadow = show;
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:nil];
                }
                    break;
                    
                case 1: {
                    static BOOL show = NO; show = !show;
                    [JGSLoadingHUDStyle sharedStyle].spinningLineWidth = show ? 2.f : 4.f;
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:@"JGSHUDTypeSpinningCircle"];
                }
                    break;
                    
                case 2: {
                    static BOOL show = NO; show = !show;
                    [JGSLoadingHUDStyle sharedStyle].spinningLineColor = show ? JGSColorRGB(128, 100, 72) : nil;
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:@"JGSHUD"];
                }
                    break;
                    
                case 3: {
                    
                    UIImage *hudImg = [UIImage imageNamed:@"AppIcon"];
                    hudImg = [hudImg jg_imageScaleAspectFit:CGSizeMake(60, 60)];
                    [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:hudImg];
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:nil];
                }
                    break;
                    
                case 4: {
                    UIImage *hudImg = [UIImage imageNamed:@"AppIcon"];
                    hudImg = [hudImg jg_imageScaleAspectFit:CGSizeMake(60, 60)];
                    [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:hudImg];
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:@"Loading..."];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    static BOOL show = NO; show = !show;
                    [JGSLoadingHUDStyle sharedStyle].spinningShadow = show;
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = [UIColor clearColor];
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:nil];
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = nil; // 还原设置
                }
                    break;
                    
                case 1: {
                    static BOOL show = NO; show = !show;
                    [JGSLoadingHUDStyle sharedStyle].spinningLineWidth = show ? 2.f : 4.f;
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = [UIColor clearColor];
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeIndicator message:nil];
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = nil; // 还原设置
                }
                    break;
                    
                case 2: {
                    static BOOL show = NO; show = !show;
                    UIImage *hudImg = [UIImage imageNamed:@"AppIcon"];
                    hudImg = [hudImg jg_imageScaleAspectFit:CGSizeMake(60, 60)];
                    [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:hudImg];
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = [UIColor clearColor];
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:nil];
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = nil; // 还原设置
                }
                    break;
                    
                default:
                    break;
            }
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

- (void)showToastHUD:(NSIndexPath *)indexPath {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
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

#endif
