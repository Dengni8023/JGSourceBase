//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "ViewController.h"
#import "JGSCategoryDemoVC.h"
#import "JGSDataStorageDemoVC.h"
#import "JGSDeviceDemoVC.h"
#import "JGSEncryptionDemoVC.h"
#import "JGSHUDDemoVC.h"
#import "JGSReachabilityDemoVC.h"
#import "JGSKeyboardDemoVC.h"
#import <AdSupport/ASIdentifierManager.h>
#import "JGSourceBaseDemo-Swift.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	self.subTitle = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    UIImage *logo = [JGSBaseUtils imageInResourceBundle:@"source_logo-29"];
    if (@available(iOS 14.0, *)) {
        JGSWeakSelf
        UIAction *toSwiftDemoAction = [UIAction actionWithTitle:@"Swift Demo" image:logo identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            JGSStrongSelf
            [self jumpToSwiftDemo:action];
        }];
        UIMenu *menu = [UIMenu menuWithTitle:@"页面导航" children:@[toSwiftDemoAction]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:logo menu:menu];
    } else {
        // Fallback on earlier versions
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ToSwift" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToSwiftDemo:)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //static BOOL enableJGSLog = NO;
    //enableJGSLog = !enableJGSLog;
    //[JGSLogFunction enableLog:enableJGSLog];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    JGSLogWithFormat(@"%@, %@, %@", @"Test2", nil, @"Test1");
    JGSLogWithFormat(@"%@, %@, %@, %d, %.1f, 0x%X", @"Test2", nil, @"Test1", 12, 12.f, 0xff);
    
//    JGSConsoleLogWithNSLog(YES);
    NSString *message = @"Git•GitHub";
    NSLog(@"%@: %@", @(__LINE__), message);
    JGSLog(@"%@", message);
    NSLog(@"%@: %s", @(__LINE__), [message UTF8String]);
    JGSLog(@"%s", [message UTF8String]);
    //NSString *log = [NSString stringWithCString:[message UTF8String] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@: %@", @(__LINE__), log);
    //JGSLog(@"%@", log);
    //NSLog(@"%@: %s", @(__LINE__), [log UTF8String]);
    //JGSLog(@"%s", [log UTF8String]);
    //
    //const char *filePath = __FILE__;
    //JGSLog(@"%s", filePath);
    //NSLog(@"%s", filePath);
    //JGSLog(@"%@", [NSString stringWithFormat:@"%s", filePath]);
    //JGSLog(@"%@", [[NSString alloc] initWithFormat:@"%s", filePath]);
    //JGSLog(@"%@", [NSString stringWithCString:filePath encoding:NSUTF8StringEncoding]);
    //JGSLog(@"%s", [[NSString stringWithCString:filePath encoding:NSUTF8StringEncoding] UTF8String]);
    //JGSLog(@"%@", [NSString stringWithCString:[[NSString stringWithCString:filePath encoding:NSUTF8StringEncoding] UTF8String] encoding:NSUTF8StringEncoding]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
	return @[
		// 基础组件
		JGSDemoTableSectionMake(@" 基础组件",
		@[
			JGSDemoTableRowMake(@"调试日志控制-Alert扩展", nil, @selector(showLogModeList:))
		]),
		// 功能组
		JGSDemoTableSectionMake(@" 功能组件",
		@[
			JGSDemoTableRowMake(@"Category Demo", nil, @selector(jumpToCategoryDemo:)),
			JGSDemoTableRowMake(@"DataStorage Demo", nil, @selector(jumpToDataStorageDemo:)),
			JGSDemoTableRowMake(@"Device Demo", nil, @selector(jumpToDeviceDemo:)),
			JGSDemoTableRowMake(@"Encryption Demo", nil, @selector(jumpToEncryptionDemo:)),
			JGSDemoTableRowMake(@"HUD（Loading、Toast）", nil, @selector(jumpToHudDemo:)),
			JGSDemoTableRowMake(@"Reachability", nil, @selector(jumpToReachabilityDemo:)),
			JGSDemoTableRowMake(@"Security Keyboard", nil, @selector(jumpToKeyboardDemo:)),
		]),
	];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@"（type: %@）", @(JGSEnableLogMode)];
    }
    
    return cell;
}

