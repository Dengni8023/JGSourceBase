//
//  String+JGSBase.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/7.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

// 定义一个协议 JGSStringSubscript，用于扩展字符串的下标功能
public protocol JGSStringSubscript {}

// 使 String 类型符合 JGSStringSubscript 协议
extension String: JGSStringSubscript {}

// 扩展 JGSStringSubscript 协议，为 String 类型添加安全的范围下标方法
extension JGSStringSubscript where Self == String {
    
    /// 字符串截取，内部做长度校验
    /// - Parameters:
    ///   - from: 起始位置，nil 则从头开始截取
    ///   - to: 结束位置，nil 则截取到结尾
    /// - Returns: 截取字符串
    func jg_substring(from: Int? = nil, to: Int? = nil) -> String {
        return self[(from ?? 0) ..< (to ?? self.count)]
    }
    
    /// 字符串截取，内部做长度校验
    /// - Parameter range: 截取字符串Range
    /// - Returns: 截取字符串
    func jg_substring(range: NSRange) -> String {
        return self[range.location ..< (range.location + range.length)]
        //let _from = max(0, min(count, range.location)) // 合法起始位置
        //var length = range.length - (_from - range.location) // 起始位置偏移后的长度
        //length = min(count - _from, max(length, 0)) // 实际长度
        //
        //// 字符串方法
        //let subRange = NSRange(location: _from, length: length)
        //let beginIndex = index(startIndex, offsetBy: subRange.location)
        //let endIdx = index(beginIndex, offsetBy: subRange.length)
        //let subStr = String(self[beginIndex ..< endIdx])
        //return subStr
    }
    
    /// 安全的范围下标方法，防止越界访问
    subscript(_ range: Range<Int>) -> String {
        // 计算开始索引，确保不越界
        let beginIndex = self.index(self.startIndex, offsetBy: max(0, min(range.lowerBound, self.count)))
        // 计算结束索引，确保不越界
        let endIndex = self.index(self.startIndex, offsetBy: max(0, min(range.upperBound, self.count)))
        // 返回指定范围内的子字符串
        return String(self[beginIndex ..< endIndex])
    }
}

// 扩展 String 类型，可以在这里添加其他字符串相关的便捷方法
public
extension String {
    
}
