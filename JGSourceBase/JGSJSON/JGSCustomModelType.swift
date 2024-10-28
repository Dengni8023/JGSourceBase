//
//  JGSExtendCustomModelType.swift
//  JGSourceBase
//
//  Created by 梅继高 on 2024/10/24.
//  Copyright © 2024 MeiJiGao. All rights reserved.
//

import Foundation

// 参考 HandyJSON: ExtendCustomModelType.swift
// https://github.com/alibaba/handyjson

public protocol JGSCustomModelType: JGSTransformable {
    init()
    mutating func willStartMapping()
    mutating func mapping(mapper: HelpingMapper)
    mutating func didFinishMapping()
}

extension JGSCustomModelType {
    public mutating func willStartMapping() {}
    public mutating func mapping(mapper: HelpingMapper) {}
    public mutating func didFinishMapping() {}
}

fileprivate func getRawValueFrom(dict: [String: Any], property: JGSPropertyInfo, mapper: HelpingMapper) -> Any? {
    let address = Int(bitPattern: property.address)
    if let mappingHandler = mapper.getMappingHandler(key: address),
       let mappingPaths = mappingHandler.mappingPaths,
       mappingPaths.count > 0 {
        for mappingPath in mappingPaths {
            if let _value = dict.findValueBy(path: mappingPath) {
                return _value
            }
        }
        return nil
    }
    return dict[property.key]
}

fileprivate func convertValue(rawValue: Any, property: JGSPropertyInfo, mapper: HelpingMapper) -> Any? {
    if rawValue is NSNull {
        return nil
    }
    if let mappingHandler = mapper.getMappingHandler(key: Int(bitPattern: property.address)),
       let transformer = mappingHandler.assignmentClosure {
        return transformer(rawValue)
    }
    if let transformableType = property.type as? JGSTransformable.Type {
        return transformableType.jg_transform(from: rawValue)
    }
    return extensions(of: property.type).takeValue(from: rawValue)
}

fileprivate func assignProperty(convertedValue: Any, instance: JGSCustomModelType, property: JGSPropertyInfo) {
    if property.bridged {
        (instance as! NSObject).setValue(convertedValue, forKey: property.key)
    } else {
        extensions(of: property.type).write(convertedValue, to: property.address)
    }
}

fileprivate func readAllChildrenFrom(mirror: Mirror) -> [(String, Any)] {
    var children = [(label: String?, value: Any)]()
    children += mirror.children

    var currentMirror = mirror
    while let superclassChildren = currentMirror.superclassMirror?.children {
        children += superclassChildren
        currentMirror = currentMirror.superclassMirror!
    }
    var result = [(String, Any)]()
    children.forEach { (child) in
        if let _label = child.label {
            result.append((_label, child.value))
        }
    }
    return result
}

fileprivate func merge(children: [(String, Any)], propertyInfos: [JGSPropertyInfo]) -> [String: (Any, JGSPropertyInfo?)] {
    var infoDict = [String: JGSPropertyInfo]()
    propertyInfos.forEach { (info) in
        infoDict[info.key] = info
    }

    var result = [String: (Any, JGSPropertyInfo?)]()
    children.forEach { (child) in
        result[child.0] = (child.1, infoDict[child.0])
    }
    return result
}

// this's a workaround before https://bugs.swift.org/browse/SR-5223 fixed
extension NSObject {
    static func createInstance() -> NSObject {
        return self.init()
    }
}

extension JGSCustomModelType {

    static func _transform(from object: Any) -> Self? {
        if let dict = [String: Any].jg_transform(from: object) {
            // nested object, transform recursively
            return self._transform(dict: dict)
        }
        return nil
    }

    static func _transform(dict: [String: Any]) -> Self? {

        var instance: Self
        if let _nsType = Self.self as? NSObject.Type {
            instance = _nsType.createInstance() as! Self
        } else {
            instance = Self()
        }
        instance.willStartMapping()
        _transform(dict: dict, to: &instance)
        instance.didFinishMapping()
        return instance
    }

