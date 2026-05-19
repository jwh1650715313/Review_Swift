//
//  ARCInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/18.
//

import UIKit

private enum ARCInterviewStyle {

    static let backgroundColor = UIColor(red: 0.035, green: 0.045, blue: 0.060, alpha: 1.0)
    static let headerBackgroundColor = UIColor(red: 0.080, green: 0.092, blue: 0.125, alpha: 1.0)
    static let cardBackgroundColor = UIColor(red: 0.098, green: 0.112, blue: 0.150, alpha: 1.0)
    static let fieldBackgroundColor = UIColor(red: 0.060, green: 0.070, blue: 0.098, alpha: 1.0)
    static let titleTextColor = UIColor(white: 0.97, alpha: 1.0)
    static let bodyTextColor = UIColor(white: 0.84, alpha: 1.0)
    static let secondaryTextColor = UIColor(white: 0.68, alpha: 1.0)
    static let highlightedTextColor = UIColor(white: 0.97, alpha: 1.0)
    static let selectionColor = UIColor.white.withAlphaComponent(0.045)

    static let accentColors: [UIColor] = [
        UIColor(red: 0.27, green: 0.74, blue: 1.00, alpha: 1.0),
        UIColor(red: 0.36, green: 0.90, blue: 0.66, alpha: 1.0),
        UIColor(red: 1.00, green: 0.64, blue: 0.30, alpha: 1.0),
        UIColor(red: 0.73, green: 0.58, blue: 1.00, alpha: 1.0),
        UIColor(red: 0.20, green: 0.84, blue: 0.92, alpha: 1.0)
    ]
}

final class ARCInterviewReviewViewController: UITableViewController {

    fileprivate struct InterviewQuestion {

        let title: String
        let question: String
        let standardAnswer: String
        let principle: String
        let followUp: String
        let practice: String
        let memoryLine: String
    }

    fileprivate struct InterviewSection {

        let id: String
        let title: String
        let subtitle: String
        let symbolName: String
        let tintColor: UIColor
        let questions: [InterviewQuestion]
    }

    private struct InterviewPoint {

        let question: String
        let standardAnswer: String
        let principle: String
        let followUp: String
        let practice: String
        let memory: String
    }

    fileprivate enum ReviewRowKind: Int, CaseIterable {

        case question
        case standardAnswer
        case principle
        case followUp
        case practice
        case memory

        var title: String {
            switch self {
            case .question:
                return "面试题"
            case .standardAnswer:
                return "标准答案"
            case .principle:
                return "底层原理"
            case .followUp:
                return "常见追问"
            case .practice:
                return "项目排查"
            case .memory:
                return "一句话速记"
            }
        }

        var iconName: String {
            switch self {
            case .question:
                return "questionmark.circle.fill"
            case .standardAnswer:
                return "checkmark.seal.fill"
            case .principle:
                return "link.circle.fill"
            case .followUp:
                return "bubble.left.and.bubble.right.fill"
            case .practice:
                return "magnifyingglass.circle.fill"
            case .memory:
                return "bolt.fill"
            }
        }

        func text(for question: InterviewQuestion) -> String {
            switch self {
            case .question:
                return question.question
            case .standardAnswer:
                return question.standardAnswer
            case .principle:
                return question.principle
            case .followUp:
                return question.followUp
            case .practice:
                return question.practice
            case .memory:
                return question.memoryLine
            }
        }
    }

    private let cellReuseIdentifier = "ARCInterviewCell"
    private let headerReuseIdentifier = "ARCInterviewHeaderView"

    private lazy var sections: [InterviewSection] = makeSections()
    private var expandedSectionIDs: Set<String> = []

