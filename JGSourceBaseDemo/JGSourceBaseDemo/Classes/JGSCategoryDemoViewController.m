//
//  JGSCategoryDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJiGao. All rights reserved.
//

#import "JGSCategoryDemoViewController.h"

@interface JGSCategoryDemoViewController ()

@end

@implementation JGSCategoryDemoViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
#ifdef JGSCategory_NSDictionary
        // Section 字典取值
        JGSDemoTableSectionMake(@" 字典取值",
                                @[
                                    JGSDemoTableRowMake(@"Get Number", nil, @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMake(@"Get Array", nil, @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMake(@"Get Dictionary", nil, @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMake(@"Get Object", nil, @selector(dictionaryGetValue:)),
                                ]),
#endif
#ifdef JGSCategory_NSString
        // Section 字符串URL处理
        JGSDemoTableSectionMake(@" 字符串URL处理",
                                @[
                                    JGSDemoTableRowMake(@"字符串URL编码", nil, @selector(string2URL:)),
                                    JGSDemoTableRowMake(@"字符串中文字符处理", nil, @selector(string2URL:)),
                                    JGSDemoTableRowMake(@"字符串query不合规范处理", nil, @selector(string2URL:)),
                                    JGSDemoTableRowMake(@"URL Query字典", nil, @selector(string2URL:)),
                                    JGSDemoTableRowMake(@"URL Query参数值", nil, @selector(string2URL:)),
                                ]),
#endif
#ifdef JGSCategory_NSObject
        // Section 对象转JSON、字典
        JGSDemoTableSectionMake(@" 对象转JSON、字典",
                                @[
                                    JGSDemoTableRowMake(@"JSON对象转JSON字符串", nil, @selector(object2JSONDictionary:)),
                                    JGSDemoTableRowMake(@"JSON字符串转JSON对象", nil, @selector(object2JSONDictionary:)),
                                ]),
#endif
    ];
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Category";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Action
- (void)dictionaryGetValue:(NSIndexPath *)indexPath {
#ifdef JGSCategory_NSDictionary
    static NSDictionary *storeDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeDictionary = @{
            //@"NumberVale1": @{@"key": @"v"},//@"655381234567890",
            @"NumberVale1": @"true",//@"655381234567890",
            //@"NumberVale1": @"NO",//@"655381234567890",
            //@"NumberVale1": @"655381234567890",
            @"NumberVale2": @(1989.55),
            @"StringVale": @"AB090BA",
            @"ArrayValue": @[@"Array Value 1", @"Array Value 2"],
            @"Dictionary": @{@"Key 1": @"Value 1", @"Key 2": @"Value 2"},
        };
    });
    
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_numberForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%ud", [storeDictionary jg_shortForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%zd", [storeDictionary jg_integerForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%ld", [storeDictionary jg_longForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%f", [storeDictionary jg_floatForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%d", [storeDictionary jg_boolForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%lf", [storeDictionary jg_CGFloatForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%ud", [storeDictionary jg_unsignedIntForKey:@"NumberVale1"]);
            
            JGSDemoShowConsoleLog(@"%zd", [storeDictionary jg_integerForKey:@"NumberVale2"]);
            JGSDemoShowConsoleLog(@"%zd", [storeDictionary jg_integerForKey:@"StringVale"]);
            JGSDemoShowConsoleLog(@"%zd", [storeDictionary jg_integerForKey:@"ArrayValue"]);
            JGSDemoShowConsoleLog(@"%zd", [storeDictionary jg_integerForKey:@"Dictionary"]);
        }
            break;
            
        case 1: {
            
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_arrayForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_arrayForKey:@"NumberVale2"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_arrayForKey:@"StringVale"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_arrayForKey:@"ArrayValue"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_arrayForKey:@"Dictionary"]);
        }
            break;
            
        case 2: {
            
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_dictionaryForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_dictionaryForKey:@"NumberVale2"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_dictionaryForKey:@"StringVale"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_dictionaryForKey:@"ArrayValue"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_dictionaryForKey:@"Dictionary"]);
        }
            break;
            
        case 3: {
            
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_objectForKey:@"NumberVale1"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_objectForKey:@"NumberVale2"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_objectForKey:@"StringVale"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_objectForKey:@"ArrayValue"]);
            JGSDemoShowConsoleLog(@"%@", [storeDictionary jg_objectForKey:@"Dictionary"]);
        }
            break;
            
        default:
            break;
    }
#endif
}

- (void)string2URL:(NSIndexPath *)indexPath {
#ifdef JGSCategory_NSString
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            NSArray<NSString *> *oriStrs = @[@":", @"#", @"[", @"]", @"@", @"!", @"$", @"&", @"'", @"(", @")", @"*", @"+", @",", @";", @"="];
            [oriStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSDemoShowConsoleLog(@"Encode %@ -> %@", obj, obj.jg_URLEncodeString);
            }];
        }
            break;
            
        case 1: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSDemoShowConsoleLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        case 2: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSDemoShowConsoleLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        case 3: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=&key2=Key&key3= &key4=Key4&key1=&key1=好";
            NSURL *URL = urlStr.jg_URL;
            JGSDemoShowConsoleLog(@"\n%@", urlStr.jg_URLString);
            JGSDemoShowConsoleLog(@"\n%@", [URL jg_queryParams]);
            
            urlStr = @"https://www.baidu.com/search?key1=%E4%BD%A0%E5%A5%BD";
            URL = urlStr.jg_URL;
            JGSDemoShowConsoleLog(@"\n%@", urlStr.jg_URLString);
            JGSDemoShowConsoleLog(@"\n%@", [URL jg_queryParams]);
        }
            break;
            
        case 4: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你 Hello 好%5B中括号%5D";
            NSURL *URL = urlStr.jg_URL;
            JGSDemoShowConsoleLog(@"\n%@", urlStr.jg_URLString);
            JGSDemoShowConsoleLog(@"\nkey1: %@", [URL jg_queryForKey:@"key1"]);
        }
            break;
            
        default:
            break;
    }
