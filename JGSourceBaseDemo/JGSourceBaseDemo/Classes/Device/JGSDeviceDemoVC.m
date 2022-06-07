//
//  JGSDeviceDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/5/31.
//

#import "JGSDeviceDemoVC.h"

@interface JGSDeviceDemoVC ()

@end

@implementation JGSDeviceDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = @"Device";
}

#ifdef JGSDevice_h
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.textView.text = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	JGSDemoShowConsoleLog(self, @"设备越狱检测：%d\n", [JGSDevice isDeviceJailbroken] == JGSDeviceJailbrokenIsBroken);
	JGSDemoShowConsoleLog(self, @"%d\n", [JGSDevice isAPPResigned:@[@"Z28L6TKG58"]]);
	JGSDemoShowConsoleLog(self, @"%d\n", [JGSDevice isSimulator]);
	
	JGSDemoShowConsoleLog(self, @"sysUserAgent: %@", [JGSDevice sysUserAgent]);
	JGSDemoShowConsoleLog(self, @"%@", [JGSDevice appInfo]);
	//JGSDemoShowConsoleLog(self, @"%@", [JGSDevice deviceInfo]);
	JGSDemoShowConsoleLog(self, @"%@", [JGSDevice deviceMachine]);
	JGSDemoShowConsoleLog(self, @"%@", [JGSDevice deviceModel]);
	JGSDemoShowConsoleLog(self, @"%@", [JGSDevice appUserAgent]);
	//dispatch_async(dispatch_get_main_queue(), ^{
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	JGSDemoShowConsoleLog(self, @"%@", [JGSDevice idfa]);
	//});
	
	// iOS 15不弹窗问题，位置修改到此处
	//dispatch_async(dispatch_get_main_queue(), ^{
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	JGSDemoShowConsoleLog(self, @"idfa: %@", [JGSDevice idfa]);
	JGSDemoShowConsoleLog(self, @"deviceId: %@", [JGSDevice deviceId]);
	//    JGSDemoShowConsoleLog(self, @"%@", [JGSDevice idfa]);
	//});
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#endif

@end
