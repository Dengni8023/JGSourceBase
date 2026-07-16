//
//  NSArray+JGSBase.h
//  JGSourceBase
//
//  Created by Mei JiGao on 2026/6/24.
//  Copyright © 2026 ByMountains. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (JGSBase)

/// 对数组中的每个元素执行映射操作，将结果组成新数组返回
/// 
/// 类似 Swift 中的 map 方法，遍历数组中的每个元素，应用传入的闭包进行转换，
/// 闭包返回 nil 的元素会被过滤掉，不会出现在结果数组中
/// 
/// - Parameter map: 映射闭包，接收数组中的每个元素，返回转换后的对象或 nil
/// - Returns: 包含所有映射结果的新数组
- (NSArray *)map:(id _Nullable (^)(ObjectType obj))map;

/// 对数组中的每个元素执行映射操作，并将结果数组扁平化为单层数组返回
/// 
/// 类似 Swift 中的 flatMap 方法，遍历数组中的每个元素，应用传入的闭包进行转换，
/// 闭包返回一个数组，然后将所有返回的数组合并成一个单层数组，
/// 闭包返回 nil 的元素会被忽略，不会出现在结果数组中
/// 
/// - Parameter map: 映射闭包，接收数组中的每个元素，返回一个数组或 nil
/// - Returns: 包含所有映射结果的扁平数组
- (NSArray *)flatMap:(NSArray *(^)(ObjectType obj))map;

@end

NS_ASSUME_NONNULL_END