    private let points: [InterviewPoint] = [
        InterviewPoint(
            question: "ARC 是怎么判断对象释放的？",
            standardAnswer: "ARC 通过强引用计数管理对象生命周期。当一个对象没有任何 strong 引用时，引用计数变为 0，对象会释放并触发 deinit。weak 和 unowned 不增加引用计数。",
            principle: "ARC 解决的是自动插入 retain/release 的问题，不是自动理解业务关系。它只看还有没有强引用链，哪怕这条链是两个对象互相 strong 持有形成的环，只要计数不归零就不会释放。",
            followUp: "追问：UIViewController strong 持有 view、子控件和数据源有没有问题？答：没有。控制器拥有这些对象是正常单向所有权，危险的是子对象再 strong 持回控制器。",
            practice: "排查时先画持有链：谁拥有谁、谁只是回调谁。正向拥有用 strong，反向通知和观察用 weak，发现 deinit 不走时优先找额外的 strong 链。",
            memory: "ARC 重点不是“用了就会释放”，而是 strong 链断完才会释放。"
        ),
        InterviewPoint(
            question: "strong、weak、unowned 应该怎么选？",
            standardAnswer: "自己拥有并且需要对方稳定存在时用 strong；不拥有、只是回调或反向引用时用 weak；确定对方生命周期一定更长且不需要 optional 时才用 unowned。",
            principle: "strong 表示所有权，会延长对象生命周期；weak 不表示所有权，对象释放后自动变 nil；unowned 也不表示所有权，但对象释放后不会置 nil，用错会访问野引用并崩溃。",
            followUp: "追问：为什么 delegate 通常是 weak？答：delegate 是反向通知，不应该拥有调用方。owner strong 持有子对象，子对象 weak 指向 owner，才能避免互相持有。",
            practice: "项目里看到 delegate、parent、owner、callbackTarget、cell 回调这些反向关系，要特别检查是不是误写成 strong；看到 unowned 要确认生命周期证明是否足够硬。",
            memory: "拥有用 strong，不拥有用 weak，确定更长命才 unowned。"
        ),
        InterviewPoint(
            question: "循环引用一般出现在什么地方？",
            standardAnswer: "循环引用最常见于两个对象互相 strong 持有，或者对象 strong 持有闭包，闭包又 strong 捕获 self。ARC 不会自动打破这种环，需要把其中一边改成 weak/unowned 或主动断开。",
            principle: "循环引用的本质是引用计数互相兜住：A 释放不了 B，B 也释放不了 A。只要环里每个对象都还有 strong 引用计数，deinit 就不会执行。",
            followUp: "追问：单向 strong 一定有问题吗？答：没有。父对象 strong 持有子对象、控制器 strong 持有 view 都是正常关系；问题是反向也 strong。",
            practice: "排查重点看闭包属性、delegate、Timer、Notification block、单例数组、异步任务、cell 回调。每一处都问一句：这个引用是不是拥有关系？",
            memory: "单向 strong 是所有权，互相 strong 才是循环引用。"
        ),
        InterviewPoint(
            question: "闭包为什么经常写 [weak self]？",
            standardAnswer: "闭包默认会强捕获 self。如果 self 又 strong 持有这个闭包，或者闭包被长期持有，就可能形成 self -> closure -> self 的循环引用。",
            principle: "不是所有闭包都必须 weak self。短生命周期、不会被 self 持有的闭包通常没问题；只要闭包可能逃逸、被属性保存、被任务或单例长期持有，就要检查捕获关系。",
            followUp: "追问：什么时候可以不用 weak self？答：UIView.animate 这种短生命周期闭包、没有被 self 间接长期持有的同步闭包，一般不需要为了形式感写 weak。",
            practice: "网络回调、按钮回调、cell 回调、ViewModel 输出闭包、DispatchQueue/Task 里的长任务都要重点看。使用 weak 后也要处理 self 为 nil 的场景，不要强行 guard 后制造逻辑空洞。",
            memory: "闭包先问生命周期：会逃逸、会保存、会回调 self，就重点查 weak。"
        ),
        InterviewPoint(
            question: "Timer / CADisplayLink 为什么容易让控制器不释放？",
            standardAnswer: "Timer 和 CADisplayLink 会被 RunLoop 持有，它们又会持有 target 或 block。如果 target/block 持有控制器，不 invalidate 就会让控制器一直活着。",
            principle: "这条链通常是 RunLoop -> Timer/CADisplayLink -> target/block -> self。只要定时器还在 RunLoop 中，链路就不断，控制器的引用计数就不会归零。",
            followUp: "追问：用 block 版本 Timer 就一定安全了吗？答：不一定。block 里强用 self 一样会泄漏，仍然需要 weak self，并在合适时机 invalidate。",
            practice: "页面消失或 deinit 前停止 Timer/CADisplayLink；复杂场景可以封装 weak proxy；不要让 cell 内部定时器在复用后继续跑。",
            memory: "Timer 泄漏链：RunLoop 持有 Timer，Timer 再持有 self。"
        ),
        InterviewPoint(
            question: "Notification 是否需要移除？",
            standardAnswer: "selector 方式在新系统上安全性更好，但 block 方式注册通知时，NotificationCenter 会持有 observer token 和 block；如果 block 强捕获 self，就可能导致泄漏。",
            principle: "block observer 的持有链是 NotificationCenter -> token/block -> self。只要 token 没移除，block 就可能一直存在，控制器也可能一直不释放。",
            followUp: "追问：为什么工程里仍建议统一清理？答：因为项目会混用 selector、block、KVO、第三方通知封装，统一在生命周期里清理更容易形成习惯，也方便排查。",
            practice: "block 注册要保存 token，deinit 或合适生命周期里 removeObserver；闭包里优先 weak self；通知回调里不要再把 self 放进单例缓存。",
            memory: "Notification block 记住两件事：保存 token，移除观察。"
        ),
        InterviewPoint(
            question: "deinit 不执行应该怎么排查？",
            standardAnswer: "先确认页面真的被 pop 或 dismiss，再查持有链：闭包、Timer、CADisplayLink、Notification block、delegate 是否 strong、单例缓存、异步任务、cell 回调、网络请求。",
            principle: "deinit 不执行说明至少还有一条 strong 链指向对象。排查不是靠猜，而是从已知入口往外找谁还拥有它，必要时用 Memory Graph 或 Instruments 看引用链。",
            followUp: "追问：deinit 里应该做什么？答：适合做生命周期收尾，比如取消任务、移除通知、invalidate 定时器、打印释放日志；不要把主要业务逻辑押在 deinit 才执行。",
            practice: "加 deinit 日志验证释放；用 Xcode Memory Graph 看引用路径；用 Leaks/Allocations 看对象数量是否持续上涨；先处理最长生命周期对象，比如单例、任务队列、通知中心。",
            memory: "deinit 不走，先找谁还 strong 持有 self。"
        ),
        InterviewPoint(
            question: "异步任务和线程会不会导致对象无法释放？",
            standardAnswer: "会。DispatchQueue、Task、网络请求或长时间运行的 operation 如果持有闭包，闭包又强捕获 self，就会延长控制器生命周期，甚至形成长期泄漏。",
            principle: "异步任务常常比页面活得更久。任务没完成前，任务对象会持有回调闭包；闭包持有 self 时，页面即使退出也可能等任务结束后才释放。",
            followUp: "追问：所有异步回调都算泄漏吗？答：不一定。短请求只是延长生命周期；不会结束的任务、重复回调、被单例保存的任务更危险。",
            practice: "页面退出时取消请求或 Task；长任务里使用 weak self；回调回来先校验页面是否仍需要更新 UI；不要在后台循环里无期限捕获控制器。",
            memory: "异步任务看两点：能不能取消，会不会长期持有 self。"
        ),
        InterviewPoint(
            question: "大对象、图片和缓存有什么内存风险？",
            standardAnswer: "大图、大富文本、大数组和缓存会抬高内存峰值。如果它们被属性、单例缓存或闭包长期持有，就算没有循环引用，也会造成内存迟迟不降。",
            principle: "内存问题不只包含泄漏，也包含峰值过高和缓存不释放。UIImage(named:) 会走系统缓存，网络图片缓存过大、原图直接渲染、富文本一次性生成太多都会增加压力。",
            followUp: "追问：没有循环引用为什么内存还高？答：可能是对象仍被正常持有，也可能是缓存策略允许暂留；要区分泄漏、峰值和可回收缓存。",
            practice: "图片按显示尺寸裁剪，缓存设置上限，列表滑动取消旧请求，大数据分页加载；收到内存警告或页面退出时释放非必要缓存。",
            memory: "内存排查别只盯泄漏，也要看大对象和缓存策略。"
        ),
        InterviewPoint(
            question: "cell 复用和内存管理有什么关系？",
            standardAnswer: "cell 复用本身是为了减少对象创建和内存占用。真正的风险在 cell 内部：图片请求不取消、定时器不停止、闭包强持有控制器、prepareForReuse 没重置状态。",
            principle: "同一个 cell 会绑定多个模型。旧任务如果晚回来，可能更新到新数据上；旧引用如果没断，可能让请求、图片、控制器或模型继续被持有。",
            followUp: "追问：cell 闭包怎么写更稳？答：cell 可以通过闭包把点击事件抛出去，但控制器在闭包里要 weak self，cell 复用时也要清理旧回调或重新覆盖。",
            practice: "prepareForReuse 里取消图片请求、停定时器、重置图片和状态；configure 必须完整赋值；异步回调用 modelID 或 requestID 校验身份。",
            memory: "cell 内存四件事：取消旧任务、停定时器、弱化回调、重置状态。"
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

        if title == nil {
            title = "UIViewController ARC 内存管理"
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    deinit {
        print("deinit ARCInterviewReviewViewController")
    }

    private func setupAppearance() {
        view.backgroundColor = ARCInterviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = ARCInterviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        view.backgroundColor = ARCInterviewStyle.backgroundColor
        tableView.backgroundColor = ARCInterviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 360
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        tableView.register(
            ARCInterviewCell.self,
            forCellReuseIdentifier: cellReuseIdentifier
        )
        tableView.register(
            ARCInterviewHeaderView.self,
            forHeaderFooterViewReuseIdentifier: headerReuseIdentifier
        )
    }

    private func updateExpandButton() {
        let isAllExpanded = expandedSectionIDs.count == sections.count
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: isAllExpanded ? "收起" : "展开",
            style: .plain,
            target: self,
            action: #selector(didTapExpandButton)
        )
    }

    @objc private func didTapExpandButton() {
        if expandedSectionIDs.count == sections.count {
            expandedSectionIDs.removeAll()
        } else {
            expandedSectionIDs = Set(sections.map(\.id))
        }

        tableView.reloadData()
        updateExpandButton()
    }

    private func toggleSection(_ section: Int) {
        let sectionID = sections[section].id

        if expandedSectionIDs.contains(sectionID) {
            expandedSectionIDs.remove(sectionID)
        } else {
            expandedSectionIDs.insert(sectionID)
        }

        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        updateExpandButton()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return expandedSectionIDs.contains(section.id) ? section.questions.count : 0
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
        ) as? ARCInterviewCell ?? ARCInterviewCell(
            style: .default,
            reuseIdentifier: cellReuseIdentifier
        )

        let section = sections[indexPath.section]
        let question = section.questions[indexPath.row]
        cell.configure(
            index: indexPath.row + 1,
            question: question,
            rows: ReviewRowKind.allCases,
            accentColor: section.tintColor
        )

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: headerReuseIdentifier
        ) as? ARCInterviewHeaderView ?? ARCInterviewHeaderView(
            reuseIdentifier: headerReuseIdentifier
        )

        let model = sections[section]
        headerView.configure(
            index: section + 1,
            section: model,
            isExpanded: expandedSectionIDs.contains(model.id)
        )
        headerView.onTap = { [weak self] in
            self?.toggleSection(section)
        }

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        92
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func makeSections() -> [InterviewSection] {
        [
            makeSection(
                id: "arc-basics",
                title: "ARC 基础",
                subtitle: "释放时机、引用关系、循环引用",
                symbolName: "link.circle.fill",
                colorIndex: 0,
                range: 0..<3
            ),
            makeSection(
                id: "closure-observer",
                title: "闭包与观察",
                subtitle: "weak self、Timer、Notification",
                symbolName: "timer.circle.fill",
                colorIndex: 1,
                range: 3..<6
            ),
            makeSection(
                id: "leak-debugging",
                title: "泄漏排查",
                subtitle: "deinit、异步任务、大对象、cell 复用",
                symbolName: "magnifyingglass.circle.fill",
                colorIndex: 2,
                range: 6..<points.count
            )
        ]
    }

    private func makeSection(
        id: String,
        title: String,
        subtitle: String,
        symbolName: String,
        colorIndex: Int,
        range: Range<Int>
    ) -> InterviewSection {
        InterviewSection(
            id: id,
            title: title,
            subtitle: subtitle,
            symbolName: symbolName,
            tintColor: ARCInterviewStyle.accentColors[
                colorIndex % ARCInterviewStyle.accentColors.count
            ],
            questions: range.map { makeQuestion(from: points[$0]) }
        )
    }

    private func makeQuestion(from point: InterviewPoint) -> InterviewQuestion {
        InterviewQuestion(
            title: point.question,
            question: point.question,
            standardAnswer: point.standardAnswer,
            principle: point.principle,
            followUp: point.followUp,
            practice: point.practice,
            memoryLine: point.memory
        )
    }
}

private final class ARCInterviewHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ARCInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = ARCInterviewStyle.titleTextColor
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        return label
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = ARCInterviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = ARCInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: ARCInterviewPaddingLabel = {
        let label = ARCInterviewPaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = ARCInterviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = ARCInterviewStyle.secondaryTextColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTap = nil
    }

