//
//  JGSDeviceDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/5/31.
//

#import "JGSDeviceDemoVC.h"

@interface JGSDeviceDemoVC ()

@property (nonatomic, weak) UILabel *infoLabel;

@end

@implementation JGSDeviceDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = @"Device";
    
#ifdef JGSDevice_h
    UILabel *infoLabel = [[UILabel alloc] init];
    self.infoLabel = infoLabel;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor darkTextColor];
    infoLabel.textAlignment = NSTextAlignmentLeft;
    infoLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:infoLabel];
    
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.tableView);
        make.left.right.mas_equalTo(self.view).inset(16);
        make.top.mas_greaterThanOrEqualTo(self.tableView).offset(0);
    }];
#endif
}

#ifdef JGSDevice_h
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.textView.text = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    NSDictionary *infoDict = @{
        @"设备越狱": [JGSDevice isDeviceJailbroken] == JGSDeviceJailbrokenIsBroken ? @"YES": @"NO",
        @"APP重签名": [JGSDevice isAPPResigned:@[@"Z28L6TKG58"]] ? @"YES": @"NO",
        @"模拟器": [JGSDevice isSimulator] ? @"YES": @"NO",
        @"User-Agent system": [JGSDevice sysUserAgent],
        @"User-Agent custom": [JGSDevice appUserAgent],
        @"Device": [NSString stringWithFormat:@"%@ -> %@", [JGSDevice deviceMachine], [JGSDevice deviceModel]],
        @"device Id": [JGSDevice deviceId],
        @"device idfa": [JGSDevice idfa],
    };
    
#ifdef JGSCategory_NSObject_h
    NSString *infoJSON = [infoDict jg_JSONStringWithOptions:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:nil];
#else
    NSData *data = [NSJSONSerialization dataWithJSONObject:infoDict options:(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:nil];
    NSString *infoJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#endif
    
    //self.infoLabel.text = [NSString stringWithFormat:@"网络是否连接： %@\n网络类型: %@", [netInfo jg_stringForKey:@"Reachable"], [netInfo jg_stringForKey:@"Network Type"]];
    self.infoLabel.text = infoJSON;
    JGSDemoShowConsoleLog(self, @"%@", infoJSON);
    JGSDemoShowConsoleLog(self, @"appInfo: %@", [JGSDevice appInfo]);
    JGSDemoShowConsoleLog(self, @"deviceInfo: %@", [JGSDevice deviceInfo]);
}

#endif

@end
