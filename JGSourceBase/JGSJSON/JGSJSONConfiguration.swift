//
//  JGSJSONConfiguration.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/7/11.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation

public struct JGSJSONDeserializeOptions: OptionSet {
    
    public static let caseInsensitive = JGSJSONDeserializeOptions(rawValue: 1 << 0)
    public static let defaultOptions: JGSJSONDeserializeOptions = []
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct JGSJSONConfiguration {
    
    static var deserializeOptions: JGSJSONDeserializeOptions = .defaultOptions
}
