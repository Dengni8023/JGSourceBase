//
//  JGSCategoryDemoViewController.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2019/5/29.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSCategoryDemoViewController.h"

@interface JGSCategoryDemoViewController ()

@end

@implementation JGSCategoryDemoViewController

- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
    
    return @[
#ifdef JGS_Category_NSDictionary
        // Section 字典取值
        JGSDemoTableSectionMake(@" 字典取值",
                                @[
                                    JGSDemoTableRowMakeSelector(@"Get Number", @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMakeSelector(@"Get Array", @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMakeSelector(@"Get Dictionary", @selector(dictionaryGetValue:)),
                                    JGSDemoTableRowMakeSelector(@"Get Object", @selector(dictionaryGetValue:)),
                                ]),
#endif
#ifdef JGS_Category_NSString
        // Section 字符串URL处理
        JGSDemoTableSectionMake(@" 字符串URL处理",
                                @[
                                    JGSDemoTableRowMakeSelector(@"字符串URL编码", @selector(string2URL:)),
                                    JGSDemoTableRowMakeSelector(@"字符串中文字符处理", @selector(string2URL:)),
                                    JGSDemoTableRowMakeSelector(@"字符串query不合规范处理", @selector(string2URL:)),
                                    JGSDemoTableRowMakeSelector(@"URL Query字典", @selector(string2URL:)),
                                    JGSDemoTableRowMakeSelector(@"URL Query参数值", @selector(string2URL:)),
                                ]),
#endif
#ifdef JGS_Category_NSObject
        // Section 对象转JSON、字典
        JGSDemoTableSectionMake(@" 对象转JSON、字典",
                                @[
                                    JGSDemoTableRowMakeSelector(@"JSON对象转JSON字符串", @selector(object2JSONDictionary:)),
                                    JGSDemoTableRowMakeSelector(@"JSON字符串转JSON对象", @selector(object2JSONDictionary:)),
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
#ifdef JGS_Category_NSDictionary
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
#endif
}

- (void)string2URL:(NSIndexPath *)indexPath {
#ifdef JGS_Category_NSString
    JGSEnableLogWithMode(JGSLogModeFunc);
    NSInteger rowIndex = indexPath.row;
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
        }
            break;
            
        case 2: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        case 3: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=&key2=Key&key3= &key4=Key4&key1=&key1=好";
            NSURL *URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\n%@", [URL jg_queryParams]);
            
            urlStr = @"https://www.baidu.com/search?key1=%E4%BD%A0%E5%A5%BD";
            URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\n%@", [URL jg_queryParams]);
        }
            break;
            
        case 4: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你 Hello 好%5B中括号%5D";
            NSURL *URL = urlStr.jg_URL;
            JGSLog(@"\n%@", urlStr.jg_URLString);
            JGSLog(@"\nkey1: %@", [URL jg_queryForKey:@"key1"]);
        }
            break;
            
        default:
            break;
    }
#endif
}

- (void)object2JSONDictionary:(NSIndexPath *)indexPath {
#ifdef JGS_Category_NSObject
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
            
            JGSLog(@"Model to JSON : %@", [storeDictionary jg_JSONString]);
            id object = [storeDictionary jg_JSONObjectWithOptions:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments) error:nil];
            JGSLog(@"Model to Mutable : %@", object);
        }
            break;
            
        case 1: {
            
            JGSLog(@"Model to JSON : %@", [storeString jg_JSONObject]);
        }
            break;
            
        default:
            break;
    }
#endif
}

#pragma mark - End

@end
