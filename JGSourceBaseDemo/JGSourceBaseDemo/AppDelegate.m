//
//  AppDelegate.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "JGSDemoNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSLog(@"APP Window: %@", _window);
    
    ViewController *vcT = [[ViewController alloc] init];
    JGSDemoNavigationController *nav = [[JGSDemoNavigationController alloc] initWithRootViewController:vcT];
    _window.rootViewController = nav;
    
    [_window makeKeyAndVisible];
    
    // IQKeyboardManager设置
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
        keyboardManager.enable = YES;
        keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
        keyboardManager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
        keyboardManager.toolbarManageBehaviour = IQAutoToolbarByPosition; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
        keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
        keyboardManager.shouldShowToolbarPlaceholder = YES; // 是否显示占位文字
        keyboardManager.placeholderFont = [UIFont systemFontOfSize:16]; // 设置占位文字的字体
        keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
    });
    
#pragma mark - URL
    NSString *urlStr = @"tpybxsit://m.baidu.com/s?from=1000539d&word=%E8%92%9C%E8%93%89%E8%99%BE%E7%9A%84%E5%81%9A%E6%B3%95";
    NSURL *URL = urlStr.jg_URL;
    JGSLog(@"%@， %@", URL.jg_queryItems, URL.jg_queryParams);
    
    urlStr = @"tpybxsit://m.baidu.com/s%3Ffrom=1000539d&word=蒜蓉虾的做法";
    URL = urlStr.jg_URL;
    JGSLog(@"%@， %@", URL.jg_queryItems, URL.jg_queryParams);
    
#pragma mark - Device
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
#endif
    
#pragma mark - Dictionary
#ifdef JGS_Category
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
    
    //sleep(3);
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    static NSInteger times = 0;
    JGSConsoleLogWithNSLog(times++ % 3 == 2);
    JGSEnableLogWithMode(JGSLogModeFunc);
    // iOS 15不弹窗问题，位置修改到此处
    //dispatch_async(dispatch_get_main_queue(), ^{
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    JGSLog(@"%@", [JGSDevice idfa]);
    //    JGSLog(@"%@", [JGSDevice idfa]);
    //});
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
