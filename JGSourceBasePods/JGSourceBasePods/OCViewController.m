//
//  OCViewController.m
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/18.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "OCViewController.h"
#ifdef JGS_DEMO_TARGET_FRM
#import "JGSourceBaseDemo-Swift.h"
#endif
#ifdef JGS_DEMO_TARGET_Pods
#import "JGSourceBasePods-Swift.h"
#endif
@import JGSourceBase;
#import <Masonry/Masonry.h>
#import "JGSDAlertController.h"

@interface OCDetailViewController ()

- (void)splitPrimaryViewController:(JGSDViewController *)primaryViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface OCViewController () <UISplitViewControllerDelegate>

@property (nonatomic, strong) OCPrimaryViewController *primaryCtr;
@property (nonatomic, strong) OCDetailViewController *detailCtr;

@end

@implementation OCViewController

- (instancetype)init {
    
    if (@available(iOS 14.0, *)) {
        if (self = [super initWithStyle:UISplitViewControllerStyleDoubleColumn]) {
            self.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
            self.preferredSplitBehavior = UISplitViewControllerSplitBehaviorTile;
        }
    } else {
        if (self = [super initWithNibName:nil bundle:nil]) {
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        }
    }
    self.primaryBackgroundStyle = UISplitViewControllerBackgroundStyleNone;
    
    JGSDNavigationController *primaryNav = [[JGSDNavigationController alloc] initWithRootViewController:self.primaryCtr];
    JGSDNavigationController *detailNav = [[JGSDNavigationController alloc] initWithRootViewController:self.detailCtr];
    self.viewControllers = @[primaryNav, detailNav];
    super.delegate = self;
    
    return self;
}

