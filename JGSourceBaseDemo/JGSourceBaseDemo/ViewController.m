//
//  ViewController.m
//  JGSourceBaseDemo
//
//  Created by Mei Jigao on 2018/3/19.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "ViewController.h"
#import <JGSourceBase/JGSourceBase.h>
#import "JGDemoTableData.h"

@interface ViewController ()

@property (nonatomic, copy) NSArray<JGDemoTableSectionData *> *demoData;

@end

@implementation ViewController

#pragma mark - init & dealloc
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initDatas];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        
        [self initDatas];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self initDatas];
    }
    return self;
}

- (void)initDatas {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    _demoData = @[
                  // Section 日志
                  JGDemoTableSectionMake(@">> 日志开关、设置",
                                         @[
                                           JGDemoTableRowMakeSelector(@"选择日志输出控制模式", @selector(showLogModeList)),
                                           ]),
                  // Section 字典取值
                  JGDemoTableSectionMake(@">> 字典取值",
                                         @[
                                           JGDemoTableRowMakeSelector(@"Get Number", @selector(dictionaryGetValue:)),
                                           JGDemoTableRowMakeSelector(@"Get Array", @selector(dictionaryGetValue:)),
                                           JGDemoTableRowMakeSelector(@"Get Dictionary", @selector(dictionaryGetValue:)),
                                           JGDemoTableRowMakeSelector(@"Get Object", @selector(dictionaryGetValue:)),
                                           ]),
                  // Section 字符串URL处理
                  JGDemoTableSectionMake(@">> 字符串URL处理",
                                         @[
                                           JGDemoTableRowMakeSelector(@"字符串URL编码", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"字符串中文字符处理", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"字符串query不合规范处理", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"URL Query字典", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"URL Query参数值", @selector(string2URL:)),
                                           ]),
                  // Section 对象转JSON、字典
                  JGDemoTableSectionMake(@">> 对象转JSON、字典",
                                         @[
                                           JGDemoTableRowMakeSelector(@"JSON对象转JSON字符串", @selector(objejct2JSONDictionary:)),
                                           JGDemoTableRowMakeSelector(@"JSON字符串转JSON对象", @selector(objejct2JSONDictionary:)),
                                           ]),
                  // Section 全屏Loading HUD
                  JGDemoTableSectionMake(@">> 全屏Loading HUD",
                                         @[
                                           JGDemoTableRowMakeSelector(@"Default样式", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Default样式 + Message", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Indicator样式", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Indicator样式 + Message", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Custom Image样式", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Custom Image样式 + Message", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Custom Spinning样式", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Custom Spinning样式 + Message", @selector(showLoadingHUD:)),
                                           JGDemoTableRowMakeSelector(@"Custom Spinning样式 + Message_Short", @selector(showLoadingHUD:)),
                                           ]),
                  ];
}

- (void)dealloc {
    
    JGSLog(@"<%@: %p>, %@", NSStringFromClass([self class]), self, self.title);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[JGSReachability sharedInstance] startMonitor];
    [[JGSReachability sharedInstance] addObserver:self statusChangeBlock:^(JGSReachabilityStatus status) {
        
        JGSEnableLogWithMode(JGSLogModeFunc);
        JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
    }];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGSReuseIdentifier(UITableViewCell)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.demoData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoData[section].rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JGSReuseIdentifier(UITableViewCell) forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //cell.contentView.backgroundColor = JGSColorRGB(arc4random() % (0xff + 1), arc4random() % (0xff + 1), arc4random() % (0xff + 1));
    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return [self.demoData[section].title stringByAppendingFormat:@"(type : %zd)", JGSEnableLogMode];
    }
    return self.demoData[section].title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    JGDemoTableRowData *rowData = self.demoData[indexPath.section].rows[indexPath.row];
    if (rowData.selectBlock) {
        rowData.selectBlock(rowData);
    }
    else if (rowData.selector && [self respondsToSelector:rowData.selector]) {
        
        // 避免警告
        IMP imp = [self methodForSelector:rowData.selector];
        id (*func)(id, SEL, NSInteger) = (void *)imp;
        func(self, rowData.selector, indexPath.row);
    }
    
    JGSLog(@"Network status: %@", [[JGSReachability sharedInstance] reachabilityStatusString]);
    if (indexPath.section == 0) {
        
        JGSLogInfo(@"Info Log");
        JGSLogError(@"Error Log");
        JGSLogWarning(@"Warning Log");
    }
}

