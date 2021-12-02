//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "ViewController.h"
#import "JGSKeyboardDemoViewController.h"
#import <AdSupport/ASIdentifierManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
        // Section Base
        JGSDemoTableSectionMake(@" Base组件基础",
                                @[
                                    JGSDemoTableRowMakeWithSelector(@"调试日志控制-Alert扩展", @selector(showLogModeList))
                                ]),
        // Section 扩展功能
        JGSDemoTableSectionMake(@" Base Utils",
                                @[
                                    JGSDemoTableRowMakeWithSelector(@"DataStorage Demo", @selector(jumpToDataStorageDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"Device Demo", @selector(jumpToDeviceDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"Encryption Demo", @selector(jumpToEncryptionDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"HUD（Loading、Toast）", @selector(jumpToHudDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"Reachability", @selector(jumpToReachabilityDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"Security Keyboard", @selector(jumpToKeyboardDemo)),
                                ]),
        // Section Category扩展
        JGSDemoTableSectionMake(@" Category",
                                @[
                                    JGSDemoTableRowMakeWithSelector(@"NSDate", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"NSDictionary", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"NSObject", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"NSString", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"NSURL", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"UIAlertController", @selector(jumpToCategoryAlert)),
                                    JGSDemoTableRowMakeWithSelector(@"UIApplication", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"UIColor", @selector(jumpToCategoryDemo)),
                                    JGSDemoTableRowMakeWithSelector(@"UIImage", @selector(jumpToCategoryDemo)),
                                ]),
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.showTextView = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        //JGSLog(@"%@", @(JGSLogModeNone));
        //JGSLog(@"%@", @(JGSLogModeLog));
        //JGSLog(@"%@", @(JGSLogModeFunc));
        //JGSLog(@"%@", @(JGSLogModeFile));
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@"（type: %@）", @(JGSEnableLogMode)];
    }
    
#ifdef JGS_Category_UIColor
    cell.backgroundColor = JGSColorHex(arc4random() % 0x01000000);
    cell.contentView.backgroundColor = JGSColorHex(0xffffff);
#endif
    
    return cell;
}

#pragma mark - Action
- (void)showLogModeList {
    
#ifdef JGS_Category_UIAlertController
    JGSWeakSelf
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
            
#ifdef JGS_Category_UIApplication
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            JGSLog(@"key: %p", [UIApplication sharedApplication].keyWindow);
            JGSLog(@"window: %p", [UIApplication sharedApplication].delegate.window);
            
#ifdef JGS_Category_UIApplication
            JGSLog(@"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSLog(@"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        });
    }];
#endif
}

#pragma mark -
#pragma mark - DataStorage
- (void)jumpToDataStorageDemo {
    
    JGSDemoViewController *vcT = [[JGSDemoViewController alloc] init];
    vcT.title = @"Data Storage";
    vcT.tableSectionData = @[
        JGSDemoTableSectionMake(@" UserDefaults",
                                @[
                                ]),
    ];
    
    [self.navigationController pushViewController:vcT animated:YES];
}

#pragma mark - Device
- (void)jumpToDeviceDemo {
    
#ifdef JGS_Device
    printf("0x%x\n", [JGSDevice isDeviceJailbroken]);
    printf("%d\n", [JGSDevice isAPPResigned:@[@"Z28L6TKG58"]]);
    printf("%d\n", [JGSDevice isSimulator]);
    
    JGSLog(@"sysUserAgent: %@", [JGSDevice sysUserAgent]);
    JGSLog(@"%@", [JGSDevice appInfo]);
    //JGSLog(@"%@", [JGSDevice deviceInfo]);
    JGSLog(@"%@", [JGSDevice deviceMachine]);
    JGSLog(@"%@", [JGSDevice deviceModel]);
    JGSLog(@"%@", [JGSDevice appUserAgent]);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    JGSLog(@"%@", [JGSDevice idfa]);
    //});
    
    // iOS 15不弹窗问题，位置修改到此处
    //dispatch_async(dispatch_get_main_queue(), ^{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    JGSLog(@"idfa: %@", [JGSDevice idfa]);
    JGSLog(@"deviceId: %@", [JGSDevice deviceId]);
    //    JGSLog(@"%@", [JGSDevice idfa]);
    //});
#endif
}

