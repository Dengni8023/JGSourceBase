//
//  AppDelegate.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/7/30.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "ViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "JGSourceBaseDemo-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    sleep(3);
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [JGSBaseUtils version]);
    JGSEnableLogWithMode(JGSLogModeFunc);
    [JGSLogFunction enableLog:YES];
    
    //NSLog(@"%@", @(JGSBaseVersionNumber));
    //NSLog(@"%s", JGSBaseVersionString);
    //NSLog(@"%@", [JGSourceBase sourceVersion]);
    
    JGSLog();
    // 应用启动设置及数据处理
    [self application:application launchingWithOptions:launchOptions];
    
    // 如果不需要支持 iPpad 多场景，且需要支持 iOS13 以下系统
    // 可以删除 Info.plist 中 Application Scene Manifest 配置字段
    // 并移除本文件中 UISceneSession lifecycle 相关方法
    // 1. - (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
    // 2. - (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions
    if (@available(iOS 13.0, *)) {
        // 需要 Info.plist 文件中配置 Application Scene Manifest 字段，字段说明：
        // Enable Multiple Windows：如果需要多场景（窗口），需要把此值设为YES，否则无法使用多场景，多场景目前仅限 Pad OS
        // 且 Application Session Role 下至少一项默认启动场景完整，配置值说明：
        // Configuration Name: 配置名，可理解为场景的标识符（必填项）
        // Delegate Class Name: 场景对应的代理对象类，每新建一个场景，都会创建一个新的代理对象（必填项）
        // Storyboard Name: 场景将自动生成此Storyboard里的Initial View Controller（默认视图控制器），如不设置，则需要在Scene Delegate里创建UIWindow和UIViewController对象（选填项）
        // Class Name: 自定义UIScene子类，默认为UIWindowScene，一般不需要更改（选填项）
        // ⚠️ 必填项 Configuration Name, Delegate Class Name 必须与以下方法内参数保持一致：
        // - (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
        return YES;
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGSize screenSize = screenBounds.size;
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    JGSLog(@"Screen Size: %@x%@@%@x, @%@x", @(screenSize.height), @(screenSize.width), @([UIScreen mainScreen].scale), @([UIScreen mainScreen].nativeScale));
    JGSLog(@"APP Window: %@", self.window);
    
    ViewController *vcT = [[ViewController alloc] init];
    JGSDemoNavigationController *nav = [[JGSDemoNavigationController alloc] initWithRootViewController:vcT];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application launchingWithOptions:(NSDictionary *)launchOptions {
    
    JGSLog();
    
    // IQKeyboardManager设置
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
        keyboardManager.enable = YES;
        keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
        keyboardManager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
        keyboardManager.toolbarManageBehavior = IQAutoToolbarByPosition; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
        keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
        keyboardManager.shouldShowToolbarPlaceholder = YES; // 是否显示占位文字
        keyboardManager.placeholderFont = [UIFont systemFontOfSize:16]; // 设置占位文字的字体
        keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
    });
}

/*
 iOS 13 以前应用生命周期管理
 1、应用启动
 2、前后台切换
 */
#pragma mark - UIApplication lifecycle
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    JGSLog();
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    JGSLog();
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    JGSLog();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    JGSLog();
    
    static NSInteger times = 0;
    JGSConsoleLogWithNSLog(times++ % 3 == 2);
    JGSEnableLogWithMode(JGSLogModeFunc);
	