    func configure(
        index: Int,
        section: ARCInterviewReviewViewController.InterviewSection,
        isExpanded: Bool
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = section.tintColor.withAlphaComponent(0.28)
        iconView.image = UIImage(systemName: section.symbolName)
        iconView.tintColor = section.tintColor
        titleLabel.text = section.title
        subtitleLabel.text = section.subtitle
        countLabel.text = "\(section.questions.count) 题"
        chevronView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        containerView.layer.borderColor = section.tintColor.withAlphaComponent(isExpanded ? 0.55 : 0.18).cgColor
        containerView.layer.borderWidth = 1
    }

    private func setupViews() {
        contentView.backgroundColor = ARCInterviewStyle.backgroundColor
        contentView.addSubview(containerView)
        containerView.addSubview(indexLabel)
        containerView.addSubview(iconView)
        containerView.addSubview(textStackView)
        containerView.addSubview(countLabel)
        containerView.addSubview(chevronView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        containerView.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            indexLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            indexLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            indexLabel.widthAnchor.constraint(equalToConstant: 30),
            indexLabel.heightAnchor.constraint(equalToConstant: 30),

            iconView.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            textStackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -10),
            textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            textStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),

            countLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -10),
            countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            chevronView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            chevronView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 18),
            chevronView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    @objc private func didTapHeader() {
        onTap?()
    }
}