- (void)dealloc {
    JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (OCPrimaryViewController *)primaryCtr {
    if (_primaryCtr) {
        return  _primaryCtr;
    }
    
    OCPrimaryViewController *vcT = [[OCPrimaryViewController alloc] init];
    
    return _primaryCtr = vcT;
}

- (OCDetailViewController *)detailCtr {
    if (_detailCtr) {
        return  _detailCtr;
    }
    
    OCDetailViewController *vcT = [[OCDetailViewController alloc] init];
    
    return _detailCtr = vcT;
}

// MAKR: - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JGSReachability.shared/*sharedInstance*/ addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {
        JGSLog(@"Network status changed: %@, %@", @(status), JGSReachability.shared/*sharedInstance*/.reachabilityStatusString)
    }];
    
    [JGSReachability.shared/*sharedInstance*/ addObserver:self selector:@selector(networkReachabilityStatusChanged:)];
    [NSNotificationCenter.defaultCenter addObserverForName:JGSReachabilityStatusChangedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        NSNumber *notiStatus = notification.userInfo[JGSReachabilityNotificationStatusKey];
        if (notiStatus) {
            JGSReachabilityStatus status = [notiStatus integerValue];
            JGSLog(@"Network status changed: %@ %@, %@", @(status), @(JGSReachability.shared/*sharedInstance*/.reachabilityStatus), JGSReachability.shared/*sharedInstance*/.reachabilityStatusString)
        } else {
            JGSLog(@"Network status changed: %@, %@", @(JGSReachability.shared/*sharedInstance*/.reachabilityStatus), JGSReachability.shared/*sharedInstance*/.reachabilityStatusString)
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JGSLog(@"%@", JGSourceBaseVersion());
    JGSLog(@"%@", [JGSBaseUtils classBundle]);
    JGSLog(@"%@", [JGSBaseUtils resourceBundle]);
    JGSLog(@"%@", [JGSBaseUtils sdkVersion]);
}

// MARK: - Action
- (void)networkReachabilityStatusChanged:(JGSReachability *)sender {
    JGSReachability *reachability = sender ?: JGSReachability.shared/*sharedInstance*/;
    JGSLog(@"Network status changed: %@, %@, %@", sender, @(reachability.reachabilityStatus), reachability.reachabilityStatusString)
    
    switch (reachability.reachabilityStatus) {
        case JGSReachabilityStatusUnknown:
        case JGSReachabilityStatusUnreachable:
            break;
        case JGSReachabilityStatusWiFi:
            break;
        case JGSReachabilityStatusWWAN:
        case JGSReachabilityStatusWWANGPRS:
        case JGSReachabilityStatusWWAN2G:
        case JGSReachabilityStatusWWAN3G:
        case JGSReachabilityStatusWWAN4G:
        case JGSReachabilityStatusWWAN5G:
            break;
        case JGSReachabilityStatusWired:
            break;
    }
}

// MARK: - UISplitViewControllerDelegate
- (UISplitViewControllerColumn)splitViewController:(UISplitViewController *)svc topColumnForCollapsingToProposedTopColumn:(UISplitViewControllerColumn)proposedTopColumn API_AVAILABLE(ios(14.0)) {
    return  UISplitViewControllerColumnPrimary;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController API_AVAILABLE(ios(14.0))  {
    return YES;
}

// MARK: - SplitPrimaryViewControllerAction
- (UINavigationController *)jgsd_navigationController {
    return (self.isCollapsed ? self.primaryCtr : self.detailCtr).navigationController;
}

- (void)jumpToAlertControllerDemo:(NSIndexPath *)indexPath {
    JGSDAlertController *vcT = [[JGSDAlertController alloc] init];
    [self.jgsd_navigationController jgsd_replaceViewController:vcT];
}

@end

@implementation OCPrimaryViewController

// MARK: - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if (@available(iOS 14, *)) {
        UIImage *img = [JGSBaseUtils imageInResourceBundle:@[
            // @"AppIcon",
            @"icon_29",
            @"assest_icon_29",
            @"bundle_icon_29",
            @"bundle_assest_icon_29",
        ][arc4random() % 4]];
        JGSWeakSelf
        UIAction *ocDemo = [UIAction actionWithTitle:@"Swift" image:img identifier:nil handler:^(__kindof UIAction *_Nonnull action) {
            JGSStrongSelf
            [self jump2SwiftDemo:action];
        }];
        UIMenu *menu = [UIMenu menuWithTitle:@"跳转Swift页面" children:@[ocDemo]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Swift" menu:menu];
    } else {
        UIBarButtonItem *ocDemo = [[UIBarButtonItem alloc] initWithTitle:@"Swift" style:UIBarButtonItemStylePlain target:self action:@selector(jump2SwiftDemo:)];
        self.navigationItem.leftBarButtonItem = ocDemo;
    }
    
    if (self.splitViewController.isCollapsed) {
        UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(toAbout:)];
        self.navigationItem.rightBarButtonItem = about;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JGSDShowConsoleLog(self, @"%@", [[NSDate alloc] init])
}

// MARK: - Data
- (void)loadData {
    
    JGSWS
    NSArray<JGSDTableSectionData *> *sections = @[
        [
            JGSDTableSectionData sectionWithTitle:@"基础组件" rows:@[
            [JGSDTableCellData dataWithTitle:@"调试日志控制" target:self selector:@selector(showLogModeList:)],
            [JGSDTableCellData dataWithTitle:@"UIAlertController" action:^(NSIndexPath * _Nonnull indexPath) {
                JGSSS
                [(OCViewController *)self.splitViewController jumpToAlertControllerDemo:indexPath];
            }],
        ]],
        [
            JGSDTableSectionData sectionWithTitle:@"安全组件" rows:@[
            [JGSDTableCellData dataWithTitle:@"代理检测" target:self selector:@selector(checkProxyEnabled:)],
        ]],
    ];
    [self setupData:sections rows:nil];
}

// MARK: - Action
- (void)jump2SwiftDemo:(id)sender {
    //    JGSDShowConsoleLog[(self, sender)
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)toAbout:(id)sender {
    // 跳转关于页面
    UIViewController *vcT = [[JGSDAboutViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)showLogModeList:(NSIndexPath *)indexPath {
    JGSDShowConsoleLog(self, "indexPath: %@", indexPath)
    
    JGSWeakSelf
    NSArray<NSString *> *types = @[@"Log disable", @"Log only", @"Log with function line", @"Log with file function line"];
    [UIAlertController jg_showAlertWithTitle:@"选择日志类型" message:nil style:arc4random() % 2 ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet cancel:@"取消" destructive:nil others:types action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
        JGSStrongSelf
        JGSDShowConsoleLog(self, @"<%@: %p)> %@", NSStringFromClass(alert.class), alert, @(idx))
        if (idx == alert.jg_cancelIdx) {
            return;
        }
        
        // 日志输出 mode 修改
        NSInteger selIdx = idx - alert.jg_firstOtherIdx;
        [JGSLogger enableLogWithMode:JGSLogModeNone + selIdx];
        [self.tableView reloadData];
        
        // 提示日志mode
        JGSWeakSelf
        [UIAlertController jg_alertWithTitle:@"日志输出设置" message:types[selIdx] cancel:@"确定" action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
            JGSStrongSelf
            JGSDShowConsoleLog(self, @"<%@: %p)> %@", NSStringFromClass(alert.class), alert, @(idx))
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIAlertController jg_hideCurrent];
        });
    }];
}

