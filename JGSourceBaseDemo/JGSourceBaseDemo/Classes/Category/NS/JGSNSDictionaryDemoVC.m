//
//  JGSNSDictionaryDemoVC.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2022/3/17.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

#import "JGSNSDictionaryDemoVC.h"
@import JGSourceBase;

@interface JGSNSDictionaryDemoVC ()

@end

@implementation JGSNSDictionaryDemoVC

#pragma mark - Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"NSDictionary";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#ifdef JGSCategory_NSDictionary_h
#pragma mark - TableRows
- (NSArray<JGSDemoTableSectionData *> *)tableSectionData {
	
	return @[
		JGSDemoTableSectionMake(@" Get Value",
		@[
			JGSDemoTableRowMake(@"Get Number", nil, @selector(dictionaryGetValue:)),
			JGSDemoTableRowMake(@"Get Array", nil, @selector(dictionaryGetValue:)),
			JGSDemoTableRowMake(@"Get Dictionary", nil, @selector(dictionaryGetValue:)),
			JGSDemoTableRowMake(@"Get String", nil, @selector(dictionaryGetValue:)),
			JGSDemoTableRowMake(@"Get BOOL", nil, @selector(dictionaryGetValue:)),
		])
	];
}

#pragma mark - Action
- (void)dictionaryGetValue:(NSIndexPath *)indexPath {
    
    static NSDictionary<NSString *, id> *storeDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeDictionary = @{
            //@"NumberVale1": @{@"key": @"v"},//@"655381234567890",
            @"NumberVale1": @"true",//@"655381234567890",
            //@"NumberVale1": @"NO",//@"655381234567890",
            //@"NumberVale1": @"655381234567890",
            @"NumberVale2": @(1989.55),
            @"StringVale": @"AB090BA",
            @"HexVale": @"0xff",
            @"TwoVale": @"0b10",
            @"EightVale": @"010",
            @"ArrayValue": @[@"Array Value 1", @"Array Value 2", @"Array中文输出：你好啊", @[@"嵌套Array"]],
            @"Dictionary": @{@"Key 1": @"Value 1", @"Key 2": @"Value 2", @"CN-Value": @"Dictionary中文输出：你好吗", @"Dict": @{@"key": @"嵌套字典Value"}},
        };
    });
    
    [JGSLogger enableLogWithMode:JGSLogModeFunc level:JGSLogger.level useNSLog:JGSLogger.useNSLog lengthLimit:JGSLogger.lengthLimit truncating:JGSLogger.truncating];
    NSInteger rowIndex = indexPath.row;
    switch (rowIndex) {
        case 0: {
            
            JGSWeakSelf
            [storeDictionary.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSStrongSelf
                id value = [storeDictionary jg_objectForKey:obj];
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, number value: %@", obj, NSStringFromClass([value class]), value, [storeDictionary jg_numberForKey:obj]);
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, short value: %d", obj, NSStringFromClass([value class]), value, [storeDictionary jg_shortForKey:obj]);
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, integer value: %zd", obj, NSStringFromClass([value class]), value, [storeDictionary jg_integerForKey:obj]);
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, long value: %ld", obj, NSStringFromClass([value class]), value, [storeDictionary jg_longForKey:obj]);
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, float value: %f", obj, NSStringFromClass([value class]), value, [storeDictionary jg_floatForKey:obj]);
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, bool value: %@", obj, NSStringFromClass([value class]), value, [storeDictionary jg_boolForKey:obj] ? @"YES" : @"NO");
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, CGFloat value: %lf", obj, NSStringFromClass([value class]), value, [storeDictionary jg_CGFloatForKey:obj]);
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, unsignedInt value: %u", obj, NSStringFromClass([value class]), value, [storeDictionary jg_unsignedIntForKey:obj]);
            }];
        }
            break;
            
        case 1: {
            
            JGSWeakSelf
            [storeDictionary.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSStrongSelf
                id value = [storeDictionary jg_objectForKey:obj];
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, array value: %@", obj, NSStringFromClass([value class]), value, [storeDictionary jg_arrayForKey:obj]);
            }];
        }
            break;
            
        case 2: {
            
            JGSWeakSelf
            [storeDictionary.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSStrongSelf
                id value = [storeDictionary jg_objectForKey:obj];
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, dictionary value: %@", obj, NSStringFromClass([value class]), value, [storeDictionary jg_dictionaryForKey:obj]);
            }];
        }
            break;
            
        case 3: {
            
            JGSWeakSelf
            [storeDictionary.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSStrongSelf
                id value = [storeDictionary jg_objectForKey:obj];
                JGSDemoShowConsoleLog(self, @"key: %@, %@ object: %@, string value: %@", obj, NSStringFromClass([value class]), value, [storeDictionary jg_stringForKey:obj]);
            }];
        }
            break;
            
        case 4: {
            
            NSDictionary *booleanDict = @{
                @"true": @"true",
                @"tr": @"tr",
                @"t": @"t",
                @"false": @"false",
                @"fal": @"fal",
                @"f": @"f",
                @"YES": @"YES",
                @"YE": @"YE",
                @"Y": @"Y",
                @"NO": @"NO",
                @"N": @"N",
                @"My": @"My",
                @"10": @"10",
                @"-1": @"-1",
            };
            JGSWeakSelf
            [booleanDict.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                JGSStrongSelf
                id value = [booleanDict jg_objectForKey:obj];
                JGSDemoShowConsoleLog(self, @"%@ -> %@", value, [booleanDict jg_boolForKey:obj] ? @"YES" : @"NO");
            }];
        }
            break;
            
        default:
            break;
    }
}

#endif

@end