private final class ARCInterviewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ARCInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: ARCInterviewPaddingLabel = {
        let label = ARCInterviewPaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = ARCInterviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = ARCInterviewStyle.titleTextColor
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentStackView.arrangedSubviews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func configure(
        index: Int,
        question: ARCInterviewReviewViewController.InterviewQuestion,
        rows: [ARCInterviewReviewViewController.ReviewRowKind],
        accentColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = accentColor.withAlphaComponent(0.26)
        titleLabel.text = question.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = accentColor.withAlphaComponent(0.20).cgColor

        rows.forEach { row in
            let fieldView = ARCInterviewFieldView()
            fieldView.configure(
                title: row.title,
                body: row.text(for: question),
                symbolName: row.iconName,
                tintColor: accentColor,
                isMemoryLine: row == .memory
            )
            contentStackView.addArrangedSubview(fieldView)
        }
    }

    private func setupViews() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = ARCInterviewStyle.selectionColor
        contentView.addSubview(containerView)
        containerView.addSubview(indexLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),

            indexLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            indexLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            titleLabel.centerYAnchor.constraint(equalTo: indexLabel.centerYAnchor),

            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            contentStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }
}

private final class ARCInterviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = ARCInterviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = ARCInterviewStyle.bodyTextColor
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ARCInterviewStyle.fieldBackgroundColor
        layer.cornerRadius = 8
        layer.masksToBounds = true

        addSubview(iconView)
        addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(bodyLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            textStackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            textStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    func configure(
        title: String,
        body: String,
        symbolName: String,
        tintColor: UIColor,
        isMemoryLine: Bool
    ) {
        iconView.image = UIImage(systemName: symbolName)
        iconView.tintColor = tintColor
        titleLabel.text = title
        titleLabel.textColor = isMemoryLine ? tintColor : ARCInterviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = isMemoryLine
            ? .systemFont(ofSize: 15, weight: .semibold)
            : .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = isMemoryLine ? ARCInterviewStyle.titleTextColor : ARCInterviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : ARCInterviewStyle.fieldBackgroundColor
    }
}