#pragma mark - Encryption
- (void)jumpToEncryptionDemo {
    
    JGSDemoViewController *vcT = [[JGSDemoViewController alloc] init];
    vcT.title = @"Encryption";
    vcT.tableSectionData = @[
        JGSDemoTableSectionMake(nil,
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"AES加解密字符串", self, @selector(showAESEncryption:)),
                                ]),
    ];
    
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)showAESEncryption:(NSIndexPath *)indexPath {

#ifdef JGS_Encryption
    // 加解密可以和在线工具进行对比验证：https://www.qtool.net/aes
    NSString *aes128Key = @"1234567890abcdef";
    NSString *aes256Key = @"1234567890abcdef1234567890ABCDEF";

    NSString *origin = @"- (void)aesDemo:(NSIndexPath *)indexPath {";
    NSString *encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:nil];
    JGSLog(@"128 encrypt: %@", encrypt);
    JGSLog(@"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:nil]);

    encrypt = [origin jg_AES128EncryptWithKey:aes128Key iv:aes128Key];
    JGSLog(@"128 encrypt: %@", encrypt);
    JGSLog(@"128 decrypt: %@", [encrypt jg_AES128DecryptWithKey:aes128Key iv:aes128Key]);

    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:nil];
    JGSLog(@"256 encrypt: %@", encrypt);
    JGSLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:nil]);

    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:@"12345"];
    JGSLog(@"256 encrypt: %@", encrypt);
    JGSLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:@"12345"]);

    encrypt = [origin jg_AES256EncryptWithKey:aes256Key iv:aes256Key];
    JGSLog(@"256 encrypt: %@", encrypt);
    JGSLog(@"256 decrypt: %@", [encrypt jg_AES256DecryptWithKey:aes256Key iv:aes256Key]);
#endif
}

#pragma mark - Hud Loading & Toast
- (void)jumpToHudDemo {
    
    JGSDemoViewController *vcT = [[JGSDemoViewController alloc] init];
    vcT.title = @"Hud Loading & Toast";
    vcT.tableSectionData = @[
        // Section 全屏Loading
        JGSDemoTableSectionMake(@" 全屏Loading",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"Default样式", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Default样式 + Message", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Indicator样式", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Indicator样式 + Message", self, @selector(showLoadingHUD:)),
                                ]),
        // Section 全屏Loading-Custom
        JGSDemoTableSectionMake(@" 全屏Loading-Custom",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"Custom Spinning样式", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Custom Spinning样式 + Message", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Custom Spinning样式 + Message_Short", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Custom Icon 样式", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Custom Icon 样式 + Message", self, @selector(showLoadingHUD:)),
                                ]),
        // Section 全屏Loading-Custom
        JGSDemoTableSectionMake(@" 全屏Loading-无边框",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"Default 无边框", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Indicator 无边框", self, @selector(showLoadingHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Custom Icon 无边框", self, @selector(showLoadingHUD:)),
                                ]),
        // Section 全屏Toast
        JGSDemoTableSectionMake(@" 全屏Toast",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"Default样式", self, @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Top样式", self, @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Up样式", self, @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Low样式", self, @selector(showToastHUD:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Bottom样式", self, @selector(showToastHUD:)),
                                ]),
    ];
    
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)showLoadingHUD:(NSIndexPath *)indexPath {
    
    JGSLog();
#ifdef JGS_HUD_Loading
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
#ifdef JGS_Category_UIImage
                    hudImg = [hudImg jg_imageScaleAspectFit:CGSizeMake(60, 60)];
#endif
                    [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:hudImg];
                    [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:nil];
                }
                    break;
                    
                case 4: {
                    UIImage *hudImg = [UIImage imageNamed:@"AppIcon"];
#ifdef JGS_Category_UIImage
                    hudImg = [hudImg jg_imageScaleAspectFit:CGSizeMake(60, 60)];
#endif
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
#ifdef JGS_Category_UIImage
                    hudImg = [hudImg jg_imageScaleAspectFit:CGSizeMake(60, 60)];
#endif
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
#endif
}

