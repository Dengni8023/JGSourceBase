//
//  NSArray+JGSBase.m
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/24.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import "NSArray+JGSBase.h"

@implementation NSArray (JGSBase)

- (NSArray *)map:(id  _Nullable (^)(id _Nonnull))map {
    
    NSMutableArray *res = @[].mutableCopy;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id mapObj = map(obj);
        if (mapObj) {
            [res addObject:mapObj];
        }
    }];
    return res.copy;
}

- (NSArray *)flatMap:(NSArray * _Nonnull (^)(id _Nonnull))map {
    
    NSMutableArray *res = @[].mutableCopy;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *mapObj = map(obj);
        if (mapObj) {
            [res addObjectsFromArray:mapObj];
        }
    }];
    return res.copy;
}

@end
