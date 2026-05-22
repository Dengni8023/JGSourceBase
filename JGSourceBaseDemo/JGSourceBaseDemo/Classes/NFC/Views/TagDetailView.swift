import UIKit

// MARK: - 标签详情页

class TagDetailViewController: UIViewController {

    // MARK: - 数据

    private var tagInfo: NFCTagInfo?
    private var historyRecord: ScanRecord?

    var onRescan: (() -> Void)?

    // MARK: - UI 组件

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    /// 顶部概览卡片
    private let overviewCard: UIView = {
        let view = UIView()
        view.backgroundColor = .bgSecondary.withAlphaComponent(0.8)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.accentPurple.withAlphaComponent(0.3).cgColor
        return view
    }()

    private let protocolIconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48)
        label.textAlignment = .center
        return label
    }()

    private let protocolTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()

    private let uidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        label.textColor = .accentCyan
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let manufacturerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textTertiary
        label.textAlignment = .center
        return label
    }()

    private let scanTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textTertiary.withAlphaComponent(0.7)
        label.textAlignment = .center
        return label
    }()

    /// 记录数统计
    private let statsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .bgSecondary.withAlphaComponent(0.6)
        view.layer.cornerRadius = 12
        return view
    }()

    private let recordCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .accentGreen
        label.textAlignment = .center
        return label
    }()

    private let recordCountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "条记录"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textTertiary
        label.textAlignment = .center
        return label
    }()

    private let dataSizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .accentYellow
        label.textAlignment = .center
        return label
    }()

    private let dataSizeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "字节数据"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textTertiary
        label.textAlignment = .center
        return label
    }()

    /// 记录列表区
    private let recordsSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "解析记录"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .textSecondary
        return label
    }()

    private let recordsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.alignment = .fill
        return sv
    }()

    /// 原始数据区
    private let rawDataHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .bgSecondary.withAlphaComponent(0.4)
        view.layer.cornerRadius = 12
        return view
    }()

    private let rawDataTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "原始数据 (HEX)"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .textSecondary
        return label
    }()

    private let rawDataToggle: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("展开", for: .normal)
        btn.setTitleColor(.accentCyan, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return btn
    }()

    private let rawDataTextView: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .accentCyan.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    /// 操作按钮区
    private let actionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var copyButton = makeActionButton(title: "复制数据", icon: "doc.on.doc", color: .accentBlue)
    private lazy var rescanButton = makeActionButton(title: "重新扫描", icon: "arrow.clockwise", color: .accentPurple)
    private lazy var shareButton = makeActionButton(title: "分享", icon: "square.and.arrow.up", color: .accentGreen)

    private var isRawDataExpanded = false

    // MARK: - 初始化

    init(tagInfo: NFCTagInfo) {
        self.tagInfo = tagInfo
        super.init(nibName: nil, bundle: nil)
    }

    init(historyUID: String) {
        // 从历史记录加载
        let records = ScanHistoryManager.shared.getAllRecords()
        self.historyRecord = records.first { $0.uid == historyUID }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        populateData()
    }

    // MARK: - UI 搭建

    private func setupUI() {
        view.backgroundColor = .bgPrimary

        // 导航栏
        title = "标签详情"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.barTintColor = .bgPrimary
        navigationController?.navigationBar.tintColor = .accentCyan
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false

        // 概览卡片
        contentView.addSubview(overviewCard)
        overviewCard.addSubview(protocolIconLabel)
        overviewCard.addSubview(protocolTypeLabel)
        overviewCard.addSubview(uidLabel)
        overviewCard.addSubview(manufacturerLabel)
        overviewCard.addSubview(scanTimeLabel)

        // 统计卡片
        contentView.addSubview(statsCard)
        statsCard.addSubview(recordCountLabel)
        statsCard.addSubview(recordCountTitleLabel)
        statsCard.addSubview(dataSizeLabel)
        statsCard.addSubview(dataSizeTitleLabel)

        // 记录列表
        contentView.addSubview(recordsSectionTitle)
        contentView.addSubview(recordsStackView)

        // 原始数据
        contentView.addSubview(rawDataHeader)
        rawDataHeader.addSubview(rawDataTitleLabel)
        rawDataHeader.addSubview(rawDataToggle)
        contentView.addSubview(rawDataTextView)

        // 操作按钮
        contentView.addSubview(actionStackView)
        actionStackView.addArrangedSubview(copyButton)
        actionStackView.addArrangedSubview(rescanButton)
        actionStackView.addArrangedSubview(shareButton)

        // 事件
        rawDataToggle.addTarget(self, action: #selector(toggleRawData), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyData), for: .touchUpInside)
        rescanButton.addTarget(self, action: #selector(rescan), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareData), for: .touchUpInside)
    }

    private func setupConstraints() {
        let allViews: [UIView] = [scrollView, contentView, overviewCard, protocolIconLabel,
                                   protocolTypeLabel, uidLabel, manufacturerLabel, scanTimeLabel,
                                   statsCard, recordCountLabel, recordCountTitleLabel,
                                   dataSizeLabel, dataSizeTitleLabel,
                                   recordsSectionTitle, recordsStackView,
                                   rawDataHeader, rawDataTitleLabel, rawDataToggle,
                                   rawDataTextView, actionStackView]
        allViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let safeArea = view.safeAreaLayoutGuide
        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // 概览卡片
            overviewCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            overviewCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            overviewCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            protocolIconLabel.topAnchor.constraint(equalTo: overviewCard.topAnchor, constant: 20),
            protocolIconLabel.centerXAnchor.constraint(equalTo: overviewCard.centerXAnchor),

            protocolTypeLabel.topAnchor.constraint(equalTo: protocolIconLabel.bottomAnchor, constant: 8),
            protocolTypeLabel.centerXAnchor.constraint(equalTo: overviewCard.centerXAnchor),

            uidLabel.topAnchor.constraint(equalTo: protocolTypeLabel.bottomAnchor, constant: 8),
            uidLabel.leadingAnchor.constraint(equalTo: overviewCard.leadingAnchor, constant: 16),
            uidLabel.trailingAnchor.constraint(equalTo: overviewCard.trailingAnchor, constant: -16),

            manufacturerLabel.topAnchor.constraint(equalTo: uidLabel.bottomAnchor, constant: 6),
            manufacturerLabel.centerXAnchor.constraint(equalTo: overviewCard.centerXAnchor),

            scanTimeLabel.topAnchor.constraint(equalTo: manufacturerLabel.bottomAnchor, constant: 4),
            scanTimeLabel.centerXAnchor.constraint(equalTo: overviewCard.centerXAnchor),
            scanTimeLabel.bottomAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: -16),

            // 统计卡片
            statsCard.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: 16),
            statsCard.leadingAnchor.constraint(equalTo: overviewCard.leadingAnchor),
            statsCard.trailingAnchor.constraint(equalTo: overviewCard.trailingAnchor),
            statsCard.heightAnchor.constraint(equalToConstant: 80),

            recordCountLabel.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 12),
            recordCountLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 40),

            recordCountTitleLabel.topAnchor.constraint(equalTo: recordCountLabel.bottomAnchor, constant: 2),
            recordCountTitleLabel.centerXAnchor.constraint(equalTo: recordCountLabel.centerXAnchor),

            dataSizeLabel.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 12),
            dataSizeLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -40),

            dataSizeTitleLabel.topAnchor.constraint(equalTo: dataSizeLabel.bottomAnchor, constant: 2),
            dataSizeTitleLabel.centerXAnchor.constraint(equalTo: dataSizeLabel.centerXAnchor),

            // 记录列表
            recordsSectionTitle.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 20),
            recordsSectionTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            recordsStackView.topAnchor.constraint(equalTo: recordsSectionTitle.bottomAnchor, constant: 10),
            recordsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            recordsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            // 原始数据
            rawDataHeader.topAnchor.constraint(equalTo: recordsStackView.bottomAnchor, constant: 20),
            rawDataHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rawDataHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            rawDataHeader.heightAnchor.constraint(equalToConstant: 44),

            rawDataTitleLabel.leadingAnchor.constraint(equalTo: rawDataHeader.leadingAnchor, constant: 14),
            rawDataTitleLabel.centerYAnchor.constraint(equalTo: rawDataHeader.centerYAnchor),

            rawDataToggle.trailingAnchor.constraint(equalTo: rawDataHeader.trailingAnchor, constant: -14),
            rawDataToggle.centerYAnchor.constraint(equalTo: rawDataHeader.centerYAnchor),

            rawDataTextView.topAnchor.constraint(equalTo: rawDataHeader.bottomAnchor, constant: 8),
            rawDataTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rawDataTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            // 操作按钮
            actionStackView.topAnchor.constraint(equalTo: rawDataTextView.bottomAnchor, constant: 20),
            actionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            actionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            actionStackView.heightAnchor.constraint(equalToConstant: 48),
            actionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    // MARK: - 数据填充

    private func populateData() {
        if let tagInfo = tagInfo {
            populateFromTagInfo(tagInfo)
        } else if let record = historyRecord {
            populateFromHistory(record)
        }
    }

    private func populateFromTagInfo(_ info: NFCTagInfo) {
        protocolIconLabel.text = info.protocolType.icon
        protocolTypeLabel.text = info.protocolType.displayName
        protocolTypeLabel.textColor = UIColor(hex: info.protocolType.color)
        uidLabel.text = "UID: \(info.uidDisplay)"
        manufacturerLabel.text = info.manufacturer

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        scanTimeLabel.text = formatter.string(from: info.scanTime)

        recordCountLabel.text = "\(info.recordCount)"
        dataSizeLabel.text = "\(info.rawData.count)"

        // 记录列表
        for record in info.parsedRecords {
            let card = makeRecordCard(record)
            recordsStackView.addArrangedSubview(card)
        }

        if info.parsedRecords.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "无解析记录"
            emptyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            emptyLabel.textColor = .textTertiary
            emptyLabel.textAlignment = .center
            recordsStackView.addArrangedSubview(emptyLabel)
        }

        rawDataTextView.text = info.rawDataHex
    }

    private func populateFromHistory(_ record: ScanRecord) {
        let protocolType = NFCProtocolType(rawValue: record.protocolType) ?? .iso7816
        protocolIconLabel.text = protocolType.icon
        protocolTypeLabel.text = protocolType.displayName
        protocolTypeLabel.textColor = UIColor(hex: protocolType.color)
        uidLabel.text = "UID: \(record.uid)"
        manufacturerLabel.text = record.manufacturer
        scanTimeLabel.text = record.formattedTime

        recordCountLabel.text = "\(record.recordCount)"
        dataSizeLabel.text = "\(record.rawDataHex.split(separator: " ").count)"

        // 历史记录只有摘要数据
        let summaryCard = makeHistorySummaryCard(record)
        recordsStackView.addArrangedSubview(summaryCard)

        rawDataTextView.text = record.rawDataHex
    }

    // MARK: - 记录卡片

    private func makeRecordCard(_ record: NFCRecord) -> UIView {
        let card = UIView()
        card.backgroundColor = .bgSecondary.withAlphaComponent(0.5)
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.textTertiary.withAlphaComponent(0.1).cgColor

        let titleLabel = UILabel()
        titleLabel.text = record.displayTitle
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .textPrimary

        let formatLabel = UILabel()
        formatLabel.text = record.typeNameFormat
        formatLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        formatLabel.textColor = .accentPurple

        let contentLabel = UILabel()
        contentLabel.text = record.payloadText
        contentLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        contentLabel.textColor = .textSecondary
        contentLabel.numberOfLines = 3

        [titleLabel, formatLabel, contentLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),

            formatLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            formatLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            contentLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            contentLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            contentLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return card
    }

    private func makeHistorySummaryCard(_ record: ScanRecord) -> UIView {
        let card = UIView()
        card.backgroundColor = .bgSecondary.withAlphaComponent(0.5)
        card.layer.cornerRadius = 12

        let label = UILabel()
        label.text = "\(record.protocolType) | \(record.recordCount) 条记录 | \(record.manufacturer)"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    // MARK: - 操作按钮

    private func makeActionButton(title: String, icon: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.setTitleColor(.textPrimary, for: .normal)
        btn.tintColor = .textPrimary
        btn.backgroundColor = color.withAlphaComponent(0.3)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        return btn
    }

    // MARK: - 交互事件

    @objc private func toggleRawData() {
        isRawDataExpanded.toggle()
        rawDataTextView.isHidden = !isRawDataExpanded
        rawDataToggle.setTitle(isRawDataExpanded ? "收起" : "展开", for: .normal)
    }

    @objc private func copyData() {
        let text: String
        if let info = tagInfo {
            text = "协议: \(info.protocolType.displayName)\nUID: \(info.uidDisplay)\n制造商: \(info.manufacturer)\n记录数: \(info.recordCount)\n原始数据: \(info.rawDataHex)"
        } else if let record = historyRecord {
            text = "协议: \(record.protocolType)\nUID: \(record.uid)\n制造商: \(record.manufacturer)\n记录数: \(record.recordCount)\n原始数据: \(record.rawDataHex)"
        } else {
            return
        }

        UIPasteboard.general.string = text

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        showToast("已复制到剪贴板")
    }

    @objc private func rescan() {
        navigationController?.popViewController(animated: true)
        onRescan?()
    }

    @objc private func shareData() {
        let text: String
        if let info = tagInfo {
            text = "协议: \(info.protocolType.displayName)\nUID: \(info.uidDisplay)\n制造商: \(info.manufacturer)\n记录数: \(info.recordCount)\n原始数据: \(info.rawDataHex)"
        } else if let record = historyRecord {
            text = "协议: \(record.protocolType)\nUID: \(record.uid)\n制造商: \(record.manufacturer)\n记录数: \(record.recordCount)\n原始数据: \(record.rawDataHex)"
        } else {
            return
        }

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    // MARK: - Toast

    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toast.textColor = .textPrimary
        toast.backgroundColor = .bgTertiary.withAlphaComponent(0.9)
        toast.textAlignment = .center
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true

        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toast.widthAnchor.constraint(equalToConstant: 200),
            toast.heightAnchor.constraint(equalToConstant: 40)
        ])

        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: {
                toast.alpha = 0.0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