- (void)showToastHUD:(NSIndexPath *)indexPath {
    
    JGSLog();
#ifdef JGS_HUD_Toast
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
#endif
}

#pragma mark - Reachability
- (void)jumpToReachabilityDemo {
    
#ifdef JGS_Reachability
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[JGSReachability sharedInstance] startMonitor];
        [[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {
            NSString *statusString = [[JGSReachability sharedInstance] reachabilityStatusString];
            JGSLog(@"Network status: %@", statusString);
#ifdef JGS_Category_UIAlertController
            [UIAlertController jg_alertWithTitle:@"网络变了" message:statusString cancel:@"确定"];
#endif
        }];
    });
    
    NSDictionary *netInfo = @{
        @"Reachable": [[JGSReachability sharedInstance] reachable] ? @"YES": @"NO",
        @"WiFi": [[JGSReachability sharedInstance] reachableViaWiFi] ? @"YES": @"NO",
        @"WWAN": [[JGSReachability sharedInstance] reachableViaWWAN] ? @"YES": @"NO",
        @"Network Type": [[JGSReachability sharedInstance] reachabilityStatusString],
    };
    
#ifdef JGS_Category_NSObject
    NSString *netJSON = [netInfo jg_JSONStringWithOptions:NSJSONWritingPrettyPrinted error:nil];
#else
    NSData *data = [NSJSONSerialization dataWithJSONObject:netInfo options:NSJSONWritingPrettyPrinted error:nil];
    NSString *netJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#endif
    
    [self showConsoleLog:@"%@", netJSON];
    
#endif
}

