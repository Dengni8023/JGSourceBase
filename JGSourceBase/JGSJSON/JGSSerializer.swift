//
//  JGSSerializer.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: Serializer.swift
// https://github.com/alibaba/handyjson

public extension JGSJSON {

    func toJSON() -> [String: Any]? {
        if let dict = Self._serializeAny(object: self) as? [String: Any] {
            return dict
        }
        return nil
    }

    func toJSONString(prettyPrint: Bool = false) -> String? {

        if let anyObject = self.toJSON() {
            if JSONSerialization.isValidJSONObject(anyObject) {
                do {
                    let jsonData: Data
                    if prettyPrint {
                        jsonData = try JSONSerialization.data(withJSONObject: anyObject, options: [.prettyPrinted])
                    } else {
                        jsonData = try JSONSerialization.data(withJSONObject: anyObject, options: [])
                    }
                    return String(data: jsonData, encoding: .utf8)
                } catch let error {
                    JGSPrivateLogE(error)
                }
            } else {
                JGSPrivateLogD("\(anyObject)) is not a valid JSON Object")
            }
        }
        return nil
    }
}

public extension Collection where Element: JGSJSON {

    func toJSON() -> [[String: Any]?] {
        return self.map{ $0.toJSON() }
    }

    func toJSONString(prettyPrint: Bool = false) -> String? {

        let anyArray = self.toJSON()
        if JSONSerialization.isValidJSONObject(anyArray) {
            do {
                let jsonData: Data
                if prettyPrint {
                    jsonData = try JSONSerialization.data(withJSONObject: anyArray, options: [.prettyPrinted])
                } else {
                    jsonData = try JSONSerialization.data(withJSONObject: anyArray, options: [])
                }
                return String(data: jsonData, encoding: .utf8)
            } catch let error {
                JGSPrivateLogE(error)
            }
        } else {
            JGSPrivateLogD("\(self.toJSON()) is not a valid JSON Object")
        }
        return nil
    }
}
