//
//  Object2DictionaryPropery.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2018/6/24.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "Object2DictionaryPropery.h"

@implementation Object2DictionaryPropery

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _modelStamp = [[NSDate date] timeIntervalSince1970];
        _modelID = [NSString stringWithFormat:@"%@_%.0f", NSStringFromClass([self class]), _modelStamp];
        
        NSDictionary *dict = @{@"Key 1": @"Value 1", @"Array": @[@"Array ele 1", @"Array ele 2"]};
        _dicProperties = dict.copy;
        _arrayProperties = @[@"Array ele 1", @"Array ele 2", dict.copy];
    }
    return self;
}

@end