#pragma mark - SecurityKeyboard
- (void)jumpToKeyboardDemo {
    
    JGSKeyboardDemoViewController *vcT = [[JGSKeyboardDemoViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

#pragma mark -
#pragma mark - Category
- (void)jumpToCategoryAlert {
    
    JGSDemoViewController *vcT = [[JGSDemoViewController alloc] init];
    vcT.title = @"UIAlertController";
    vcT.tableSectionData = @[
        // Section Base
        JGSDemoTableSectionMake(@" Base",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"Show alerts，Last hide all", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Show alerts，Last hide one", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Alert canle & destructive", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Alert canle & other", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Alert canle & others", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Alert canle & destructive & others", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Action Sheet", self, @selector(categoryAlertDemo:)),
                                ]),
    ];
    
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)categoryAlertDemo:(NSIndexPath *)indexPath {
    
#ifdef JGS_Category_UIAlertController
    switch (indexPath.section) {
        case 0: {
            
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
                    
                case 6: {
                    
                    // Action Sheet
                    static BOOL withCancel = YES;
                    [UIAlertController jg_actionSheetWithTitle:@"Title" message:@"Message" cancel:(withCancel ? @"Cancel" : nil) destructive:@"Destructive" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        withCancel = !withCancel;
                    }];
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
#endif
}

#pragma mark - Category
- (void)jumpToCategoryDemo {
    
    JGSDemoViewController *vcT = [[JGSDemoViewController alloc] init];
    vcT.title = @"Category";
    vcT.tableSectionData = @[
        // Section 字典取值
        JGSDemoTableSectionMake(@" 字典取值",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"Get Number", self, @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Get Array", self, @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Get Dictionary", self, @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"Get Object", self, @selector(dictionaryGetValue:)),
                                ]),
        // Section 字符串URL处理
        JGSDemoTableSectionMake(@" 字符串URL处理",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"字符串URL编码", self, @selector(string2URL:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"字符串中文字符处理", self, @selector(string2URL:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"字符串query不合规范处理", self, @selector(string2URL:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"URL Query字典", self, @selector(string2URL:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"URL Query参数值", self, @selector(string2URL:)),
                                ]),
        // Section 对象转JSON、字典
        JGSDemoTableSectionMake(@" 对象转JSON、字典",
                                @[
                                    JGSDemoTableRowMakeWithObjectSelector(@"JSON对象转JSON字符串", self, @selector(object2JSONDictionary:)),
                                    JGSDemoTableRowMakeWithObjectSelector(@"JSON字符串转JSON对象", self, @selector(object2JSONDictionary:)),
                                ]),
    ];
    
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)dictionaryGetValue:(NSIndexPath *)indexPath {
    
#ifdef JGS_Category_NSObject
    NSMutableDictionary *tmp = @{@"NullKey1": [NSNull null], @"NullKey2": [NSNull null]}.mutableCopy;
    JGSLog(@"%@", [tmp objectForKey:@"NullKey1"]);
    JGSLog(@"%@", tmp[@"NullKey2"]);
    tmp[@"Nullkey3"] = [NSNull null];
    JGSLog(@"%@", tmp.jg_JSONString);
    tmp[@"Nullkey3"] = nil;
    JGSLog(@"%@", tmp.jg_JSONString);
    [tmp setObject:[NSNull null] forKey:@"Nullkey4"];
    JGSLog(@"%@", tmp.jg_JSONString);
    [tmp setObject:nil forKey:@"Nullkey4"];
    JGSLog(@"%@", tmp.jg_JSONString);
#endif
    
#ifdef JGS_Category_NSDictionary
    static NSDictionary *storeDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeDictionary = @{
            //@"NumberVale1": @{@"key": @"v"},//@"655381234567890",
            @"NumberVale1": @"true",//@"655381234567890",
            //@"NumberVale1": @"NO",//@"655381234567890",
            //@"NumberVale1": @"655381234567890",
            @"NumberVale2": @(1989.55),
            @"StringVale": @"AB090BA",
            @"ArrayValue": @[@"Array Value 1", @"Array Value 2"],
            @"Dictionary": @{@"Key 1": @"Value 1", @"Key 2": @"Value 2"},
        };
    });
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            JGSLog(@"%@", [storeDictionary jg_numberForKey:@"NumberVale1"]);
            JGSLog(@"%ud", [storeDictionary jg_shortForKey:@"NumberVale1"]);
            JGSLog(@"%zd", [storeDictionary jg_integerForKey:@"NumberVale1"]);
            JGSLog(@"%ld", [storeDictionary jg_longForKey:@"NumberVale1"]);
            JGSLog(@"%f", [storeDictionary jg_floatForKey:@"NumberVale1"]);
            JGSLog(@"%d", [storeDictionary jg_boolForKey:@"NumberVale1"]);
            JGSLog(@"%lf", [storeDictionary jg_CGFloatForKey:@"NumberVale1"]);
            JGSLog(@"%ud", [storeDictionary jg_unsignedIntForKey:@"NumberVale1"]);
            
            JGSLog(@"%zd", [storeDictionary jg_integerForKey:@"NumberVale2"]);
            JGSLog(@"%zd", [storeDictionary jg_integerForKey:@"StringVale"]);
            JGSLog(@"%zd", [storeDictionary jg_integerForKey:@"ArrayValue"]);
            JGSLog(@"%zd", [storeDictionary jg_integerForKey:@"Dictionary"]);
        }
            break;
            
        case 1: {
            
            JGSLog(@"%@", [storeDictionary jg_arrayForKey:@"NumberVale1"]);
            JGSLog(@"%@", [storeDictionary jg_arrayForKey:@"NumberVale2"]);
            JGSLog(@"%@", [storeDictionary jg_arrayForKey:@"StringVale"]);
            JGSLog(@"%@", [storeDictionary jg_arrayForKey:@"ArrayValue"]);
            JGSLog(@"%@", [storeDictionary jg_arrayForKey:@"Dictionary"]);
        }
            break;
            
        case 2: {
            
            JGSLog(@"%@", [storeDictionary jg_dictionaryForKey:@"NumberVale1"]);
            JGSLog(@"%@", [storeDictionary jg_dictionaryForKey:@"NumberVale2"]);
            JGSLog(@"%@", [storeDictionary jg_dictionaryForKey:@"StringVale"]);
            JGSLog(@"%@", [storeDictionary jg_dictionaryForKey:@"ArrayValue"]);
            JGSLog(@"%@", [storeDictionary jg_dictionaryForKey:@"Dictionary"]);
        }
            break;
            
        case 3: {
            
            JGSLog(@"%@", [storeDictionary jg_objectForKey:@"NumberVale1"]);
            JGSLog(@"%@", [storeDictionary jg_objectForKey:@"NumberVale2"]);
            JGSLog(@"%@", [storeDictionary jg_objectForKey:@"StringVale"]);
            JGSLog(@"%@", [storeDictionary jg_objectForKey:@"ArrayValue"]);
            JGSLog(@"%@", [storeDictionary jg_objectForKey:@"Dictionary"]);
        }
            break;
            
        default:
            break;
    }
