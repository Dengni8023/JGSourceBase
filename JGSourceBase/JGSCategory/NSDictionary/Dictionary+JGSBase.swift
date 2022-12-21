//
//  Dictionary+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2022/12/2.
//  Copyright © 2022 MeiJiGao. All rights reserved.
//

import Foundation

extension Dictionary where Key : Hashable {
    
//    // String
//    public func jg_string(forKey key: Key, defaultValue: String? = nil) -> String? {
//
//        let value = self[key]
//        guard value != nil else {
//            return defaultValue
//        }
//
//        if value is String, let str = value as? String {
//            return str
//        }
//
//        if value is NSNumber, let number = value as? NSNumber {
//            return number.stringValue
//        }
//
//        return value as? String ?? defaultValue
//    }
//
//    // Number
//    public func jg_number(forKey key: Key, defaultValue: NSNumber? = nil) -> NSNumber? {
//        return self[key] as? NSNumber ?? defaultValue
//    }
//
//    // Short
//    public func jg_short(forKey key: Key, defaultValue: CShort = 0) -> CShort {
//        return self[key] as? CShort ?? defaultValue
//    }
//
//    public func jg_ushort(forKey key: Key, defaultValue: ushort = 0) -> ushort {
//        return self[key] as? ushort ?? defaultValue
//    }
//
//    // Int
//    public func jg_int8(forKey key: Key, defaultValue: Int8 = 0) -> Int8 {
//        return self[key] as? Int8 ?? defaultValue
//    }
//
//    public func jg_uint8(forKey key: Key, defaultValue: UInt8 = 0) -> UInt8 {
//        return self[key] as? UInt8 ?? defaultValue
//    }
//
//    public func jg_int(forKey key: Key, defaultValue: Int = 0) -> Int {
//        return self[key] as? Int ?? defaultValue
//    }
//
//    public func jg_uint(forKey key: Key, defaultValue: UInt = 0) -> UInt {
//        return self[key] as? UInt ?? defaultValue
//    }
//
//    public func jg_int16(forKey key: Key, defaultValue: Int16 = 0) -> Int16 {
//        return self[key] as? Int16 ?? defaultValue
//    }
//
//    public func jg_uint16(forKey key: Key, defaultValue: UInt16 = 0) -> UInt16 {
//        return self[key] as? UInt16 ?? defaultValue
//    }
//
//    public func jg_int32(forKey key: Key, defaultValue: Int32 = 0) -> Int32 {
//        return self[key] as? Int32 ?? defaultValue
//    }
//
//    public func jg_uint32(forKey key: Key, defaultValue: UInt32 = 0) -> UInt32 {
//        return self[key] as? UInt32 ?? defaultValue
//    }
//
//    public func jg_int64(forKey key: Key, defaultValue: Int64 = 0) -> Int64 {
//        return self[key] as? Int64 ?? defaultValue
//    }
//
//    public func jg_uint64(forKey key: Key, defaultValue: UInt64 = 0) -> UInt64 {
//        return self[key] as? UInt64 ?? defaultValue
//    }
//
//    // Long
//    public func jg_long(forKey key: Key, defaultValue: CLong = 0) -> CLong {
//        return self[key] as? CLong ?? defaultValue
//    }
//
//    public func jg_unsignedlong(forKey key: Key, defaultValue: CUnsignedLong = 0) -> CUnsignedLong {
//        return self[key] as? CUnsignedLong ?? defaultValue
//    }
//
//    public func jg_longlong(forKey key: Key, defaultValue: CLongLong = 0) -> CLongLong {
//        return self[key] as? CLongLong ?? defaultValue
//    }
//
//    public func jg_unsignedlonglong(forKey key: Key, defaultValue: CUnsignedLongLong = 0) -> CUnsignedLongLong {
//        return self[key] as? CUnsignedLongLong ?? defaultValue
//    }
//
//    // Float
//    public func jg_float(forKey key: Key, defaultValue: Float = 0.0) -> Float {
//        return self[key] as? Float ?? defaultValue
//    }
//
//    @available(iOS 14.0, *)
//    public func jg_float16(forKey key: Key, defaultValue: Float16 = 0.0) -> Float16 {
//        return self[key] as? Float16 ?? defaultValue
//    }
//
//    public func jg_float32(forKey key: Key, defaultValue: Float32 = 0.0) -> Float32 {
//        return self[key] as? Float32 ?? defaultValue
//    }
//
//    public func jg_float64(forKey key: Key, defaultValue: Float64 = 0.0) -> Float64 {
//        return self[key] as? Float64 ?? defaultValue
//    }
//
//    public func jg_double(forKey key: Key, defaultValue: Double = 0.0) -> Double {
//        return self[key] as? Double ?? defaultValue
//    }
//
//    // BOOL
//    public func jg_bool(forKey key: Key, defaultValue: Bool = false) -> Bool {
//        return self[key] as? Bool ?? defaultValue
//    }
//
//    // CGFloat
//    public func jg_CGFloat(forKey key: Key, defaultValue: CGFloat = 0.0) -> CGFloat {
//        return self[key] as? CGFloat ?? defaultValue
//    }
//
//    // NSInteger
//    public func jg_integer(forKey key: Key, defaultValue: NSInteger = 0) -> NSInteger {
//        return self[key] as? NSInteger ?? defaultValue
//    }
//
//    public func jg_unsignedInteger<T: UnsignedInteger>(forKey key: Key, defaultValue: T = 0) -> T {
//        return self[key] as? T ?? defaultValue
//    }
    
//    - (NSInteger)jg_integerForKey:(const KeyType)key;
//    - (NSInteger)jg_integerForKey:(const KeyType)key defaultValue:(NSInteger)defaultValue;
//    - (NSUInteger)jg_unsignedIntegerForKey:(const KeyType)key;
//    - (NSUInteger)jg_unsignedIntegerForKey:(const KeyType)key defaultValue:(NSUInteger)defaultValue;
//
//    // Object
//    - (nullable ObjectType)jg_objectForKey:(const KeyType)key;
//    - (nullable ObjectType)jg_objectForKey:(const KeyType)key defaultValue:(nullable ObjectType)defaultValue;
//    - (nullable ObjectType)jg_objectForKey:(const KeyType)key withClass:(__unsafe_unretained Class)cls;
//    - (nullable ObjectType)jg_objectForKey:(const KeyType)key withClass:(__unsafe_unretained Class)cls defaultValue:(nullable ObjectType)defaultValue;
//
//    // Dict
//    - (nullable NSDictionary *)jg_dictionaryForKey:(const KeyType)key;
//    - (nullable NSDictionary *)jg_dictionaryForKey:(const KeyType)key defaultValue:(nullable NSDictionary *)defaultValue;
//
//    // Array
//    - (nullable NSArray *)jg_arrayForKey:(const KeyType)key;
//    - (nullable NSArray *)jg_arrayForKey:(const KeyType)key defaultValue:(nullable NSArray *)defaultValue;

}
