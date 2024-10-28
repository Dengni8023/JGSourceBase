//
//  JGSISO8601DateTransform.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: ISO8601DateTransform.swift
// https://github.com/alibaba/handyjson

open class ISO8601DateTransform: DateFormatterTransform {

    public init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        super.init(dateFormatter: formatter)
    }
}
