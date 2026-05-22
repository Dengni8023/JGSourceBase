import Foundation

// MARK: - NFC 协议类型

enum NFCProtocolType: String, CaseIterable {
    case iso7816 = "ISO 7816"
    case iso15693 = "ISO 15693"
    case felica = "FeliCa"
    case mifare = "MIFARE"

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .iso7816:  return "💳"
        case .iso15693: return "📡"
        case .felica:   return "🚃"
        case .mifare:   return "🔑"
        }
    }

    var color: String {
        switch self {
        case .iso7816:  return "#0984E3"
        case .iso15693: return "#00B894"
        case .felica:   return "#E17055"
        case .mifare:   return "#FDCB6E"
        }
    }
}

// MARK: - NFC 记录

struct NFCRecord {
    let typeNameFormat: String
    let type: String
    let identifier: String
    let payload: Data
    let payloadText: String

    var displayTitle: String {
        if !type.isEmpty { return type }
        if !typeNameFormat.isEmpty { return typeNameFormat }
        return "Record"
    }
}

// MARK: - NFC 标签信息

struct NFCTagInfo {
    let uid: String
    let protocolType: NFCProtocolType
    let manufacturer: String
    let rawData: Data
    let parsedRecords: [NFCRecord]
    let scanTime: Date

    var uidDisplay: String {
        uid.isEmpty ? "未知" : uid
    }

    var rawDataHex: String {
        rawData.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    var recordCount: Int {
        parsedRecords.count
    }

    var summary: String {
        "\(protocolType.displayName) | UID: \(uidDisplay) | \(recordCount) 条记录"
    }
}
