import UIKit
import CoreNFC

// MARK: - NFC 读取器主界面

class NFCReaderViewController: UIViewController {

    // MARK: - UI 组件

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    /// 顶部标题栏
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "NFC 读取器"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "扫描并读取不同协议的 NFC 标签"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textTertiary
        return label
    }()

    /// 历史按钮
    private let historyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        btn.tintColor = .accentCyan
        btn.backgroundColor = .bgTertiary.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 20
        return btn
    }()

    /// 扫描动画区
    private let scanContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let pulseView = PulseAnimationView()

    /// 扫描按钮
    private let scanButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("开始扫描", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btn.setTitleColor(.textPrimary, for: .normal)
        btn.backgroundColor = .accentPurple
        btn.layer.cornerRadius = 28
        btn.layer.shadowColor = UIColor.accentPurple.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 12
        btn.layer.shadowOpacity = 0.4
        return btn
    }()

    /// 状态标签
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "准备就绪"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .accentCyan
        label.textAlignment = .center
        return label
    }()

    /// 协议选择区标题
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "协议筛选"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .textSecondary
        return label
    }()

    /// 协议标签容器
    private let protocolStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillProportionally
        sv.alignment = .center
        return sv
    }()

    /// 协议标签视图
    private var protocolTags: [ProtocolTagView] = []

    /// 最近扫描卡片
    private let recentCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .bgSecondary.withAlphaComponent(0.6)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.textTertiary.withAlphaComponent(0.1).cgColor
        return view
    }()

    private let recentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "最近扫描"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .textTertiary
        return label
    }()

    private let recentContentLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无扫描记录"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    /// 底部提示
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.text = "需要 iPhone 7 及以上设备 | 仅支持真机调试"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textTertiary.withAlphaComponent(0.6)
        label.textAlignment = .center
        return label
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindSessionManager()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanButton.applyGradient(colors: [.accentPurple, .accentBlue],
                                  startPoint: CGPoint(x: 0, y: 0),
                                  endPoint: CGPoint(x: 1, y: 1))
    }

    // MARK: - UI 搭建

    private func setupUI() {
        view.backgroundColor = .bgPrimary
        navigationController?.setNavigationBarHidden(true, animated: false)

        // ScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true

        // 标题区
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(historyButton)

        // 扫描动画区
        contentView.addSubview(scanContainerView)
        scanContainerView.addSubview(pulseView)
        contentView.addSubview(scanButton)
        contentView.addSubview(statusLabel)

        // 协议筛选区
        contentView.addSubview(sectionTitleLabel)
        contentView.addSubview(protocolStackView)
        setupProtocolTags()

        // 最近扫描卡片
        contentView.addSubview(recentCardView)
        recentCardView.addSubview(recentTitleLabel)
        recentCardView.addSubview(recentContentLabel)

        // 底部提示
        contentView.addSubview(tipLabel)

        // 事件绑定
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        recentCardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(recentCardTapped))
        )

        // 加载最近记录
        updateRecentCard()
    }

    private func setupProtocolTags() {
        for type in NFCProtocolType.allCases {
            let tag = ProtocolTagView(protocolType: type)
            tag.onToggle = { [weak self] isSelected in
                self?.updateEnabledProtocols()
            }
            protocolTags.append(tag)
            protocolStackView.addArrangedSubview(tag)
        }
    }

    // MARK: - 约束

    private func setupConstraints() {
        [scrollView, contentView, titleLabel, subtitleLabel, historyButton,
         scanContainerView, pulseView, scanButton, statusLabel,
         sectionTitleLabel, protocolStackView,
         recentCardView, recentTitleLabel, recentContentLabel, tipLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let safeArea = view.safeAreaLayoutGuide

        // ScrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let padding: CGFloat = 20

        // 标题区
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            historyButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            historyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            historyButton.widthAnchor.constraint(equalToConstant: 40),
            historyButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // 扫描动画区
        NSLayoutConstraint.activate([
            scanContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            scanContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            scanContainerView.widthAnchor.constraint(equalToConstant: 240),
            scanContainerView.heightAnchor.constraint(equalToConstant: 240),

            pulseView.topAnchor.constraint(equalTo: scanContainerView.topAnchor),
            pulseView.leadingAnchor.constraint(equalTo: scanContainerView.leadingAnchor),
            pulseView.trailingAnchor.constraint(equalTo: scanContainerView.trailingAnchor),
            pulseView.bottomAnchor.constraint(equalTo: scanContainerView.bottomAnchor)
        ])

        // 扫描按钮
        NSLayoutConstraint.activate([
            scanButton.topAnchor.constraint(equalTo: scanContainerView.bottomAnchor, constant: 24),
            scanButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 200),
            scanButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // 状态标签
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 12),
            statusLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        // 协议筛选区
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 28),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            protocolStackView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 10),
            protocolStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            protocolStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])

        // 最近扫描卡片
        NSLayoutConstraint.activate([
            recentCardView.topAnchor.constraint(equalTo: protocolStackView.bottomAnchor, constant: 24),
            recentCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            recentCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            recentTitleLabel.topAnchor.constraint(equalTo: recentCardView.topAnchor, constant: 16),
            recentTitleLabel.leadingAnchor.constraint(equalTo: recentCardView.leadingAnchor, constant: 16),

            recentContentLabel.topAnchor.constraint(equalTo: recentTitleLabel.bottomAnchor, constant: 8),
            recentContentLabel.leadingAnchor.constraint(equalTo: recentCardView.leadingAnchor, constant: 16),
            recentContentLabel.trailingAnchor.constraint(equalTo: recentCardView.trailingAnchor, constant: -16),
            recentContentLabel.bottomAnchor.constraint(equalTo: recentCardView.bottomAnchor, constant: -16)
        ])

        // 底部提示
        NSLayoutConstraint.activate([
            tipLabel.topAnchor.constraint(equalTo: recentCardView.bottomAnchor, constant: 20),
            tipLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tipLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    // MARK: - 绑定 NFCSessionManager

    private func bindSessionManager() {
        let manager = NFCSessionManager.shared

        manager.stateDidChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(for: state)
            }
        }

        manager.didScanTag = { [weak self] tagInfo in
            DispatchQueue.main.async {
                self?.handleScannedTag(tagInfo)
            }
        }

        manager.didEncounterError = { [weak self] error in
            DispatchQueue.main.async {
                self?.handleError(error)
            }
        }
    }

    // MARK: - 交互事件

    @objc private func scanButtonTapped() {
        let manager = NFCSessionManager.shared

        if manager.state.isBusy {
            manager.invalidateSession()
            pulseView.isAnimating = false
            updateScanButton(isScanning: false)
            statusLabel.text = "已取消"
            statusLabel.textColor = .accentYellow
            return
        }

        updateEnabledProtocols()
        manager.startScanning()
        pulseView.isAnimating = true
        updateScanButton(isScanning: true)
    }

    @objc private func historyButtonTapped() {
        let historyVC = ScanHistoryViewController()
        historyVC.onSelectRecord = { [weak self] record in
            self?.showTagDetail(uid: record.uid)
        }
        navigationController?.pushViewController(historyVC, animated: true)
    }

    @objc private func recentCardTapped() {
        let records = ScanHistoryManager.shared.getAllRecords()
        if let first = records.first {
            showTagDetail(uid: first.uid)
        }
    }

    // MARK: - UI 更新

    private func updateUI(for state: NFCSessionState) {
        statusLabel.text = state.displayText

        switch state {
        case .idle:
            statusLabel.textColor = .textTertiary
            pulseView.isAnimating = false
            updateScanButton(isScanning: false)
        case .scanning:
            statusLabel.textColor = .accentCyan
            pulseView.isAnimating = true
            updateScanButton(isScanning: true)
        case .connected:
            statusLabel.textColor = .accentGreen
            pulseView.isAnimating = true
        case .reading:
            statusLabel.textColor = .accentYellow
            pulseView.isAnimating = true
        case .completed:
            statusLabel.textColor = .accentGreen
            pulseView.isAnimating = false
            updateScanButton(isScanning: false)
        case .error:
            statusLabel.textColor = .accentRed
            pulseView.isAnimating = false
            updateScanButton(isScanning: false)
        }
    }

    private func updateScanButton(isScanning: Bool) {
        UIView.animate(withDuration: 0.3) {
            if isScanning {
                self.scanButton.setTitle("取消扫描", for: .normal)
                self.scanButton.backgroundColor = .accentRed
                self.scanButton.layer.shadowColor = UIColor.accentRed.cgColor
            } else {
                self.scanButton.setTitle("开始扫描", for: .normal)
                self.scanButton.backgroundColor = .accentPurple
                self.scanButton.layer.shadowColor = UIColor.accentPurple.cgColor
            }
        }
    }

    private func updateEnabledProtocols() {
        let enabledTypes = protocolTags.filter { $0.isSelected }.map { $0.protocolType }
        NFCSessionManager.shared.enabledProtocols = enabledTypes
    }

    private func updateRecentCard() {
        let records = ScanHistoryManager.shared.getAllRecords()
        if let latest = records.first {
            recentContentLabel.text = "\(latest.protocolType) | UID: \(latest.uid.prefix(16))\n\(latest.formattedTime)"
            recentContentLabel.textColor = .textSecondary
        } else {
            recentContentLabel.text = "暂无扫描记录"
            recentContentLabel.textColor = .textTertiary
        }
    }

    // MARK: - 扫描结果处理

    private func handleScannedTag(_ tagInfo: NFCTagInfo) {
        updateRecentCard()

        // 震动反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // 跳转详情页
        let detailVC = TagDetailViewController(tagInfo: tagInfo)
        detailVC.onRescan = { [weak self] in
            self?.scanButtonTapped()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func handleError(_ error: NFCReaderError) {
        switch error {
        case .userCancelled:
            // 用户取消不弹窗
            break
        case .sessionNotAvailable:
            showAlert(title: "NFC 不可用", message: error.localizedDescription)
        default:
            showAlert(title: "读取失败", message: error.localizedDescription)
        }
    }

    private func showTagDetail(uid: String) {
        // 从历史记录中查找
        let records = ScanHistoryManager.shared.getAllRecords()
        guard let _ = records.first(where: { $0.uid == uid }) else { return }

        // 构造简化的 TagInfo 用于展示
        let detailVC = TagDetailViewController(historyUID: uid)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
