import CoreNFC
import UIKit

// MARK: - NFC 会话管理器

/// 统一管理 NFCTagReaderSession 的生命周期
/// 负责启动扫描、识别标签类型、分发到对应协议读取器
class NFCSessionManager: NSObject {

    // MARK: - 单例

    static let shared = NFCSessionManager()

    // MARK: - 属性

    /// 所有已注册的协议读取器
    private var readers: [NFCProtocolReader] = []

    /// 当前会话
    private var session: NFCTagReaderSession?
    //private var session: NFCNDEFReaderSession?

    /// 当前会话状态
    private(set) var state: NFCSessionState = .idle {
        didSet { stateDidChange?(state) }
    }

    /// 状态变更回调
    var stateDidChange: ((NFCSessionState) -> Void)?

    /// 扫描结果回调
    var didScanTag: ((NFCTagInfo) -> Void)?

    /// 错误回调
    var didEncounterError: ((NFCReaderError) -> Void)?

    /// 协议筛选（空数组表示支持所有协议）
    var enabledProtocols: [NFCProtocolType] = []

    // MARK: - 初始化

    private override init() {
        super.init()
        registerDefaultReaders()
    }

    // MARK: - 注册读取器

    func registerReader(_ reader: NFCProtocolReader) {
        readers.append(reader)
    }

    func unregisterReader(for protocolType: NFCProtocolType) {
        readers.removeAll { $0.supportedProtocolType == protocolType }
    }

    private func registerDefaultReaders() {
        registerReader(ISO7816Reader())
        registerReader(ISO15693Reader())
        registerReader(FeliCaReader())
        registerReader(MIFAREReader())
    }

    // MARK: - 会话控制

    /// 检查 NFC 是否可用
    var isNFCAvailable: Bool {
        return NFCTagReaderSession.readingAvailable
    }

    /// 启动扫描会话
    func startScanning() {
        guard isNFCAvailable else {
            let error = NFCReaderError.sessionNotAvailable
            state = .error(error)
            didEncounterError?(error)
            return
        }

        // 结束旧会话
        invalidateSession()

        // 创建新会话
        var options: NFCTagReaderSession.PollingOption = [.iso14443, .iso15693, .iso18092]
        if #available(iOS 16, *) {
            options.insert(.pace)
        }
        //session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session = NFCTagReaderSession(pollingOption: options, delegate: self)
        state = .scanning
        session?.begin()
    }

    /// 结束当前会话
    func invalidateSession() {
        session?.invalidate()
        session = nil
        if state.isBusy {
            state = .idle
        }
    }

    /// 提示消息（显示在 NFC 扫描弹窗上）
    func alertMessage(_ message: String) {
        session?.alertMessage = message
    }
}

// MARK: - NFCTagReaderSessionDelegate

extension NFCSessionManager: NFCTagReaderSessionDelegate {

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .scanning
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession,
                          didInvalidateWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let readerError = error as? NFCReaderError {
                switch readerError {
                case .userCancelled:
                    self.state = .error(.userCancelled)
                    self.didEncounterError?(.userCancelled)
                case .timeout:
                    self.state = .error(.timeout)
                    self.didEncounterError?(.timeout)
                default:
                    self.state = .error(.readFailed(error.localizedDescription))
                    self.didEncounterError?(.readFailed(error.localizedDescription))
                }
            } else {
                self.state = .error(.readFailed(error.localizedDescription))
                self.didEncounterError?(.readFailed(error.localizedDescription))
            }
            self.session = nil
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession,
                          didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else { return }

        DispatchQueue.main.async { [weak self] in
            self?.state = .connected
        }

        // 根据标签类型查找匹配的读取器
        guard let reader = findReader(for: firstTag) else {
            session.alertMessage = "不支持的标签类型"
            session.invalidate()
            DispatchQueue.main.async { [weak self] in
                self?.state = .error(.tagNotSupported)
                self?.didEncounterError?(.tagNotSupported)
            }
            return
        }

        // 协议筛选检查
        if !enabledProtocols.isEmpty && !enabledProtocols.contains(reader.supportedProtocolType) {
            session.alertMessage = "当前协议未启用：\(reader.supportedProtocolType.displayName)"
            session.invalidate()
            return
        }

        // 连接并读取
        session.connect(to: firstTag) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                session.alertMessage = "连接失败：\(error.localizedDescription)"
                session.invalidate()
                DispatchQueue.main.async {
                    self.state = .error(.connectionFailed)
                    self.didEncounterError?(.connectionFailed)
                }
                return
            }

            DispatchQueue.main.async {
                self.state = .reading
            }

            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let tagInfo = try await reader.read(tag: firstTag)
                    session.alertMessage = "读取成功"
                    session.invalidate()

                    DispatchQueue.main.async {
                        self.state = .completed
                        self.didScanTag?(tagInfo)
                        // 保存到历史
                        let record = ScanRecord(from: tagInfo)
                        ScanHistoryManager.shared.addRecord(record)
                    }
                } catch {
                    session.alertMessage = "读取失败：\(error.localizedDescription)"
                    session.invalidate()

                    DispatchQueue.main.async {
                        let readerError = error as? NFCReaderError ?? .readFailed(error.localizedDescription)
                        self.state = .error(readerError)
                        self.didEncounterError?(readerError)
                    }
                }
            }
        }
    }

    // MARK: - 私有方法

    private func findReader(for tag: NFCTag) -> NFCProtocolReader? {
        switch tag {
        case .iso7816:
            return readers.first { $0.supportedProtocolType == .iso7816 }
        case .iso15693:
            return readers.first { $0.supportedProtocolType == .iso15693 }
        case .feliCa:
            return readers.first { $0.supportedProtocolType == .felica }
        case .miFare:
            return readers.first { $0.supportedProtocolType == .mifare }
        @unknown default:
            return nil
        }
    }
}


extension NFCSessionManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        JGSLog("error:", error)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        JGSLog("messages:", messages)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        JGSLog("tags:", tags)
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        JGSLog()
    }
}
