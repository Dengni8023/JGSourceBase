//
//  JGSHUDDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/2/16.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSHUDDemoVC.h"
#import <SDWebImage/SDWebImage.h>

@interface JGSHUDDemoVC ()

@end

@implementation JGSHUDDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Loading & Toast";
}

#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		// Section 全屏Loading
		JGSDemoTableSectionMake(@" 全屏Loading",
		@[
			JGSDemoTableRowMake(@"Default样式", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Default样式 + Message", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Indicator样式", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Indicator样式 + Message", self, @selector(showLoadingHUD:)),
		]),
		// Section 全屏Loading-Custom
		JGSDemoTableSectionMake(@" 全屏Loading-Custom",
		@[
			JGSDemoTableRowMake(@"Custom Spinning样式", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Custom Spinning样式 + Message", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Custom Spinning样式 + Message_Short", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Custom Icon 样式", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Custom Icon 样式 + Message", self, @selector(showLoadingHUD:)),
		]),
		// Section 全屏Loading-Custom
		JGSDemoTableSectionMake(@" 全屏Loading-无边框",
		@[
			JGSDemoTableRowMake(@"Default 无边框", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Indicator 无边框", self, @selector(showLoadingHUD:)),
			JGSDemoTableRowMake(@"Custom Icon 无边框", self, @selector(showLoadingHUD:)),
            JGSDemoTableRowMake(@"Custom gif 无边框", self, @selector(showLoadingHUD:)),
		]),
		// Section 全屏Toast
		JGSDemoTableSectionMake(@" 全屏Toast",
		@[
			JGSDemoTableRowMake(@"Default样式", self, @selector(showToastHUD:)),
			JGSDemoTableRowMake(@"Top样式", self, @selector(showToastHUD:)),
			JGSDemoTableRowMake(@"Up样式", self, @selector(showToastHUD:)),
			JGSDemoTableRowMake(@"Low样式", self, @selector(showToastHUD:)),
			JGSDemoTableRowMake(@"Bottom样式", self, @selector(showToastHUD:)),
			JGSDemoTableRowMake(@"Default样式+completion", self, @selector(showToastHUD:)),
		]),
	];
}

#pragma mark - Action
- (void)showLoadingHUD:(NSIndexPath *)indexPath {
    
    JGSDemoShowConsoleLog(self, @"");
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
                    UIImage *hudImg = [UIImage imageNamed:@"AppIcon"];
                    hudImg = [hudImg jg_imageScaleAspectFit:CGSizeMake(60, 60)];
                    [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:hudImg];
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = [UIColor clearColor];
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:nil];
                    [JGSLoadingHUDStyle sharedStyle].bezelBackgroundColor = nil; // 还原设置
                }
                    break;
                    
                case 3: {
                    static int show = 0; show += 1;
                    NSString *gifName = @[@"LoadingWithAlpha-1.gif",
                                          @"LoadingWithAlpha-2.gif",
                                          @"LoadingWithAlpha-3.gif",
                                          @"LoadingWithAlpha-4.gif",
                                          @"LoadingWithAlpha-5.gif",
                                          @"LoadingWithoutAlpha-1.gif"][show % 6];
                    show = show >= 6 ? 0 : show;
                    NSData *gifData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:gifName ofType:nil]];
                    UIImageView *gifImgView = [[UIImageView alloc] initWithImage:[UIImage sd_imageWithData:gifData]];
                    gifImgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.28];
                    
                    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:gifImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:120];
                    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:gifImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:120];
                    [gifImgView addConstraints:@[width, height]];
                    
                    [JGSLoadingHUDStyle sharedStyle].customView = gifImgView;
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
    
    JGSDemoShowConsoleLog(self, @"");
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
            
        case 5: {
            [JGSToast showToastWithIcon:[UIImage imageNamed:@"AppIcon"] message:@"加载中..." completion:^{
                
            }];
        }
            break;
            
        default:
            break;
    }
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
