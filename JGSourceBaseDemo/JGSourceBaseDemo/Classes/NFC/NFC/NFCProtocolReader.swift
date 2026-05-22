import CoreNFC

// MARK: - NFC 协议读取器接口

/// 所有 NFC 协议读取器必须遵循的协议
/// 定义了统一的读取接口，便于 NFCSessionManager 根据标签类型分发
protocol NFCProtocolReader: AnyObject {

    /// 该读取器支持的协议类型
    var supportedProtocolType: NFCProtocolType { get }

    /// 该读取器支持的 NFCTag 类型
    var supportedTagType: NFCTag.Type { get }

    /// 从标签中读取数据
    /// - Parameter tag: 检测到的 NFC 标签
    /// - Returns: 解析后的标签信息
    /// - Throws: 读取过程中可能抛出的错误
    func read(tag: NFCTag) async throws -> NFCTagInfo
}

// MARK: - NFC 读取错误

enum NFCReaderError: LocalizedError {
    case sessionNotAvailable
    case tagNotSupported
    case connectionFailed
    case readFailed(String)
    case invalidData
    case timeout
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .sessionNotAvailable:
            return "NFC 不可用，请确认设备支持 NFC 且已开启"
        case .tagNotSupported:
            return "不支持的标签类型"
        case .connectionFailed:
            return "无法连接到标签，请重试"
        case .readFailed(let reason):
            return "读取失败：\(reason)"
        case .invalidData:
            return "标签数据无效"
        case .timeout:
            return "读取超时，请重试"
        case .userCancelled:
            return "用户取消扫描"
        }
    }
}

// MARK: - NFC 会话状态

enum NFCSessionState {
    case idle
    case scanning
    case connected
    case reading
    case completed
    case error(NFCReaderError)

    var isBusy: Bool {
        switch self {
        case .scanning, .connected, .reading:
            return true
        default:
            return false
        }
    }

    var displayText: String {
        switch self {
        case .idle:       return "准备就绪"
        case .scanning:   return "扫描中..."
        case .connected:  return "已检测到标签"
        case .reading:    return "正在读取..."
        case .completed:  return "读取完成"
        case .error(let e): return e.localizedDescription
        }
    }
}