#pragma mark - Log
- (void)showLogModeList {
    
    NSArray *types = @[@"Log disable", @"Log only", @"Log with function line", @"Log with function line and pretty out", @"Log with file function line"];
    [JGSAlertController actionSheetWithTitle:@"选择日志类型" cancel:nil others:types action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
        JGSLog();
        NSInteger selIdx = idx - alert.jg_firstOtherIdx;
        JGSEnableLogWithMode(JGSLogModeNone + selIdx);
        [JGSAlertController alertWithTitle:@"日志输出设置" message:types[selIdx] cancel:@"确定" action:^(UIAlertController * _Nonnull _alert, NSInteger _idx) {
            JGSLog(@"<%@: %p> %@", NSStringFromClass([_alert class]), _alert, @(_idx));
        }];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JGSLog();
        [JGSAlertController hideAlert];
    });
}

#pragma mark - 字典取值
- (void)dictionaryGetValue:(NSInteger)rowIndex {
    
    static NSDictionary *storeDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeDictionary = @{
                            @"NumberVale1": @"655381234567890",
                            @"NumberVale2": @(1989.55),
                            @"StringVale": @"AB090BA",
                            @"ArrayValue": @[@"Array Value 1", @"Array Value 2"],
                            @"Dictionary": @{@"Key 1": @"Value 1", @"Key 2": @"Value 2"},
                            };
    });
    
    JGSEnableLogWithMode(JGSLogModeFunc);
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
}

- (void)string2URL:(NSInteger)rowIndex {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
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
            [self.view jg_showToastWithMessage:[NSString stringWithFormat:@"%@\n\n%@", urlStr, urlStr.jg_URLString]];
        }
            break;
            
        case 2: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
            [self.view jg_showToastWithMessage:[NSString stringWithFormat:@"%@\n\n%@", urlStr, urlStr.jg_URLString]];
        }
            break;
            
        case 3: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=&key2=Key&key3= &key4=Key4&key1=&key1=好";
            NSURL *URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\n%@", [URL jg_queryParams]);
            JGSLog(@"\n%@", [URL jg_queryParams:JGSURLQueryPolicyFirstUnempty]);
            JGSLog(@"\n%@", [URL jg_queryParams:JGSURLQueryPolicyLast]);
        }
            break;
            
        case 4: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你 Hello 好%5B中括号%5D";
            NSURL *URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\nkey1: %@", [URL jg_queryValueWithKey:@"key1"]);
        }
            break;
            
        default:
            break;
    }
}

- (void)objejct2JSONDictionary:(NSInteger)rowIndex {
    
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
    switch (rowIndex) {
        case 0: {
            
            JGSLog(@"Model to JSON : %@", [storeDictionary jg_JSONString]);
        }
            break;
            
        case 1: {
            
            JGSLog(@"Model to JSON : %@", [storeString jg_JSONObject]);
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Loading HUD
- (void)showLoadingHUD:(NSInteger)rowIndex {
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    switch (rowIndex) {
        case 0: {
            [JGSLoadingHUD showLoadingHUD];
        }
            break;
            
        case 1: {
            [JGSLoadingHUD showLoadingHUD:@"showLoadingHUDWithMessage"];
        }
            break;
            
        case 2: {
            [JGSLoadingHUD showIndicatorLoadingHUD];
        }
            break;
            
        case 3: {
            [JGSLoadingHUD showIndicatorLoadingHUD:@"Indicator:JGSHUDTypeIndicator"];
        }
            break;
            
        case 4: {
            [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoadingHUD"]];
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:nil];
        }
            break;
            
        case 5: {
            [JGSLoadingHUDStyle sharedStyle].customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoadingHUD"]];
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeCustomView message:@"Image:JGSHUDTypeCustomView"];
        }
            break;
            
        case 6: {
            static BOOL show = NO; show = !show;
            [JGSLoadingHUDStyle sharedStyle].spinningShadow = show;
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:nil];
        }
            break;
            
        case 7: {
            static BOOL show = NO; show = !show;
            [JGSLoadingHUDStyle sharedStyle].spinningLineWidth = show ? 2.f : 4.f;
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:@"JGSHUDTypeSpinningCircle"];
        }
            break;
            
        case 8: {
            static BOOL show = NO; show = !show;
            [JGSLoadingHUDStyle sharedStyle].spinningLineColor = show ? JGSColorRGB(128, 100, 72) : nil;
            [JGSLoadingHUD showLoadingHUD:JGSHUDTypeSpinningCircle message:@"JGSHUD"];
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
}

#pragma mark - End

@end
