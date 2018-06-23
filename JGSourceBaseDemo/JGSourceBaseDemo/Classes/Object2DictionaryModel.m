//
//  Object2DictionaryModel.m
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2018/6/24.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import "Object2DictionaryModel.h"

@implementation Object2DictionaryModel

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _modelStamp = [[NSDate date] timeIntervalSince1970];
        _modelID = [NSString stringWithFormat:@"%@_%.0f", NSStringFromClass([self class]), _modelStamp];
        
        _modelProperty = [[Object2DictionaryPropery alloc] init];
    }
    return self;
}

@end
