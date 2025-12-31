//
//  JGSNSObjectDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/3/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSNSObjectDemoVC.h"
@import JGSourceBase;

@interface JGSNSObjectDemoVC ()

@end

@implementation JGSNSObjectDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"NSObject";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#ifdef JGSCategory_NSObject_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" JSON",
		@[
			JGSDemoTableRowMake(@"Object to String", nil, @selector(object2JSONDictionary:)),
			JGSDemoTableRowMake(@"String to Object", nil, @selector(object2JSONDictionary:)),
			JGSDemoTableRowMake(@"Object with Option", nil, @selector(object2JSONDictionary:)),
		]),
	];
}

#pragma mark - Action
- (void)object2JSONDictionary:(NSIndexPath *)indexPath {
    
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
    
    [JGSLogger enableLogWithMode:JGSLogModeFunc level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            JGSDemoShowConsoleLog(self, @"Model to JSON : %@", [storeDictionary jg_JSONString]);
        }
            break;
            
        case 1: {
            
            JGSDemoShowConsoleLog(self, @"Model to JSON : %@", [storeString jg_JSONObject]);
        }
            break;
            
        case 2: {
            
            id object = [storeDictionary jg_JSONObjectWithOptions:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments) error:nil];
            JGSDemoShowConsoleLog(self, @"%@ : %@", NSStringFromClass([object class]), object);
        }
            break;
            
        default:
            break;
    }
}

#endif

@end