#pragma mark - Action
- (void)jumpToSwiftDemo:(id)sender {
    
    JGSDemoShowConsoleLog(self, @"%@", sender);
#if __has_include("JGSourceBaseDemo-Swift.h")
    SwiftViewController *swiftCtr = [[SwiftViewController alloc] init];
    [self.navigationController pushViewController:swiftCtr animated:YES];
#endif
}

- (void)showLogModeList:(NSIndexPath *)indexPath {
    
    JGSDemoShowConsoleLog(self, @"");
#ifdef JGSCategory_UIAlertController_h
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
        
        JGSWeakSelf
        [UIAlertController jg_alertWithTitle:@"日志输出设置" message:types[selIdx] cancel:@"确定" action:^(UIAlertController * _Nonnull _alert, NSInteger _idx) {
            
            JGSStrongSelf
            JGSDemoShowConsoleLog(self, @"<%@: %p> %@", NSStringFromClass([_alert class]), _alert, @(_idx));
            
#ifdef JGSCategory_UIApplication
            JGSDemoShowConsoleLog(self, @"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSDemoShowConsoleLog(self, @"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            JGSStrongSelf
            JGSDemoShowConsoleLog(self, @"key: %p", [UIApplication sharedApplication].keyWindow);
            JGSDemoShowConsoleLog(self, @"window: %p", [UIApplication sharedApplication].delegate.window);
            
#ifdef JGSCategory_UIApplication
            JGSDemoShowConsoleLog(self, @"top: %@", [[UIApplication sharedApplication] jg_topViewController]);
            JGSDemoShowConsoleLog(self, @"visiable: %@", [[UIApplication sharedApplication] jg_visibleViwController]);
#endif
        });
    }];
#endif
}

- (void)jumpToCategoryDemo:(NSIndexPath *)indexPath {
	
    JGSCategoryDemoVC *vcT = [[JGSCategoryDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToDataStorageDemo:(NSIndexPath *)indexPath {
	
    JGSDataStorageDemoVC *vcT = [[JGSDataStorageDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToDeviceDemo:(NSIndexPath *)indexPath {

	JGSDeviceDemoVC *vcT = [[JGSDeviceDemoVC alloc] init];
	[self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToEncryptionDemo:(NSIndexPath *)indexPath {
	
    JGSEncryptionDemoVC *vcT = [[JGSEncryptionDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToHudDemo:(NSIndexPath *)indexPath {

    JGSHUDDemoVC *vcT = [[JGSHUDDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)jumpToReachabilityDemo:(NSIndexPath *)indexPath {
	
	JGSReachabilityDemoVC *vcT = [[JGSReachabilityDemoVC alloc] init];
	[self.navigationController pushViewController:vcT animated:YES];
    
#ifdef JGSReachability_h
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [[JGSReachability sharedInstance] startMonitor];

        JGSWeakSelf
        [[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {

            JGSStrongSelf
            NSString *statusString = [[JGSReachability sharedInstance] reachabilityStatusString];
            JGSDemoShowConsoleLog(self, @"Network status: %@", statusString);
#ifdef JGSCategory_UIAlertController_h
            [UIAlertController jg_alertWithTitle:@"网络变了" message:statusString cancel:@"确定"];
#endif
        }];
    });
#endif
}

- (void)jumpToKeyboardDemo:(NSIndexPath *)indexPath {
    
    JGSKeyboardDemoVC *vcT = [[JGSKeyboardDemoVC alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

#pragma mark - End

@end


@implementation NSJSONSerialization (JGSourceBaseDemo)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        NSArray<NSString *> *originalArray = @[
            NSStringFromSelector(@selector(JSONObjectWithData:options:error:)),
        ];
        
        [originalArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            SEL originSelector = NSSelectorFromString(obj);
            SEL swizzledSelector = NSSelectorFromString([@"JGSDemo_" stringByAppendingString:obj]);
            JGSRuntimeSwizzledClassMethod(class, originSelector, swizzledSelector);
        }];
    });
}

+ (id)JGSDemo_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSError *err = nil;
    id ret = [self JGSDemo_JSONObjectWithData:data options:opt error:&err];
    if (err) {
        if (error) {
            *error = err;
        }
    }
    //JGSLog(@"%@", ret);
    return ret;
}

@end
