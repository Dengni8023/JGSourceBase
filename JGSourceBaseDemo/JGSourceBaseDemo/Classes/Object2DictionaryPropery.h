//
//  Object2DictionaryPropery.h
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2018/6/24.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Object2DictionaryPropery : NSObject

@property (nonatomic, assign) NSTimeInterval modelStamp;
@property (nonatomic, copy) NSString *modelID;

@property (nonatomic, strong) NSDictionary *dicProperties;
@property (nonatomic, strong) NSArray *arrayProperties;

@end
