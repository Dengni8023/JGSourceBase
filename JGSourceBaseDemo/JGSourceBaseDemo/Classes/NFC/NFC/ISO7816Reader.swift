import CoreNFC
import Foundation

// MARK: - ISO 7816 协议读取器

/// 读取 ISO 7816 智能卡
/// 广泛应用于银行卡、门禁卡、SIM卡、身份证等
class ISO7816Reader: NFCProtocolReader {

    var supportedProtocolType: NFCProtocolType { .iso7816 }
    var supportedTagType: NFCTag.Type { NFCTag.self }

    // MARK: - 读取

    func read(tag: NFCTag) async throws -> NFCTagInfo {
        guard case .iso7816(let isoTag) = tag else {
            throw NFCReaderError.tagNotSupported
        }

        let uid = isoTag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":")

        // 读取标签基本信息
        var records: [NFCRecord] = []
        var allRawData = Data()

        // 1. 读取应用标识
        let selectResponse = try await selectApplication(on: isoTag)
        if !selectResponse.data.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "ISO 7816",
                type: "SELECT 响应",
                identifier: uid,
                payload: selectResponse.data,
                payloadText: parseAPDUResponse(selectResponse)
            ))
            allRawData.append(selectResponse.data)
        }

        // 2. 读取历史字节（卡片能力信息）
        if let historicalBytes = isoTag.historicalBytes {
            records.append(NFCRecord(
                typeNameFormat: "ISO 7816",
                type: "历史字节",
                identifier: uid,
                payload: historicalBytes,
                payloadText: parseHistoricalBytes(historicalBytes)
            ))
            allRawData.append(historicalBytes)
        }

        // 3. 读取应用数据
        let readResponse = try await readApplicationData(on: isoTag)
        if !readResponse.data.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "ISO 7816",
                type: "应用数据",
                identifier: uid,
                payload: readResponse.data,
                payloadText: parseDataAsHex(readResponse.data)
            ))
            allRawData.append(readResponse.data)
        }

        if records.isEmpty {
            records.append(NFCRecord(
                typeNameFormat: "ISO 7816",
                type: "基本信息",
                identifier: uid,
                payload: isoTag.identifier,
                payloadText: "UID: \(uid)"
            ))
            allRawData = isoTag.identifier
        }

        return NFCTagInfo(
            uid: uid,
            protocolType: .iso7816,
            manufacturer: queryManufacturer(from: isoTag),
            rawData: allRawData,
            parsedRecords: records,
            scanTime: Date()
        )
    }

    // MARK: - APDU 命令

    /// 选择应用（发送 SELECT 命令）
    private func selectApplication(on tag: NFCISO7816Tag) async throws -> (data: Data, sw1: UInt8, sw2: UInt8) {
        // SELECT 命令：选择 MF (Master File)
        // INS=0xA4 是 ISO 7816 标准的 SELECT 指令
        let selectAPDU = NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: 0xA4,  // SELECT command
            p1Parameter: 0x04,      // Select by DF name
            p2Parameter: 0x00,      // First or only occurrence
            data: Data([0x3F, 0x00]),  // MF AID
            expectedResponseLength: 256
        )

        return try await withCheckedThrowingContinuation { continuation in
            tag.sendCommand(apdu: selectAPDU) { data, sw1, sw2, error in
                if let error = error {
                    continuation.resume(throwing: NFCReaderError.readFailed(error.localizedDescription))
                } else {
                    continuation.resume(returning: (data, sw1, sw2))
                }
            }
        }
    }

    /// 读取应用数据（发送 READ BINARY 命令）
    private func readApplicationData(on tag: NFCISO7816Tag) async throws -> (data: Data, sw1: UInt8, sw2: UInt8) {
        // READ BINARY 命令
        let readAPDU = NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: 0xB0,  // READ BINARY
            p1Parameter: 0x00,
            p2Parameter: 0x00,
            data: Data(),
            expectedResponseLength: 256
        )

        return try await withCheckedThrowingContinuation { continuation in
            tag.sendCommand(apdu: readAPDU) { data, sw1, sw2, error in
                if let error = error {
                    // 读取失败不中断，返回空数据
                    continuation.resume(returning: (Data(), sw1, sw2))
                } else {
                    continuation.resume(returning: (data, sw1, sw2))
                }
            }
        }
    }

    // MARK: - 解析方法

    private func parseAPDUResponse(_ response: (data: Data, sw1: UInt8, sw2: UInt8)) -> String {
        var parts: [String] = []
        if !response.data.isEmpty {
            parts.append("数据: \(parseDataAsHex(response.data))")
        }
        parts.append("状态: SW1=\(String(format: "%02X", response.sw1)) SW2=\(String(format: "%02X", response.sw2))")

        // 解析常见状态码
        let sw = (UInt16(response.sw1) << 8) | UInt16(response.sw2)
        switch sw {
        case 0x9000: parts.append("(成功)")
        case 0x6A82: parts.append("(文件未找到)")
        case 0x6982: parts.append("(安全状态不满足)")
        case 0x6985: parts.append("(条件不满足)")
        default: break
        }
        return parts.joined(separator: " | ")
    }

    private func parseHistoricalBytes(_ bytes: Data) -> String {
        if let text = String(data: bytes, encoding: .utf8), !text.isEmpty {
            return "\(parseDataAsHex(bytes)) (\(text))"
        }
        return parseDataAsHex(bytes)
    }

    private func parseDataAsHex(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    // MARK: - 制造商信息

    private func queryManufacturer(from tag: NFCISO7816Tag) -> String {
        let uidBytes = tag.identifier
        guard !uidBytes.isEmpty else { return "未知" }

        let manufacturerCode = uidBytes[0]
        switch manufacturerCode {
        case 0x04: return "NXP Semiconductors"
        case 0x07: return "Samsung"
        case 0x3B: return "Infineon"
        case 0x28: return "Infineon (旧)"
        default:    return "未知 (0x\(String(format: "%02X", manufacturerCode)))"
        }
    }
}
