//
//  JGSReachabilityDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/5/31.
//

#import "JGSReachabilityDemoVC.h"

@interface JGSReachabilityDemoVC ()

@end

@implementation JGSReachabilityDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = @"Reachability";
	
#ifdef JGSReachability_h
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
	
	NSDictionary *netInfo = @{
		@"Reachable": [[JGSReachability sharedInstance] reachable] ? @"YES": @"NO",
		@"WiFi": [[JGSReachability sharedInstance] reachableViaWiFi] ? @"YES": @"NO",
		@"WWAN": [[JGSReachability sharedInstance] reachableViaWWAN] ? @"YES": @"NO",
		@"Network Type": [[JGSReachability sharedInstance] reachabilityStatusString],
	};
	
#ifdef JGSCategory_NSObject
	NSString *netJSON = [netInfo jg_JSONStringWithOptions:NSJSONWritingPrettyPrinted error:nil];
#else
	NSData *data = [NSJSONSerialization dataWithJSONObject:netInfo options:NSJSONWritingPrettyPrinted error:nil];
	NSString *netJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#endif
	
	JGSDemoShowConsoleLog(self, @"%@", netJSON);
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