#endif
}

- (void)object2JSONDictionary:(NSIndexPath *)indexPath {
#ifdef JGSCategory_NSObject
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
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            JGSDemoShowConsoleLog(@"Model to JSON : %@", [storeDictionary jg_JSONString]);
            id object = [storeDictionary jg_JSONObjectWithOptions:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments) error:nil];
            JGSDemoShowConsoleLog(@"Model to Mutable : %@", object);
        }
            break;
            
        case 1: {
            
            JGSDemoShowConsoleLog(@"Model to JSON : %@", [storeString jg_JSONObject]);
        }
            break;
            
        default:
            break;
    }
#endif
}

#pragma mark - Category - NSDate
- (void)jumpToCategoryDate {
    
    JGSDemoViewController *vcT = [[JGSDemoViewController alloc] init];
    vcT.title = @"NSDate";
    vcT.showTextView = YES;
    vcT.tableSectionData = @[
        // Section Base
        JGSDemoTableSectionMake(nil,
                                @[
                                    JGSDemoTableRowMake(@"Date Demo", self, @selector(categoryDateDemo:controller:)),
                                ]),
    ];
    
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)categoryDateDemo:(NSIndexPath *)indexPath controller:(JGSDemoViewController *)vcT {
    
#ifdef JGSCategory_NSDate
    NSDate *now = [NSDate date];
    [vcT showConsoleLog:@"%04d-%02d-%02d %02d:%02d:%02d-%09", now.jg_year, now.jg_month, now.jg_day, now.jg_hour, now.jg_minute, now.jg_second, now.jg_nanosecond];
#endif
}

#pragma mark - Category - UIAlertController
- (void)jumpToCategoryAlert {
    
    JGSDemoViewController *vcT = [[JGSDemoViewController alloc] init];
    vcT.title = @"UIAlertController";
    vcT.tableSectionData = @[
        // Section Base
        JGSDemoTableSectionMake(@" Base",
                                @[
                                    JGSDemoTableRowMake(@"Show alerts，Last hide all", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMake(@"Show alerts，Last hide one", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMake(@"Alert canle & destructive", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMake(@"Alert canle & other", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMake(@"Alert canle & others", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMake(@"Alert canle & destructive & others", self, @selector(categoryAlertDemo:)),
                                    JGSDemoTableRowMake(@"Action Sheet", self, @selector(categoryAlertDemo:)),
                                ]),
    ];
    
    [self.navigationController pushViewController:vcT animated:YES];
}

- (void)categoryAlertDemo:(NSIndexPath *)indexPath {
    
#ifdef JGSCategory_UIAlertController
    switch (indexPath.section) {
        case 0: {
            
            switch (indexPath.row) {
                case 0: {
                    
                    // Last hide all
                    NSInteger i = 0;
                    while (i < 5) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [UIAlertController jg_alertWithTitle:[@(i + 1) stringValue] message:@"5 alerts，Last hide all" cancel:(i == 4 ? @"关闭所有" : (i % 2 == 0 ? @"确定" : nil)) action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                                
                                if (i == 4) {
                                    [UIAlertController jg_hideAllAlert:YES];
                                }
                            }];
                        });
                        i += 1;
                    }
                }
                    break;
                    
                case 1: {
                    
                    // Last hide one
                    NSInteger i = 0;
                    while (i < 4) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [UIAlertController jg_alertWithTitle:[@(i + 1) stringValue] message:@"5 alerts，Last hide all" cancel:(i == 3 ? @"再关闭一个" : @"确定") action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                                
                                if (i == 3) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [UIAlertController jg_hideCurrentAlert:YES];
                                    });
                                }
                            }];
                        });
                        i += 1;
                    }
                }
                    break;
                    
                case 2: {
                    
                    // canle & destructive
                    [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" destructive:@"Destructive" action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        
                    }];
                }
                    break;
                    
                case 3: {
                    
                    // canle & other
                    [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" other:@"Other" action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        
                    }];
                }
                    break;
            
                case 4: {
                    
                    // canle & others
                    [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        
                    }];
                }
                    break;
                    
                case 5: {
                    
                    // canle & destructive & others
                    [UIAlertController jg_alertWithTitle:@"Title" message:@"Message" cancel:@"Cancel" destructive:@"Destructive" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        
                    }];
                }
                    break;
                    
                case 6: {
                    
                    // Action Sheet
                    static BOOL withCancel = YES;
                    [UIAlertController jg_actionSheetWithTitle:@"Title" message:@"Message" cancel:(withCancel ? @"Cancel" : nil) destructive:@"Destructive" others:@[@"Other 1", @"Other 2"] action:^(UIAlertController * _Nonnull alert, NSInteger idx) {
                        withCancel = !withCancel;
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
#endif
}

#pragma mark - End

@end