private final class ARCInterviewPaddingLabel: UILabel {

    var textInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}

private final class ARCMemorySectionHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ARCInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.layer.cornerRadius = 8
        label.layer.cornerCurve = .continuous
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = ARCInterviewStyle.titleTextColor
        label.numberOfLines = 0
        return label
    }()

    private let memoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = ARCInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .semibold
        )
        return imageView
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        onTap = nil
        titleLabel.text = nil
        memoryLabel.text = nil
        numberLabel.text = nil
        chevronImageView.image = nil
    }

    func configure(
        index: Int,
        title: String,
        memory: String,
        accentColor: UIColor,
        isExpanded: Bool
    ) {
        numberLabel.text = String(format: "%02d", index)
        numberLabel.backgroundColor = accentColor
        titleLabel.text = title
        memoryLabel.text = memory
        chevronImageView.tintColor = accentColor
        chevronImageView.image = UIImage(
            systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill"
        )
        containerView.backgroundColor = ARCInterviewStyle.headerBackgroundColor
    }

    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(numberLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(memoryLabel)
        containerView.addSubview(chevronImageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        contentView.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            numberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            numberLabel.widthAnchor.constraint(equalToConstant: 42),
            numberLabel.heightAnchor.constraint(equalToConstant: 30),

            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chevronImageView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),

            memoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            memoryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            memoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            memoryLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    @objc private func didTapHeader() {
        onTap?()
    }
}