- (void)checkProxyEnabled:(id)sender {
    
    if ([JGSProxyDetector proxyEnabledTypes] == kNilOptions) {
        [self jg_alertWithTitle:nil message:@"未设置网络代理" cancel:@"确定" destructive:nil others:@[] action:nil];
        return;
    }
    
    [self jg_alertWithTitle:@"安全警告" message:@"已设置网络代理，请注意使用安全" cancel: @"确定" destructive:nil others:@[] action:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *domain in @[@"https://m.baidu.com", @"http://m.baidu.com", @"https://jd.com"]) {
            
            if (arc4random() % 2 == 0) {
                NSURL *url = [NSURL URLWithString:domain];
                JGSDShowConsoleLog(self, @"isProxyEnabled for %@: %zd", domain, [JGSProxyDetector proxyEnabledTypesForURL:url]);
            } else {
                JGSDShowConsoleLog(self, @"isProxyEnabled for %@: %zd", domain, [JGSProxyDetector proxyEnabledTypesFor:domain]);
            }
        }
    });
}

// MARK: - Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    JGSDTableCellData *rowData = self.sections.count > 0 ? self.sections[indexPath.section].rows[indexPath.row] : self.rows[indexPath.row];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    // 日志
                    NSDictionary<NSNumber *, NSString *> *modeMap = @{
                        @(JGSLogModeNone): @"none - 不打印日志",
                        @(JGSLogModeLog): @"log - 仅日志",
                        @(JGSLogModeFunc): @"func - 方法名、行号、日志",
                        @(JGSLogModeFile): @"file - 文件名、方法名、行号、日志",
                    };
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", rowData.title, modeMap[@(JGSLogger.mode)] ? : @""];
                }
                    
                default:
                    break;
            }
            
        default:
            break;
    }
    
    return cell;
}

@end

@implementation OCDetailViewController

// MARK: - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.splitViewController.isCollapsed) {
        UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(toAbout:)];
        self.navigationItem.rightBarButtonItem = about;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //        showConsoleLog(Date())
}

// MARK: - Split
- (void)splitPrimaryViewController:(JGSDViewController *)primaryViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JGSLog(@"primaryViewController didSelectRowAt indexPath: %@", indexPath)
}

// MAR: - Action
- (void)toAbout:(id)sender {
    // 跳转关于页面
    UIViewController *vcT = [[JGSDAboutViewController alloc] init];
    [self.navigationController pushViewController:vcT animated:YES];
}

@end
