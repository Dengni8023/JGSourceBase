//
//  JGSUIAlertControllerDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/3/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSUIAlertControllerDemoVC.h"

@interface JGSUIAlertControllerDemoVC ()

@end

@implementation JGSUIAlertControllerDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"UIAlertController";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#ifdef JGSCategory_UIAlertController_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" Alert",
		@[
			JGSDemoTableRowMake(@"Show alerts，Last hide all", self, @selector(categoryAlertDemo:)),
			JGSDemoTableRowMake(@"Show alerts，Last hide one", self, @selector(categoryAlertDemo:)),
			JGSDemoTableRowMake(@"Alert canle & destructive", self, @selector(categoryAlertDemo:)),
			JGSDemoTableRowMake(@"Alert canle & other", self, @selector(categoryAlertDemo:)),
			JGSDemoTableRowMake(@"Alert canle & others", self, @selector(categoryAlertDemo:)),
			JGSDemoTableRowMake(@"Alert canle & destructive & others", self, @selector(categoryAlertDemo:)),
		]),
		JGSDemoTableSectionMake(@" ActionSheet",
		@[
			JGSDemoTableRowMake(@"No title & no message", self, @selector(categoryActionSheetDemo:)),
			JGSDemoTableRowMake(@"With title", self, @selector(categoryActionSheetDemo:)),
			JGSDemoTableRowMake(@"With title & message", self, @selector(categoryActionSheetDemo:)),
			JGSDemoTableRowMake(@"With title & message & cancel", self, @selector(categoryActionSheetDemo:)),
			JGSDemoTableRowMake(@"With title & message & cancel & destructive", self, @selector(categoryActionSheetDemo:)),
		])
	];
}

#pragma mark - Action
- (void)categoryAlertDemo:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            
            // Last hide all
            NSInteger i = 0;
            while (i < 5) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [UIAlertController jg_alertWithTitle:[@(i + 1) stringValue] message:@"5 alerts，Last hide all" cancel:(i == 4 ? @"关闭所有" : (i % 2 == 0 ? @"确定" : nil)) action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        
                        if (i == 4) {
                            [UIAlertController jg_hideAllAlert:YES];
                        }
                    }];
                });
                i += 1;
            }
        }
            break;
            
        case 1: {
            
            // Last hide one
            NSInteger i = 0;
            while (i < 4) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [UIAlertController jg_alertWithTitle:[@(i + 1) stringValue] message:@"5 alerts，Last hide all" cancel:(i == 3 ? @"再关闭一个" : @"确定") action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        
                        if (i == 3) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [UIAlertController jg_hideCurrentAlert:YES];
                            });
                        }
                    }];
                });
                i += 1;
            }
        }
            break;
            
        case 2: {
            
            // canle & destructive
            [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" destructive:@"Destructive" action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        case 3: {
            
            // canle & other
            [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" other:@"Other" action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        case 4: {
            
            // canle & others
            [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        case 5: {
            
            // canle & destructive & others
            [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" destructive:@"Destructive" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)categoryActionSheetDemo:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            
            // no title
            [UIAlertController jg_actionSheetWithTitle:nil cancel:nil others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        case 1: {
            
            // title
            [UIAlertController jg_actionSheetWithTitle:@"Title" cancel:nil others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        case 2: {
            
            // title & message
            [UIAlertController jg_actionSheetWithTitle:@"Title" message:@"Message" cancel:nil others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        case 3: {
            
            // title & message & cancel
            [UIAlertController jg_actionSheetWithTitle:@"Title" message:@"Message" cancel:@"Cancel" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        case 4: {
            
            // title & message & cancel & destructive
            [UIAlertController jg_actionSheetWithTitle:@"Title" message:@"Message" cancel:@"Cancel" destructive:@"Destructive" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                
            }];
        }
            break;
            
        default:
            break;
    }
}

#endif

@end
