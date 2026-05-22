import Foundation

// MARK: - 扫描记录（持久化模型）

struct ScanRecord: Codable {
    let id: UUID
    let uid: String
    let protocolType: String
    let manufacturer: String
    let rawDataHex: String
    let recordCount: Int
    let scanTime: Date

    init(from tagInfo: NFCTagInfo) {
        self.id = UUID()
        self.uid = tagInfo.uid
        self.protocolType = tagInfo.protocolType.rawValue
        self.manufacturer = tagInfo.manufacturer
        self.rawDataHex = tagInfo.rawDataHex
        self.recordCount = tagInfo.recordCount
        self.scanTime = tagInfo.scanTime
    }

    var displayTitle: String {
        "\(protocolType) - \(uid.prefix(8))"
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: scanTime)
    }
}

// MARK: - 扫描历史管理器

class ScanHistoryManager {

    static let shared = ScanHistoryManager()

    private let defaults = UserDefaults.standard
    private let historyKey = "nfc_scan_history"

    private init() {}

    // MARK: - 增删查

    func addRecord(_ record: ScanRecord) {
        var records = getAllRecords()
        records.insert(record, at: 0)
        // 最多保留 100 条
        if records.count > 100 {
            records = Array(records.prefix(100))
        }
        saveRecords(records)
    }

    func getAllRecords() -> [ScanRecord] {
        guard let data = defaults.data(forKey: historyKey) else { return [] }
        return (try? JSONDecoder().decode([ScanRecord].self, from: data)) ?? []
    }

    func deleteRecord(id: UUID) {
        var records = getAllRecords()
        records.removeAll { $0.id == id }
        saveRecords(records)
    }

    func clearAll() {
        defaults.removeObject(forKey: historyKey)
    }

    // MARK: - Private

    private func saveRecords(_ records: [ScanRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: historyKey)
    }
}
