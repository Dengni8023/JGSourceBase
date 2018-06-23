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
#import "Object2DictionaryModelLeaf.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray<JGDemoTableSectionData *> *demoData;

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
    
    JGSCWeak(self);
    _demoData = @[
                  // Section 日志
                  JGDemoTableSectionMake(@"日志开关、设置",
                                         @[
                                           JGDemoTableRowMakeBlock(@"Log disable", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeNone);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log only", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeLog);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with function line", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeFunc);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with function line and pretty out", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModePretty);
                      [weakself.tableView reloadData];
                  }),
                                           JGDemoTableRowMakeBlock(@"Log with file function line", ^(JGDemoTableRowData * _Nonnull rowData) {
                      JGSCEnableLogWithMode(JGSCLogModeFile);
                      [weakself.tableView reloadData];
                  }),
                                           ]),
                  // Section 字典取值
                  JGDemoTableSectionMake(@"字典取值",
                                         @[
                                           JGDemoTableRowMakeSelector(@"Get Number", @selector(dictionaryGetValue:)),
                                           JGDemoTableRowMakeSelector(@"Get Array", @selector(dictionaryGetValue:)),
                                           JGDemoTableRowMakeSelector(@"Get Dictionary", @selector(dictionaryGetValue:)),
                                           JGDemoTableRowMakeSelector(@"Get Object", @selector(dictionaryGetValue:)),
                                           ]),
                  // Section 字符串URL处理
                  JGDemoTableSectionMake(@"字符串URL处理",
                                         @[
                                           JGDemoTableRowMakeSelector(@"字符串URL编码", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"字符串中文字符处理", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"字符串query不合规范处理", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"URL Query字典", @selector(string2URL:)),
                                           JGDemoTableRowMakeSelector(@"URL Query参数值", @selector(string2URL:)),
                                           ]),
                  // Section 对象转JSON、字典
                  JGDemoTableSectionMake(@"对象转JSON、字典",
                                         @[
                                           JGDemoTableRowMakeSelector(@"JSON对象转JSON字符串", @selector(objejct2JSONDictionary:)),
                                           JGDemoTableRowMakeSelector(@"对象转字典", @selector(objejct2JSONDictionary:)),
                                           ]),
                  ];
}

- (void)dealloc {
    
    JGSCLog(@"<%@: %p>, %@", NSStringFromClass([self class]), self, self.title);
}

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.sectionHeaderHeight = 44;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:JGSCReuseIdentifier(UITableViewCell)];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JGSCReuseIdentifier(UITableViewCell) forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = self.demoData[indexPath.section].rows[indexPath.row].title;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return [self.demoData[section].title stringByAppendingFormat:@"(type : %zd)", JGSCEnableLogMode];
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
        
        //#pragma clang diagnostic push
        //#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        //        [self performSelector:selctor];
        //#pragma clang diagnostic pop
        
        // 避免警告
        IMP imp = [self methodForSelector:rowData.selector];
        void (*func)(id, SEL, NSInteger) = (void *)imp;
        func(self, rowData.selector, indexPath.row);
    }
    
    if (indexPath.section == 0) {
        
        JGSCLogInfo(@"Info Log");
        JGSCLogError(@"Error Log");
        JGSCLogWarning(@"Warning Log");
    }
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
    
    JGSCEnableLogWithMode(JGSCLogModeFunc);
    switch (rowIndex) {
        case 0: {
            
            JGSCLog(@"%@", [storeDictionary jg_numberForKey:@"NumberVale1"]);
            JGSCLog(@"%ud", [storeDictionary jg_shortForKey:@"NumberVale1"]);
            JGSCLog(@"%zd", [storeDictionary jg_integerForKey:@"NumberVale1"]);
            JGSCLog(@"%ld", [storeDictionary jg_longForKey:@"NumberVale1"]);
            JGSCLog(@"%f", [storeDictionary jg_floatForKey:@"NumberVale1"]);
            JGSCLog(@"%d", [storeDictionary jg_boolForKey:@"NumberVale1"]);
            JGSCLog(@"%lf", [storeDictionary jg_CGFloatForKey:@"NumberVale1"]);
            JGSCLog(@"%ud", [storeDictionary jg_unsignedIntForKey:@"NumberVale1"]);
            
            JGSCLog(@"%zd", [storeDictionary jg_integerForKey:@"NumberVale2"]);
            JGSCLog(@"%zd", [storeDictionary jg_integerForKey:@"StringVale"]);
            JGSCLog(@"%zd", [storeDictionary jg_integerForKey:@"ArrayValue"]);
            JGSCLog(@"%zd", [storeDictionary jg_integerForKey:@"Dictionary"]);
        }
            break;
            
        case 1: {
            
            JGSCLog(@"%@", [storeDictionary jg_arrayForKey:@"NumberVale1"]);
            JGSCLog(@"%@", [storeDictionary jg_arrayForKey:@"NumberVale2"]);
            JGSCLog(@"%@", [storeDictionary jg_arrayForKey:@"StringVale"]);
            JGSCLog(@"%@", [storeDictionary jg_arrayForKey:@"ArrayValue"]);
            JGSCLog(@"%@", [storeDictionary jg_arrayForKey:@"Dictionary"]);
        }
            break;
            
        case 2: {
            
            JGSCLog(@"%@", [storeDictionary jg_dictionaryForKey:@"NumberVale1"]);
            JGSCLog(@"%@", [storeDictionary jg_dictionaryForKey:@"NumberVale2"]);
            JGSCLog(@"%@", [storeDictionary jg_dictionaryForKey:@"StringVale"]);
            JGSCLog(@"%@", [storeDictionary jg_dictionaryForKey:@"ArrayValue"]);
            JGSCLog(@"%@", [storeDictionary jg_dictionaryForKey:@"Dictionary"]);
        }
            break;
            
        case 3: {
            
            JGSCLog(@"%@", [storeDictionary jg_objectForKey:@"NumberVale1"]);
            JGSCLog(@"%@", [storeDictionary jg_objectForKey:@"NumberVale2"]);
            JGSCLog(@"%@", [storeDictionary jg_objectForKey:@"StringVale"]);
            JGSCLog(@"%@", [storeDictionary jg_objectForKey:@"ArrayValue"]);
            JGSCLog(@"%@", [storeDictionary jg_objectForKey:@"Dictionary"]);
        }
            break;
            
        default:
            break;
    }
}

