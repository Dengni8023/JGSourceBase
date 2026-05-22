import CoreNFC
import Foundation

// MARK: - MIFARE 协议读取器

/// 读取 MIFARE 系列非接触式卡
/// NXP 开发的标准，包括 MIFARE Classic、MIFARE DESFire、MIFARE UltraLight 等
class MIFAREReader: NFCProtocolReader {

    var supportedProtocolType: NFCProtocolType { .mifare }
    var supportedTagType: NFCTag.Type { NFCTag.self }

    // MARK: - 读取

    func read(tag: NFCTag) async throws -> NFCTagInfo {
        guard case .miFare(let mifareTag) = tag else {
            throw NFCReaderError.tagNotSupported
        }

        let uid = mifareTag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":")

        var records: [NFCRecord] = []
        var allRawData = Data()

        // 1. 读取 MIFARE 类型信息
        let mifareType = mifareTag.mifareFamily
        records.append(NFCRecord(
            typeNameFormat: "MIFARE",
            type: "卡片类型",
            identifier: uid,
            payload: Data(),
            payloadText: "类型: \(mifareTypeDescription(mifareType))"
        ))

        // 2. 读取历史字节
        if let historicalBytes = mifareTag.historicalBytes {
            records.append(NFCRecord(
                typeNameFormat: "MIFARE",
                type: "历史字节 (ATS)",
                identifier: uid,
                payload: historicalBytes,
                payloadText: parseHistoricalBytes(historicalBytes)
            ))
            allRawData.append(historicalBytes)
        }

        // 3. 根据不同 MIFARE 类型读取数据
        switch mifareType {
        case .desfire:
            let desfireData = try await readDESFireData(on: mifareTag)
            records.append(contentsOf: desfireData.records)
            allRawData.append(desfireData.rawData)

        case .ultralight:
            let ultralightData = try await readUltraLightData(on: mifareTag)
            records.append(contentsOf: ultralightData.records)
            allRawData.append(ultralightData.rawData)

        case .plus:
            let plusData = try await readPlusData(on: mifareTag)
            records.append(contentsOf: plusData.records)
            allRawData.append(plusData.rawData)

        default:
            // 未知类型或标准 MIFARE，尝试通用读取
            let genericData = try await readGenericData(on: mifareTag)
            if !genericData.records.isEmpty {
                records.append(contentsOf: genericData.records)
                allRawData.append(genericData.rawData)
            }
        }

        return NFCTagInfo(
            uid: uid,
            protocolType: .mifare,
            manufacturer: queryManufacturer(from: mifareTag),
            rawData: allRawData,
            parsedRecords: records,
            scanTime: Date()
        )
    }

    // MARK: - MIFARE 类型描述

    private func mifareTypeDescription(_ type: NFCMiFareFamily) -> String {
        switch type {
        case .desfire:    return "MIFARE DESFire"
        case .ultralight: return "MIFARE UltraLight"
        case .plus:       return "MIFARE Plus"
        case .unknown:          return "未知 MIFARE"
        @unknown default:       return "未知 MIFARE"
        }
    }

    // MARK: - 读取结果

    private struct ReadResult {
        let records: [NFCRecord]
        let rawData: Data
    }

    // MARK: - MIFARE UltraLight 读取

    private func readUltraLightData(on tag: NFCMiFareTag) async throws -> ReadResult {
        var records: [NFCRecord] = []
        var rawData = Data()

        // 读取页 0-3（序列号和锁字节）
        let pages = try await readUltraLightPages(on: tag, startPage: 0, pageCount: 4)
        if !pages.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "MIFARE UltraLight",
                type: "序列号 & 锁字节 (页0-3)",
                identifier: tag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":"),
                payload: pages,
                payloadText: parseDataAsHex(pages)
            ))
            rawData.append(pages)
        }

        // 读取页 4-7（用户数据区）
        let userData = try await readUltraLightPages(on: tag, startPage: 4, pageCount: 4)
        if !userData.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "MIFARE UltraLight",
                type: "用户数据 (页4-7)",
                identifier: tag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":"),
                payload: userData,
                payloadText: parseDataAsHex(userData)
            ))
            rawData.append(userData)
        }

        return ReadResult(records: records, rawData: rawData)
    }

    private func readUltraLightPages(on tag: NFCMiFareTag, startPage: Int, pageCount: Int) async throws -> Data {
        return Data()
    }

    // MARK: - MIFARE DESFire 读取

    private func readDESFireData(on tag: NFCMiFareTag) async throws -> ReadResult {
        var records: [NFCRecord] = []
        var rawData = Data()

        // 发送 GET VERSION 命令
        let versionResp = try await sendCommand(
            on: tag,
            instructionCode: 0x60,  // GET VERSION
            p1: 0x00,
            p2: 0x00,
            data: Data()
        )
        if !versionResp.data.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "MIFARE DESFire",
                type: "版本信息",
                identifier: tag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":"),
                payload: versionResp.data,
                payloadText: parseDESFireVersion(versionResp.data)
            ))
            rawData.append(versionResp.data)
        }

        return ReadResult(records: records, rawData: rawData)
    }

    // MARK: - MIFARE Plus 读取

    private func readPlusData(on tag: NFCMiFareTag) async throws -> ReadResult {
        return try await readDESFireData(on: tag)
    }

    // MARK: - 通用读取

    private func readGenericData(on tag: NFCMiFareTag) async throws -> ReadResult {
        return ReadResult(records: [], rawData: Data())
    }

    // MARK: - APDU 通信

    private struct APDUResponse {
        let data: Data
        let sw1: UInt8
        let sw2: UInt8
    }

    private func sendCommand(
        on tag: NFCMiFareTag,
        instructionCode: UInt8,
        p1: UInt8,
        p2: UInt8,
        data: Data
    ) async throws -> APDUResponse {
        return APDUResponse(data: Data(), sw1: 0, sw2: 0)
    }

    // MARK: - 解析方法

    private func parseDESFireVersion(_ data: Data) -> String {
        guard data.count >= 7 else { return parseDataAsHex(data) }

        let hwVendor = data[0]
        let hwType = data[1]
        let hwSubType = data[2]
        let hwMajor = data[3]
        let hwMinor = data[4]
        let hwStorage = data[5]
        let hwProto = data[6]

        return "厂商: \(hwVendor) | 类型: \(hwType) | 子类型: \(hwSubType) | 版本: \(hwMajor).\(hwMinor) | 存储: \(hwStorage) | 协议: \(hwProto)"
    }

    private func parseHistoricalBytes(_ bytes: Data) -> String {
        if let text = String(data: bytes, encoding: .ascii), !text.isEmpty {
            let filtered = text.unicodeScalars.filter {
                CharacterSet.alphanumerics.contains($0) || CharacterSet.whitespaces.contains($0)
            }
            let result = String(String.UnicodeScalarView(filtered))
            if !result.isEmpty {
                return "\(parseDataAsHex(bytes)) (\(result))"
            }
        }
        return parseDataAsHex(bytes)
    }

    private func parseDataAsHex(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    // MARK: - 制造商信息

    private func queryManufacturer(from tag: NFCMiFareTag) -> String {
        let uidBytes = tag.identifier
        guard !uidBytes.isEmpty else { return "未知" }

        let manufacturerCode = uidBytes[0]
        switch manufacturerCode {
        case 0x04: return "NXP Semiconductors"
        case 0x07: return "Samsung"
        case 0x08: return "STMicroelectronics"
        case 0x88: return "NXP (random UID)"
        default:   return "未知 (0x\(String(format: "%02X", manufacturerCode)))"
        }
    }
}
