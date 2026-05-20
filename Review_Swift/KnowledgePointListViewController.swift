//
//  KnowledgePointListViewController.swift
//  Review_Swift
//
//  Created by kwmin on 2026/5/13.
//

import UIKit

final class KnowledgePointListViewController: UITableViewController {

    fileprivate struct KnowledgeSection {

        let title: String
        let subtitle: String
        let symbolName: String
        let tintColor: UIColor
        let points: [KnowledgePoint]
    }

    fileprivate struct KnowledgePoint {

        let title: String
        let subtitle: String
        let symbolName: String
        let badge: String
        let makeViewController: () -> UIViewController
    }

    private let cellReuseIdentifier = "KnowledgePointHomeCell"
    private let headerReuseIdentifier = "KnowledgePointSectionHeader"

    private let sections: [KnowledgeSection] = [
        KnowledgeSection(
            title: "总复习路线",
            subtitle: "把散题压成必背、高频、加分和专项",
            symbolName: "bolt.shield.fill",
            tintColor: UIColor(red: 1.00, green: 0.40, blue: 0.40, alpha: 1.0),
            points: [
                KnowledgePoint(
                    title: "必背高频速记总纲",
                    subtitle: "复习顺序、临场模板、核心口诀、项目化回答",
                    symbolName: "map.fill",
                    badge: "总纲",
                    makeViewController: {
                        InterviewMustRememberViewController()
                    }
                )
            ]
        ),
        KnowledgeSection(
            title: "项目实战",
            subtitle: "中小公司最看重的项目表达和落地经验",
            symbolName: "briefcase.fill",
            tintColor: InterviewReviewStyle.accentColors[2],
            points: [
                KnowledgePoint(
                    title: "中小公司高频项目面试题",
                    subtitle: "项目介绍、架构、网络封装、登录态、业务场景、排查协作",
                    symbolName: "flame.fill",
                    badge: "必背",
                    makeViewController: {
                        ProjectInterviewReviewViewController()
                    }
                )
            ]
        ),
        KnowledgeSection(
            title: "Swift 基础",
            subtitle: "语言基础、值引用语义和内存管理",
            symbolName: "swift",
            tintColor: InterviewReviewStyle.accentColors[0],
            points: [
                KnowledgePoint(
                    title: "Swift 基础高频面试题",
                    subtitle: "Optional、protocol、closure、COW、lazy、static、final",
                    symbolName: "swift",
                    badge: "基础",
                    makeViewController: {
                        SwiftFoundationInterviewViewController()
                    }
                ),
                KnowledgePoint(
                    title: "struct 与 class 的区别",
                    subtitle: "值类型、引用类型、继承、mutating、deinit",
                    symbolName: "square.on.square",
                    badge: "高频",
                    makeViewController: {
                        StructClassReviewViewController()
                    }
                ),
                KnowledgePoint(
                    title: "strong、weak、unowned 的区别",
                    subtitle: "ARC 持有关系、自动置 nil、生命周期约束",
                    symbolName: "link.circle.fill",
                    badge: "高频",
                    makeViewController: {
                        StrongWeakUnownedReviewViewController()
                    }
                ),
                KnowledgePoint(
                    title: "UIViewController ARC 内存管理",
                    subtitle: "循环引用、weak、闭包、Timer、通知、cell 复用",
                    symbolName: "person.crop.rectangle.stack.fill",
                    badge: "必会",
                    makeViewController: {
                        ARCInterviewReviewViewController()
                    }
                )
            ]
        ),
        KnowledgeSection(
            title: "UIKit 与列表",
            subtitle: "页面生命周期、事件响应、布局和列表性能",
            symbolName: "rectangle.3.group.fill",
            tintColor: InterviewReviewStyle.accentColors[1],
            points: [
                KnowledgePoint(
                    title: "UIKit 高频面试题",
                    subtitle: "View/Controller 生命周期、AutoLayout、响应链、手势冲突",
                    symbolName: "iphone.gen3",
                    badge: "高频",
                    makeViewController: {
                        UIKitInterviewReviewViewController()
                    }
                ),
                KnowledgePoint(
                    title: "UITableView 面试宝典",
                    subtitle: "复用、刷新、动态高度、卡顿、RunLoop、Instruments",
                    symbolName: "list.bullet.rectangle.fill",
                    badge: "必会",
                    makeViewController: {
                        UITableViewInterviewReviewViewController()
                    }
                )
            ]
        ),
        KnowledgeSection(
            title: "网络与数据",
            subtitle: "请求链路、登录态、本地缓存和业务协议",
            symbolName: "network",
            tintColor: InterviewReviewStyle.accentColors[3],
            points: [
                KnowledgePoint(
                    title: "iOS 网络相关面试宝典",
                    subtitle: "URLSession、HTTP/HTTPS、GET/POST、JSON、token/session",
                    symbolName: "network",
                    badge: "必会",
                    makeViewController: {
                        NetworkInterviewReviewViewController()
                    }
                ),
                KnowledgePoint(
                    title: "iOS 数据持久化面试宝典",
                    subtitle: "UserDefaults、FileManager、Keychain、SQLite/CoreData、Codable",
                    symbolName: "externaldrive.fill",
                    badge: "高频",
                    makeViewController: {
                        DataPersistenceInterviewReviewViewController()
                    }
                ),
                KnowledgePoint(
                    title: "MQTT 面试八股",
                    subtitle: "Broker、Topic、QoS、retain、长连接、IoT 场景",
                    symbolName: "dot.radiowaves.left.and.right",
                    badge: "专项",
                    makeViewController: {
                        MQTTInterviewReviewViewController()
                    }
                )
            ]
        ),
        KnowledgeSection(
            title: "并发与底层",
            subtitle: "多线程、RunLoop、runtime、KVC/KVO/Block",
            symbolName: "cpu.fill",
            tintColor: InterviewReviewStyle.accentColors[4],
            points: [
                KnowledgePoint(
                    title: "iOS 多线程面试知识点",
                    subtitle: "GCD、队列、死锁、锁、Group、RunLoop、OperationQueue",
                    symbolName: "cpu.fill",
                    badge: "高频",
                    makeViewController: {
                        MultithreadingInterviewReviewViewController()
                    }
                ),
                KnowledgePoint(
                    title: "OC runtime / KVC / KVO / Block",
                    subtitle: "消息发送、方法缓存、KVC、KVO、Block、循环引用",
                    symbolName: "gearshape.2.fill",
                    badge: "加分",
                    makeViewController: {
                        OCRuntimeInterviewViewController()
                    }
                )
            ]
        ),
        KnowledgeSection(
            title: "排查加分",
            subtitle: "Crash、泄漏、卡顿和 Instruments 项目话术",
            symbolName: "stethoscope",
            tintColor: UIColor(red: 1.00, green: 0.40, blue: 0.40, alpha: 1.0),
            points: [
                KnowledgePoint(
                    title: "iOS 崩溃与问题排查面试宝典",
                    subtitle: "Crash、dSYM、内存泄漏、Instruments、项目回答模板",
                    symbolName: "cross.case.fill",
                    badge: "必背",
                    makeViewController: {
                        CrashDebugInterviewViewController()
                    }
                )
            ]
        ),
        KnowledgeSection(
            title: "AI 专项",
            subtitle: "AI 聊天、流式输出、上下文、RAG、Agent 和项目优化",
            symbolName: "brain.head.profile",
            tintColor: InterviewReviewStyle.accentColors[4],
            points: [
                KnowledgePoint(
                    title: "AI 常规高频面试题总结",
                    subtitle: "请求、SSE、Token、上下文、Markdown、RAG、Agent、MCP",
                    symbolName: "sparkles",
                    badge: "必背",
                    makeViewController: {
                        AICommonInterviewViewController()
                    }
                )
            ]
        )
    ]

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Swift 面试宝典"
        setupAppearance()
        setupTableView()
        setupHeaderView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderWidthIfNeeded()
    }

    private func setupAppearance() {
        view.backgroundColor = InterviewReviewStyle.backgroundColor

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = InterviewReviewStyle.backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: InterviewReviewStyle.titleTextColor
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: InterviewReviewStyle.titleTextColor
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = InterviewReviewStyle.accentColors[0]
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        tableView.backgroundColor = InterviewReviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 104
        tableView.sectionHeaderTopPadding = 8
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 28, right: 0)
        tableView.register(
            KnowledgePointHomeCell.self,
            forCellReuseIdentifier: cellReuseIdentifier
        )
        tableView.register(
            KnowledgePointSectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: headerReuseIdentifier
        )
    }

    private func setupHeaderView() {
        let headerView = KnowledgeOverviewHeaderView(
            frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 154)
        )
        headerView.configure(
            sectionCount: sections.count,
            pointCount: sections.reduce(0) { $0 + $1.points.count }
        )
        tableView.tableHeaderView = headerView
    }

    private func updateHeaderWidthIfNeeded() {
        guard let headerView = tableView.tableHeaderView else { return }
        let expectedWidth = tableView.bounds.width

        if headerView.frame.width != expectedWidth {
            headerView.frame.size.width = expectedWidth
            tableView.tableHeaderView = headerView
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].points.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
        ) as? KnowledgePointHomeCell ?? KnowledgePointHomeCell(
            style: .default,
            reuseIdentifier: cellReuseIdentifier
        )

        let section = sections[indexPath.section]
        let point = section.points[indexPath.row]
        cell.configure(point: point, tintColor: section.tintColor)

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: headerReuseIdentifier
        ) as? KnowledgePointSectionHeaderView ?? KnowledgePointSectionHeaderView(
            reuseIdentifier: headerReuseIdentifier
        )

        headerView.configure(section: sections[section])
        return headerView
    }

    override func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForHeaderInSection section: Int
    ) -> CGFloat {
        70
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let knowledgePoint = sections[indexPath.section].points[indexPath.row]
        let viewController = knowledgePoint.makeViewController()
        viewController.title = knowledgePoint.title
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private final class KnowledgeOverviewHeaderView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = InterviewReviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = InterviewReviewStyle.accentColors[0].withAlphaComponent(0.16)
        view.layer.cornerRadius = 18
        return view
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = InterviewReviewStyle.accentColors[0]
        imageView.image = UIImage(systemName: "books.vertical.fill")
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.text = "中小公司 iOS 面试路线"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = InterviewReviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.text = "项目实战优先，基础题兜底，排查题加分。"
        return label
    }()

    private let sectionMetricLabel = KnowledgeMetricLabel()
    private let pointMetricLabel = KnowledgeMetricLabel()
    private let focusMetricLabel = KnowledgeMetricLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func configure(sectionCount: Int, pointCount: Int) {
        sectionMetricLabel.configure(value: "\(sectionCount)", title: "分组")
        pointMetricLabel.configure(value: "\(pointCount)", title: "专题")
        focusMetricLabel.configure(value: "项目", title: "优先")
    }

    private func setupLayout() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        let metricsStackView = UIStackView(arrangedSubviews: [
            sectionMetricLabel,
            pointMetricLabel,
            focusMetricLabel
        ])
        metricsStackView.translatesAutoresizingMaskIntoConstraints = false
        metricsStackView.axis = .horizontal
        metricsStackView.alignment = .fill
        metricsStackView.distribution = .fillEqually
        metricsStackView.spacing = 8
        containerView.addSubview(metricsStackView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            iconContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            iconContainerView.widthAnchor.constraint(equalToConstant: 36),
            iconContainerView.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 17),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            metricsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            metricsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            metricsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            metricsStackView.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
}