#endif
}

- (void)string2URL:(NSIndexPath *)indexPath {
    
#ifdef JGS_Category_NSURL
#pragma mark - URL
    NSString *urlStr = @"tpybxsit://m.baidu.com/s?from=1000539d&word=%E8%92%9C%E8%93%89%E8%99%BE%E7%9A%84%E5%81%9A%E6%B3%95";
    NSURL *URL = urlStr.jg_URL;
    JGSLog(@"%@， %@", URL.jg_queryItems, URL.jg_queryParams);
    
    urlStr = @"tpybxsit://m.baidu.com/s%3Ffrom=1000539d&word=蒜蓉虾的做法";
    URL = urlStr.jg_URL;
    JGSLog(@"%@， %@", URL.jg_queryItems, URL.jg_queryParams);
#endif
    
#ifdef JGS_Category_NSString
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            NSArray<NSString *> *oriStrs = @[@":", @"#", @"[", @"]", @"@", @"!", @"$", @"&", @"'", @"(", @")", @"*", @"+", @",", @";", @"="];
            [oriStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSLog(@"Encode %@ -> %@", obj, obj.jg_URLEncodeString);
            }];
        }
            break;
            
        case 1: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        case 2: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        case 3: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=&key2=Key&key3= &key4=Key4&key1=&key1=好";
            NSURL *URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\n%@", [URL jg_queryParams]);
            
            urlStr = @"https://www.baidu.com/search?key1=%E4%BD%A0%E5%A5%BD";
            URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\n%@", [URL jg_queryParams]);
        }
            break;
            
        case 4: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你 Hello 好%5B中括号%5D";
            NSURL *URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\nkey1: %@", [URL jg_queryForKey:@"key1"]);
        }
            break;
            
        default:
            break;
    }
#endif
}

- (void)object2JSONDictionary:(NSIndexPath *)indexPath {
#ifdef JGS_Category_NSObject
    static NSDictionary *storeDictionary = nil;
    static NSString *storeString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        storeDictionary = @{
                            @"NumberVale1": @"655381234567890",
                            @"NumberVale2": @(1989.55),
                            @"StringVale": @"AB090BA",
                            @"ArrayValue": @[@"Array Value 1", @"Array Value 2"],
                            @"Dictionary": @{@"Key 1": @"Value 1", @"Key 2": @"Value 2"},
                            };
        storeString = [storeDictionary jg_JSONString];
    });
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            JGSLog(@"Model to JSON : %@", [storeDictionary jg_JSONString]);
            id object = [storeDictionary jg_JSONObjectWithOptions:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments) error:nil];
            JGSLog(@"Model to Mutable : %@", object);
        }
            break;
            
        case 1: {
            
            JGSLog(@"Model to JSON : %@", [storeString jg_JSONObject]);
        }
            break;
            
        default:
            break;
    }
#endif
}

#pragma mark - End

@end
