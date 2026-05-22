import UIKit

// MARK: - 扫描历史页

class ScanHistoryViewController: UIViewController {

    // MARK: - 回调

    var onSelectRecord: ((ScanRecord) -> Void)?

    // MARK: - 数据

    private var records: [ScanRecord] = []

    // MARK: - UI 组件

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .bgPrimary
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return tv
    }()

    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let emptyIconLabel: UILabel = {
        let label = UILabel()
        label.text = "📋"
        label.font = UIFont.systemFont(ofSize: 56)
        label.textAlignment = .center
        return label
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无扫描记录"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
    }()

    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "扫描 NFC 标签后，记录将显示在这里"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textTertiary
        label.textAlignment = .center
        return label
    }()

    private static let cellReuseId = "ScanRecordCell"

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    // MARK: - UI 搭建

    private func setupUI() {
        view.backgroundColor = .bgPrimary

        // 导航栏
        title = "扫描历史"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.barTintColor = .bgPrimary
        navigationController?.navigationBar.tintColor = .accentCyan

        // 清空按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "清空",
            style: .plain,
            target: self,
            action: #selector(clearAllTapped)
        )

        // TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseId)
        view.addSubview(tableView)

        // 空状态视图
        view.addSubview(emptyView)
        emptyView.addSubview(emptyIconLabel)
        emptyView.addSubview(emptyTitleLabel)
        emptyView.addSubview(emptySubtitleLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        [tableView, emptyView, emptyIconLabel, emptyTitleLabel, emptySubtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyIconLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            emptyIconLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -40),

            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconLabel.bottomAnchor, constant: 16),
            emptyTitleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),

            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 6),
            emptySubtitleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor)
        ])
    }

    // MARK: - 数据

    private func loadData() {
        records = ScanHistoryManager.shared.getAllRecords()
        tableView.reloadData()
        emptyView.isHidden = !records.isEmpty
        tableView.isHidden = records.isEmpty
    }

    // MARK: - 交互

    @objc private func clearAllTapped() {
        guard !records.isEmpty else { return }

        let alert = UIAlertController(
            title: "清空历史",
            message: "确定要删除所有扫描记录吗？此操作不可撤销。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清空", style: .destructive) { [weak self] _ in
            ScanHistoryManager.shared.clearAll()
            self?.loadData()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ScanHistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseId, for: indexPath)
        configureCell(cell, for: indexPath)
        return cell
    }

    private func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        let record = records[indexPath.row]
        let protocolType = NFCProtocolType(rawValue: record.protocolType) ?? .iso7816

        // 清除旧子视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        cell.backgroundColor = .bgPrimary
        cell.selectionStyle = .none

        // 卡片容器
        let card = UIView()
        card.backgroundColor = .bgSecondary.withAlphaComponent(0.6)
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(hex: protocolType.color).withAlphaComponent(0.25).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        // 协议图标
        let iconLabel = UILabel()
        iconLabel.text = protocolType.icon
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)

        // 协议类型标签
        let typeLabel = UILabel()
        typeLabel.text = protocolType.displayName
        typeLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        typeLabel.textColor = UIColor(hex: protocolType.color)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(typeLabel)

        // UID
        let uidLabel = UILabel()
        uidLabel.text = "UID: \(record.uid.prefix(16))\(record.uid.count > 16 ? "..." : "")"
        uidLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        uidLabel.textColor = .textTertiary
        uidLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(uidLabel)

        // 时间
        let timeLabel = UILabel()
        timeLabel.text = record.formattedTime
        timeLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        timeLabel.textColor = .textTertiary.withAlphaComponent(0.6)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(timeLabel)

        // 记录数
        let countLabel = UILabel()
        countLabel.text = "\(record.recordCount) 条"
        countLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = .accentGreen
        countLabel.textAlignment = .right
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(countLabel)

        // 箭头
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        arrowLabel.textColor = .textTertiary
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),

            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            typeLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            typeLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            uidLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
            uidLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),

            timeLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: uidLabel.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            countLabel.trailingAnchor.constraint(equalTo: arrowLabel.leadingAnchor, constant: -4),
            countLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),

            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate

extension ScanHistoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records[indexPath.row]
        onSelectRecord?(record)
        navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completion in
            guard let self = self else { return }
            let record = self.records[indexPath.row]
            ScanHistoryManager.shared.deleteRecord(id: record.id)
            self.records.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            if self.records.isEmpty {
                self.emptyView.isHidden = false
                self.tableView.isHidden = true
            }
            completion(true)
        }
        deleteAction.backgroundColor = .accentRed

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