- (void)string2URL:(NSInteger)rowIndex {
    
    JGSCEnableLogWithMode(JGSCLogModeFunc);
    switch (rowIndex) {
        case 0: {
            
            NSArray<NSString *> *oriStrs = @[@":", @"#", @"[", @"]", @"@", @"!", @"$", @"&", @"'", @"(", @")", @"*", @"+", @",", @";", @"="];
            [oriStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSCLog(@"Encode %@ -> %@", obj, obj.jg_URLEncodeString);
            }];
        }
            break;
            
        case 1: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSCLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        case 2: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=Key&key3= &key4=Key4&key1=&key1=好";
            JGSCLog(@"\n%@\n%@", urlStr, urlStr.jg_URLString);
        }
            break;
            
        case 3: {
            
            NSString *urlStr = @"https://www.baidu.com/search&key1=你好&key2=&key2=Key&key3= &key4=Key4&key1=&key1=好";
            NSURL *URL = urlStr.jg_URL;
            JGSCLog(@"\n%@", urlStr.jg_URLString);
            JGSCLog(@"\n%@", [URL jg_queryParams]);
            JGSCLog(@"\n%@", [URL jg_queryParams:JGSCURLQueryPolicyFirstUnempty]);
            JGSCLog(@"\n%@", [URL jg_queryParams:JGSCURLQueryPolicyLast]);
        }
            break;
            
        case 4: {
            
            NSString *urlStr = @"https://www.baidu.com/search?key1=你 Hello 好%5B中括号%5D";
            NSURL *URL = urlStr.jg_URL;
            JGSCLog(@"\n%@", urlStr.jg_URLString);
            JGSCLog(@"\nkey1: %@", [URL jg_queryValueWithKey:@"key1"]);
        }
            break;
            
        default:
            break;
    }
}

- (void)objejct2JSONDictionary :(NSInteger)rowIndex {
    
    static NSDictionary *storeDictionary = nil;
    static Object2DictionaryModelLeaf *modelObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        modelObj = [[Object2DictionaryModelLeaf alloc] init];
        storeDictionary = @{
                            @"NumberVale1": @"655381234567890",
                            @"NumberVale2": @(1989.55),
                            @"StringVale": @"AB090BA",
                            @"ArrayValue": @[@"Array Value 1", @"Array Value 2"],
                            @"Dictionary": @{@"Key 1": @"Value 1", @"Key 2": @"Value 2"},
                            };
    });
    
    JGSCEnableLogWithMode(JGSCLogModeFunc);
    switch (rowIndex) {
        case 0: {
            
            JGSCLog(@"Model to JSON : %@", [storeDictionary jg_JSONString]);
        }
            break;
            
        case 1: {
            
            JGSCLog(@"Model to JSON : %@", [modelObj jg_Object2Dictionary]);
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - End

@end
