import CoreNFC
import Foundation

// MARK: - ISO 15693 协议读取器

/// 读取 ISO 15693 远距离 RFID 标签
/// 常用于图书馆管理、资产追踪、门禁系统等场景
class ISO15693Reader: NFCProtocolReader {

    var supportedProtocolType: NFCProtocolType { .iso15693 }
    var supportedTagType: NFCTag.Type { NFCTag.self }

    // MARK: - 读取

    func read(tag: NFCTag) async throws -> NFCTagInfo {
        guard case .iso15693(let isoTag) = tag else {
            throw NFCReaderError.tagNotSupported
        }

        let uid = isoTag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":")

        var records: [NFCRecord] = []
        var allRawData = Data()

        // 1. 读取系统信息
        let sysInfo = try await readSystemInfo(on: isoTag)
        if !sysInfo.data.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "ISO 15693",
                type: "系统信息",
                identifier: uid,
                payload: sysInfo.data,
                payloadText: sysInfo.description
            ))
            allRawData.append(sysInfo.data)
        }

        // 2. 读取块数据（尝试读取多个块）
        let blockData = try await readBlocks(on: isoTag, blockCount: sysInfo.blockCount)
        if !blockData.isEmpty {
            for (index, block) in blockData.enumerated() {
                records.append(NFCRecord(
                    typeNameFormat: "ISO 15693",
                    type: "块 \(index)",
                    identifier: uid,
                    payload: block,
                    payloadText: parseDataAsHex(block)
                ))
                allRawData.append(block)
            }
        }

        if records.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "ISO 15693",
                type: "基本信息",
                identifier: uid,
                payload: isoTag.identifier,
                payloadText: "UID: \(uid)"
            ))
            allRawData = isoTag.identifier
        }

        return NFCTagInfo(
            uid: uid,
            protocolType: .iso15693,
            manufacturer: queryManufacturer(from: isoTag),
            rawData: allRawData,
            parsedRecords: records,
            scanTime: Date()
        )
    }

    // MARK: - 系统信息

    struct SystemInfo {
        let data: Data
        let blockCount: UInt8
        let blockSize: Int
        let dsfid: Int
        let afi: Int

        var description: String {
            "块数: \(blockCount) | 块大小: \(blockSize) 字节 | D SFID: \(dsfid) | AFI: \(afi)"
        }
    }

    private func readSystemInfo(on tag: NFCISO15693Tag) async throws -> SystemInfo {
        return try await withCheckedThrowingContinuation { continuation in
            tag.getSystemInfo(requestFlags: [.highDataRate]) { dsfid, afi, blockSize, blockCount, icReference, error in
                if let error = error {
                    // 系统信息读取失败，返回默认值
                    continuation.resume(returning: SystemInfo(
                        data: Data(),
                        blockCount: 0,
                        blockSize: 4,
                        dsfid: 0,
                        afi: 0
                    ))
                } else {
                    let infoData = Data([
                        UInt8(dsfid ?? 0),
                        UInt8(afi ?? 0),
                        UInt8(blockSize ?? 0),
                        UInt8(blockCount ?? 0),
                        UInt8(icReference ?? 0)
                    ])
                    continuation.resume(returning: SystemInfo(
                        data: infoData,
                        blockCount: UInt8(blockCount ?? 0),
                        blockSize: blockSize ?? 4,
                        dsfid: dsfid ?? 0,
                        afi: afi ?? 0
                    ))
                }
            }
        }
    }

    // MARK: - 块数据读取

    private func readBlocks(on tag: NFCISO15693Tag, blockCount: UInt8) async throws -> [Data] {
        let maxBlocks = min(blockCount, 16)  // 最多读16个块，避免过长时间

        guard maxBlocks > 0 else {
            // 如果不知道块数，尝试读单个块
            return [try await readSingleBlock(on: tag, blockNumber: 0)]
        }

        var blocks: [Data] = []
        for i in 0..<maxBlocks {
            let block = try await readSingleBlock(on: tag, blockNumber: i)
            blocks.append(block)
        }
        return blocks
    }

    private func readSingleBlock(on tag: NFCISO15693Tag, blockNumber: UInt8) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            tag.readSingleBlock(requestFlags: [.highDataRate],
                                blockNumber: blockNumber) { data, error in
                if let error = error {
                    continuation.resume(returning: Data())
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }

    // MARK: - 解析方法

    private func parseDataAsHex(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    // MARK: - 制造商信息

    private func queryManufacturer(from tag: NFCISO15693Tag) -> String {
        let uidBytes = tag.identifier
        guard uidBytes.count >= 2 else { return "未知" }

        // ISO 15693 UID 前2字节为制造商代码
        let manufacturerCode = (UInt16(uidBytes[1]) << 8) | UInt16(uidBytes[0])

        switch manufacturerCode {
        case 0x0400: return "NXP Semiconductors (ICODE)"
        case 0x040E: return "NXP Semiconductors (SL2)"
        case 0x0501: return "Infineon"
        case 0x0502: return "STMicroelectronics"
        case 0x0503: return "Texas Instruments"
        case 0x0700: return "Samsung"
        default:     return "未知 (0x\(String(format: "%04X", manufacturerCode)))"
        }
    }
}
