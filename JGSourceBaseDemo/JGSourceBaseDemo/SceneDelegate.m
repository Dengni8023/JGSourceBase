//
//  SceneDelegate.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/12/9.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "SceneDelegate.h"
#import "ViewController.h"
@import JGSourceBase;

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    JGSLog();
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (windowScene) {
        
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        self.window.frame = windowScene.screen.bounds;
        
        ViewController *vcT = [[ViewController alloc] init];
        JGSDemoNavigationController *nav = [[JGSDemoNavigationController alloc] initWithRootViewController:vcT];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    }
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    JGSLog();
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    JGSLog(@"");
    
    static NSInteger times = 0;
    [JGSLogger enableLogWithMode:JGSLogModeFunc level:JGSLogger.level useNSLog:times++ % 3 == 2 lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    
#ifdef JGSIntegrityCheck_h
    [[JGSIntegrityCheckResourcesHash shareInstance] setCheckInfoPlistKeyBlacklist:@[
        @"MinimumOSVersion", // 该字段在Xcode 13.0打包时工具添加，经验证配置最低支持11.0时，打包为11.0，但TestFlight测试发现修改为15.0
        @"CFBundleURLTypes.CFBundleURLName", //
        @"NSAppTransportSecurity.NSAllowsArbitraryLoads"
    ]];
    [[JGSIntegrityCheckResourcesHash shareInstance] setCheckFileExtesionBlacklist:@[
#ifdef DEBUG
        @"dylib" // 调试会添加预览相关 dylib
#endif
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

- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    JGSLog();
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    JGSLog();
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    JGSLog();
}


@end