#ifdef JGSIntegrityCheck_h
	[[JGSIntegrityCheckResourcesHash shareInstance] setCheckInfoPlistKeyBlacklist:@[
		@"MinimumOSVersion", // 该字段在Xcode 13.0打包时工具添加，经验证配置最低支持11.0时，打包为11.0，但TestFlight测试发现修改为15.0
		@"CFBundleURLTypes.CFBundleURLName", //
		@"NSAppTransportSecurity.NSAllowsArbitraryLoads"
	]];
	[[JGSIntegrityCheckResourcesHash shareInstance] checkAPPResourcesHash:^(NSArray<NSString *> * _Nullable unpassFiles, NSDictionary * _Nullable unpassPlistInfo) {
		
		JGSLog(@"%@, %@", unpassFiles, unpassPlistInfo);
		if (unpassFiles) {
			
			NSString *extraMsg = nil;
#ifdef DEBUG
			extraMsg = [NSString stringWithFormat:@"unpassFiles: %@", unpassFiles];
			if (unpassPlistInfo.count > 0) {
				extraMsg = [extraMsg stringByAppendingFormat:@"\nunpassPlistInfo: %@", unpassPlistInfo];
			}
#endif
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#ifdef JGSCategory_UIAlertController_h
				[UIAlertController jg_alertWithTitle:@"您安装的应用已损坏，存在安全隐患，请退出应用，并从官方渠道下载安装后使用！" message:extraMsg cancel:@"确定"];
#else
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您安装的应用已损坏，存在安全隐患，请退出应用，并从官方渠道下载安装后使用！" message:extraMsg preferredStyle:UIAlertControllerStyleAlert];
				[alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
					
				}]];
				[self.window.rootViewController presentViewController:alert animated:YES completion:^{
					
				}];
#endif
			});
		}
	}];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    JGSLog();
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(UIApplicationExtensionPointIdentifier)extensionPointIdentifier {
    
    // 禁用第三方键盘
    if ([extensionPointIdentifier isEqualToString:@"com.apple.keyboard-service"]) {
        return YES;
    }
    return NO;
}

/*
 iOS 13 及之后应用生命周期管理，在 SceneDelegate 实现
 */
#pragma mark - UISceneSession lifecycle
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0)) {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    JGSLog();
    
    /*
     1. 如果没有在 Info.plist 文件中配置 Application Session Role 的配置数据，或者要动态更改场景配置数据，需要实现此方法，UIKit会在创建新scene前调用此方法
     2. 方法会返回一个 UISceneConfiguration 对象，其包含其中包含场景详细信息，包括要创建的场景类型，用于管理场景的委托对象以及包含要显示的初始视图控制器的情节提要
     3. 如果未实现此方法，则必须在应用程序的 Info.plist 文件中提供 Application Session Role 场景配置数据
     
     总结：
     1. 默认在 Info.plist 中进行了配置，且不需要动态修改场景配置数据，可以不实现该方法
     2. 如果没有配置就需要实现这个方法并返回一个UISceneConfiguration对象
     
     配置参数中 Application Session Role 是个数组，每一项有四个参数:
     Configuration Name: 配置名，可理解为场景的标识符（必填项）
     Delegate Class Name: 场景对应的代理对象类，每新建一个场景，都会创建一个新的代理对象（必填项）
     Storyboard Name: 场景将自动生成此Storyboard里的Initial View Controller（默认视图控制器），如不设置，则需要在Scene Delegate里创建UIWindow和UIViewController对象（选填项）
     Class Name: 自定义UIScene子类，默认为UIWindowScene，一般不需要更改（选填项）
     
     参考：简书 - QiShare https://www.jianshu.com/p/6d6573fbd60b
     */
    // 应用程序正常退出/全部的窗口被正常关闭后再启动才会进入此方法
    // 假如activityType为空，表示是刚启动的，否则是新创建的场景
    NSString *activityType = options.userActivities.anyObject.activityType;
    Class delegateCls = nil;
    if (options.userActivities.anyObject.activityType == nil) {
        
        // ⚠️注意：
        // 配置名为 Default Configuration 的 Scene，系统会自动去调用自动创建的 SceneDelegate 这个类
        // 如果删除后手动创建 SceneDelegate 或其他自定义类，需要指定 delegateClass
        activityType = @"Default Configuration";
        delegateCls = [SceneDelegate class];
    }
    
    UISceneConfiguration *sceneConfig = [[UISceneConfiguration alloc] initWithName:activityType sessionRole:connectingSceneSession.role];
    sceneConfig.delegateClass = delegateCls;
    
    return sceneConfig;
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions API_AVAILABLE(ios(13.0)) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    JGSLog();
}

@end