private final class KnowledgeMetricLabel: UIView {

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = InterviewReviewStyle.secondaryTextColor
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = InterviewReviewStyle.fieldBackgroundColor
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
        ])
    }
}

private final class KnowledgePointSectionHeaderView: UITableViewHeaderFooterView {

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = InterviewReviewStyle.secondaryTextColor
        label.numberOfLines = 2
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func configure(section: KnowledgePointListViewController.KnowledgeSection) {
        iconContainerView.backgroundColor = section.tintColor.withAlphaComponent(0.16)
        iconView.tintColor = section.tintColor
        iconView.image = UIImage(systemName: section.symbolName) ?? UIImage(systemName: "folder.fill")
        titleLabel.text = section.title
        subtitleLabel.text = section.subtitle
    }

    private func setupLayout() {
        contentView.backgroundColor = InterviewReviewStyle.backgroundColor
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.widthAnchor.constraint(equalToConstant: 28),
            iconContainerView.heightAnchor.constraint(equalToConstant: 28),
            iconContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),

            iconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 15),
            iconView.heightAnchor.constraint(equalToConstant: 15),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9)
        ])
    }
}

private final class KnowledgePointHomeCell: UITableViewCell {

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = InterviewReviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = InterviewReviewStyle.secondaryTextColor
        label.numberOfLines = 2
        return label
    }()

    private let badgeLabel: KnowledgeBadgeLabel = {
        let label = KnowledgeBadgeLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = InterviewReviewStyle.secondaryTextColor
        imageView.image = UIImage(systemName: "chevron.right")
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func configure(
        point: KnowledgePointListViewController.KnowledgePoint,
        tintColor: UIColor
    ) {
        iconContainerView.backgroundColor = tintColor.withAlphaComponent(0.16)
        iconView.tintColor = tintColor
        iconView.image = UIImage(systemName: point.symbolName) ?? UIImage(systemName: "book.closed.fill")
        titleLabel.text = point.title
        subtitleLabel.text = point.subtitle
        badgeLabel.text = point.badge
        badgeLabel.textColor = tintColor
        badgeLabel.backgroundColor = tintColor.withAlphaComponent(0.14)
    }

    private func setupLayout() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = InterviewReviewStyle.selectionColor

        contentView.addSubview(cardView)
        cardView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(badgeLabel)
        cardView.addSubview(chevronView)

        badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        badgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        chevronView.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            iconContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            iconContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 21),
            iconView.heightAnchor.constraint(equalToConstant: 21),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: badgeLabel.leadingAnchor, constant: -10),

            badgeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -10),
            badgeLabel.heightAnchor.constraint(equalToConstant: 22),

            chevronView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            chevronView.widthAnchor.constraint(equalToConstant: 10),
            chevronView.heightAnchor.constraint(equalToConstant: 16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }
}

private final class KnowledgeBadgeLabel: UILabel {

    private let textInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
