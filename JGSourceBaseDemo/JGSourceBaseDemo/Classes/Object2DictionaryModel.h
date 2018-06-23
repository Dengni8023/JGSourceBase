//
//  Object2DictionaryModel.h
//  JGSourceBaseDemo
//
//  Created by 梅继高 on 2018/6/24.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Object2DictionaryPropery.h"

@interface Object2DictionaryModel : NSObject

@property (nonatomic, assign) NSTimeInterval modelStamp;
@property (nonatomic, copy) NSString *modelID;

@property (nonatomic, strong) Object2DictionaryPropery *modelProperty;

@end
