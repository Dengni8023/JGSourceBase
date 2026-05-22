import CoreNFC
import Foundation

// MARK: - FeliCa 协议读取器

/// 读取 FeliCa 非接触式 IC 卡
/// Sony 开发的标准，广泛用于日本交通卡（Suica、PASMO）、八达通等
class FeliCaReader: NFCProtocolReader {

    var supportedProtocolType: NFCProtocolType { .felica }
    var supportedTagType: NFCTag.Type { NFCTag.self }

    // MARK: - 读取

    func read(tag: NFCTag) async throws -> NFCTagInfo {
        guard case .feliCa(let felicaTag) = tag else {
            throw NFCReaderError.tagNotSupported
        }

        let uid = felicaTag.currentIDm.map { String(format: "%02X", $0) }.joined(separator: ":")

        var records: [NFCRecord] = []
        var allRawData = Data()

        // 1. 读取系统代码列表
        let systemCode = felicaTag.currentSystemCode
        let systemCodeHex = systemCode.map { String(format: "%02X", $0) }.joined()
        records.append(NFCRecord(
            typeNameFormat: "FeliCa",
            type: "系统代码",
            identifier: uid,
            payload: systemCode,
            payloadText: "System Code: \(systemCodeHex)"
        ))
        allRawData.append(systemCode)

        // 2. 读取 PMm（制造信息）
        let pmm = felicaTag.currentIDm
        let pmmHex = pmm.map { String(format: "%02X", $0) }.joined(separator: ":")
        records.append(NFCRecord(
            typeNameFormat: "FeliCa",
            type: "制造信息 (PMm)",
            identifier: uid,
            payload: pmm,
            payloadText: "PMm: \(pmmHex) | \(parsePMm(pmm))"
        ))
        allRawData.append(pmm)

        // 3. 轮询（获取卡片状态）
        let pollResponse = try await polling(tag: felicaTag)
        if !pollResponse.data.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "FeliCa",
                type: "轮询响应",
                identifier: uid,
                payload: pollResponse.data,
                payloadText: pollResponse.description
            ))
            allRawData.append(pollResponse.data)
        }

        // 4. 读取服务数据
        let serviceData = try await readServiceData(tag: felicaTag)
        for (index, data) in serviceData.enumerated() {
            records.append(NFCRecord(
                typeNameFormat: "FeliCa",
                type: "服务数据 #\(index + 1)",
                identifier: uid,
                payload: data,
                payloadText: parseDataAsHex(data)
            ))
            allRawData.append(data)
        }

        return NFCTagInfo(
            uid: uid,
            protocolType: .felica,
            manufacturer: parseManufacturerFromPMm(pmm),
            rawData: allRawData,
            parsedRecords: records,
            scanTime: Date()
        )
    }

    // MARK: - FeliCa 命令

    struct PollingResponse {
        let data: Data
        let description: String
    }

    /// 轮询命令，获取卡片基本信息
    private func polling(tag: NFCFeliCaTag) async throws -> PollingResponse {
        return try await withCheckedThrowingContinuation { continuation in
            tag.polling(systemCode: tag.currentSystemCode, requestCode: .systemCode, timeSlot: .max8) { pmm, requestData, error in
                if let error = error {
                    continuation.resume(returning: PollingResponse(
                        data: Data(),
                        description: "轮询失败: \(error.localizedDescription)"
                    ))
                } else {
                    var requestDataStr = requestData.map { String(format: "%02X", $0) }.joined(separator: " ")
                    continuation.resume(returning: PollingResponse(
                        data: requestData,
                        description: requestDataStr
                    ))
                }
            }
        }
    }

    /// 读取服务数据（尝试常见服务代码）
    private func readServiceData(tag: NFCFeliCaTag) async throws -> [Data] {
        var results: [Data] = []

        // 常见 FeliCa 服务代码
        let serviceCodes: [UInt16] = [
            0x0009,  // Suica 历史记录
            0x008B,  // Suica 余额
            0x004B,  // 八达通
            0x090F,  // 通用
        ]

        for serviceCode in serviceCodes {
            let data = try await readBlockList(tag: tag, serviceCode: serviceCode)
            if !data.isEmpty {
                results.append(data)
            }
        }

        return results
    }

    /// 读取指定服务的块列表
    private func readBlockList(tag: NFCFeliCaTag, serviceCode: UInt16) async throws -> Data {
        // 服务代码（2字节，小端序）
        let serviceCodeData = Data([UInt8(serviceCode & 0xFF), UInt8(serviceCode >> 8)])
        // 块列表：0x80 表示服务代码模式，0x00 表示第0块
        let blockListData = Data([0x80, 0x00])

        return try await withCheckedThrowingContinuation { continuation in
            tag.readWithoutEncryption(serviceCodeList: [serviceCodeData],
                                      blockList: [blockListData]) { status1, status2, blockData, error in
                if let error = error, status1 != 0x00 {
                    continuation.resume(returning: Data())
                } else {
                    var combined = Data()
                    for block in blockData {
                        combined.append(block)
                    }
                    continuation.resume(returning: combined)
                }
            }
        }
    }

    // MARK: - 解析方法

    /// 解析 PMm（制造信息）
    private func parsePMm(_ pmm: Data) -> String {
        guard pmm.count >= 8 else { return "数据不足" }

        let icType = pmm[0]
        let romType = pmm[6]
        let icVersion = pmm[7]

        var parts: [String] = []
        parts.append("IC: 0x\(String(format: "%02X", icType))")

        switch icType {
        case 0x01: parts.append("(FeliCa Standard)")
        case 0x02: parts.append("(FeliCa Lite)")
        case 0x03: parts.append("(FeliCa Link)")
        case 0x0F: parts.append("(Mobile FeliCa)")
        default:   parts.append("(未知 IC)")
        }

        parts.append("ROM: 0x\(String(format: "%02X", romType))")
        parts.append("Ver: 0x\(String(format: "%02X", icVersion))")

        return parts.joined(separator: " | ")
    }

    /// 从 PMm 解析制造商
    private func parseManufacturerFromPMm(_ pmm: Data) -> String {
        guard pmm.count >= 1 else { return "未知" }

        switch pmm[0] {
        case 0x01, 0x02, 0x03: return "Sony (FeliCa)"
        case 0x0F: return "Sony (Mobile FeliCa)"
        default: return "未知 IC (0x\(String(format: "%02X", pmm[0])))"
        }
    }

    private func parseDataAsHex(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}