    static func _transform(dict: [String: Any], to instance: inout Self) {
        guard let properties = getProperties(forType: Self.self) else {
            JGSPrivateLogD("Failed when try to get properties from type: \(type(of: Self.self))")
            return
        }

        // do user-specified mapping first
        let mapper = HelpingMapper()
        instance.mapping(mapper: mapper)

        // get head addr
        let rawPointer = instance.headPointer()
        JGSPrivateLogD("instance start at: ", Int(bitPattern: rawPointer))

        // process dictionary
        let instanceIsNsObject = instance.isNSObjectType()
        let bridgedPropertyList = instance.getBridgedPropertyList()

        for property in properties {
            let isBridgedProperty = instanceIsNsObject && bridgedPropertyList.contains(property.key)

            let propAddr = rawPointer.advanced(by: property.offset)
            JGSPrivateLogD(property.key, "address at: ", Int(bitPattern: propAddr))
            if mapper.propertyExcluded(key: Int(bitPattern: propAddr)) {
                JGSPrivateLogD("Exclude property: \(property.key)")
                continue
            }

            let propertyDetail = JGSPropertyInfo(key: property.key, type: property.type, address: propAddr, bridged: isBridgedProperty)
            JGSPrivateLogD("field: ", property.key, "  offset: ", property.offset, "  isBridgeProperty: ", isBridgedProperty)

            if let rawValue = getRawValueFrom(dict: dict, property: propertyDetail, mapper: mapper) {
                if let convertedValue = convertValue(rawValue: rawValue, property: propertyDetail, mapper: mapper) {
                    assignProperty(convertedValue: convertedValue, instance: instance, property: propertyDetail)
                    continue
                }
            }
            JGSPrivateLogD("Property: \(property.key) hasn't been written in")
        }
    }
}

extension JGSCustomModelType {

    func _plainValue() -> Any? {
        return Self._serializeAny(object: self)
    }
    
    static func _serializeAny(object: JGSTransformable) -> Any? {

        let mirror = Mirror(reflecting: object)

        guard let displayStyle = mirror.displayStyle else {
            return object.jg_plainValue()
        }

        // after filtered by protocols above, now we expect the type is pure struct/class
        switch displayStyle {
        case .class, .struct:
            let mapper = HelpingMapper()
            // do user-specified mapping first
            if !(object is JGSCustomModelType) {
                JGSPrivateLogD("This model of type: \(type(of: object)) is not mappable but is class/struct type")
                return object
            }

            let children = readAllChildrenFrom(mirror: mirror)

            guard let properties = getProperties(forType: type(of: object)) else {
                JGSPrivateLogE("Can not get properties info for type: \(type(of: object))")
                return nil
            }

            var mutableObject = object as! JGSCustomModelType
            let instanceIsNsObject = mutableObject.isNSObjectType()
            let head = mutableObject.headPointer()
            let bridgedProperty = mutableObject.getBridgedPropertyList()
            let propertyInfos = properties.map({ (desc) -> JGSPropertyInfo in
                return JGSPropertyInfo(key: desc.key, type: desc.type, address: head.advanced(by: desc.offset),
                                        bridged: instanceIsNsObject && bridgedProperty.contains(desc.key))
            })

            mutableObject.mapping(mapper: mapper)

            let requiredInfo = merge(children: children, propertyInfos: propertyInfos)

            return _serializeModelObject(instance: mutableObject, properties: requiredInfo, mapper: mapper) as Any
        default:
            return object.jg_plainValue()
        }
    }

    static func _serializeModelObject(instance: JGSCustomModelType, properties: [String: (Any, JGSPropertyInfo?)], mapper: HelpingMapper) -> [String: Any] {

        var dict = [String: Any]()
        for (key, property) in properties {
            var realKey = key
            var realValue = property.0

            if let info = property.1 {
                if info.bridged, let _value = (instance as! NSObject).value(forKey: key) {
                    realValue = _value
                }

                if mapper.propertyExcluded(key: Int(bitPattern: info.address)) {
                    continue
                }

                if let mappingHandler = mapper.getMappingHandler(key: Int(bitPattern: info.address)) {
                    // if specific key is set, replace the label
                    if let mappingPaths = mappingHandler.mappingPaths, mappingPaths.count > 0 {
                        // take the first path, last segment if more than one
                        realKey = mappingPaths[0].segments.last!
                    }

                    if let transformer = mappingHandler.takeValueClosure {
                        if let _transformedValue = transformer(realValue) {
                            dict[realKey] = _transformedValue
                        }
                        continue
                    }
                }
            }

            if let typedValue = realValue as? JGSTransformable {
                if let result = self._serializeAny(object: typedValue) {
                    dict[realKey] = result
                    continue
                }
            }

            JGSPrivateLogD("The value for key: \(key) is not transformable type")
        }
        return dict
    }
}

// 参考 HandyJSON: PropertyInfo.swift
// https://github.com/alibaba/handyjson

struct JGSPropertyInfo {
    let key: String
    let type: Any.Type
    let address: UnsafeMutableRawPointer
    let bridged: Bool
}
