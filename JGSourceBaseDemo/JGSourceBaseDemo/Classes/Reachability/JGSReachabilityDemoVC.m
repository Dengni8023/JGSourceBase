//
//  JGSReachabilityDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/5/31.
//

#import "JGSReachabilityDemoVC.h"

@interface JGSReachabilityDemoVC ()

@property (nonatomic, weak) UILabel *infoLabel;

@end

@implementation JGSReachabilityDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = @"Reachability";
	
#ifdef JGSReachability_h
    
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
    
	JGSWeakSelf
	[[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {
		
		JGSStrongSelf
		NSString *statusString = [[JGSReachability sharedInstance] reachabilityStatusString];
		JGSDemoShowConsoleLog(self, @"Network status: %@", statusString);
	}];
#endif
}

#ifdef JGSReachability_h
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.textView.text = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSDictionary *infoDict = @{
		@"Reachable": [[JGSReachability sharedInstance] reachable] ? @"YES": @"NO",
		@"WiFi": [[JGSReachability sharedInstance] reachableViaWiFi] ? @"YES": @"NO",
		@"WWAN": [[JGSReachability sharedInstance] reachableViaWWAN] ? @"YES": @"NO",
		@"Network Type": [[JGSReachability sharedInstance] reachabilityStatusString],
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