private final class ARCMemoryDetailCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ARCInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 15,
            weight: .semibold
        )
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = ARCInterviewStyle.bodyTextColor
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.image = nil
        titleLabel.text = nil
        bodyLabel.attributedText = nil
        containerView.layer.borderWidth = 0
    }

    func configure(
        rowKind: ARCInterviewReviewViewController.ReviewRowKind,
        text: String,
        accentColor: UIColor,
        highlightedWords: [String]
    ) {
        let isMemoryRow = rowKind == .memory
        iconImageView.image = UIImage(systemName: rowKind.iconName)
        iconImageView.tintColor = isMemoryRow
            ? ARCInterviewStyle.highlightedTextColor
            : accentColor
        titleLabel.text = rowKind.title
        titleLabel.textColor = isMemoryRow
            ? ARCInterviewStyle.highlightedTextColor
            : accentColor
        bodyLabel.attributedText = makeHighlightedText(
            text,
            accentColor: accentColor,
            highlightedWords: highlightedWords,
            isProminent: isMemoryRow
        )
        containerView.backgroundColor = isMemoryRow
            ? accentColor.withAlphaComponent(0.18)
            : ARCInterviewStyle.cardBackgroundColor
        containerView.layer.borderColor = accentColor
            .withAlphaComponent(isMemoryRow ? 0.58 : 0.22)
            .cgColor
        containerView.layer.borderWidth = 1
    }

    private func setupViews() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = ARCInterviewStyle.selectionColor
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),

            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    private func makeHighlightedText(
        _ text: String,
        accentColor: UIColor,
        highlightedWords: [String],
        isProminent: Bool
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 2

        let baseFont = UIFont.systemFont(ofSize: 15, weight: isProminent ? .semibold : .regular)
        let result = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: baseFont,
                .foregroundColor: isProminent
                    ? ARCInterviewStyle.highlightedTextColor
                    : ARCInterviewStyle.bodyTextColor,
                .paragraphStyle: paragraphStyle
            ]
        )

        for word in highlightedWords {
            let ranges = rangesOfWord(word, in: text)
            for range in ranges {
                result.addAttributes(
                    [
                        .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                        .foregroundColor: ARCInterviewStyle.highlightedTextColor,
                        .backgroundColor: accentColor.withAlphaComponent(isProminent ? 0.26 : 0.18)
                    ],
                    range: range
                )
            }
        }

        return result
    }

    private func rangesOfWord(_ word: String, in text: String) -> [NSRange] {
        var ranges: [NSRange] = []
        var searchRange = text.startIndex..<text.endIndex

        while let range = text.range(of: word, options: [], range: searchRange) {
            ranges.append(NSRange(range, in: text))
            searchRange = range.upperBound..<text.endIndex
        }

        return ranges
    }
}
