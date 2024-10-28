//
//  JGSJSON.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2023/4/26.
//  Copyright © 2023 MeiJiGao. All rights reserved.
//

import Foundation
import UIKit

// 数据、对象类型转换，参考：
// SwiftyJSON: https://github.com/SwiftyJSON/SwiftyJSON
// HandyJSON: https://github.com/alibaba/handyjson

/// 自定义转换实现
/// 需要继承协议后自定义实现转换协议方法
public protocol JGSCustomTransform: JGSTransformable {
    // 参考 HandyJSON: ExtendCustomBasicType.swift
    static func jg_transform(from object: Any) -> Self?
    func jg_plainValue() -> Any?
}

/// 枚举类型
public protocol JGSJSONEnum: JGSRawRepresentable {}

/// 自定义数据类型
public protocol JGSJSON: JGSCustomModelType {}
