//
//  SwiftFoundationInterviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/18.
//

import UIKit

private enum SwiftFoundationInterviewStyle {

    static let backgroundColor = UIColor(red: 0.035, green: 0.045, blue: 0.060, alpha: 1.0)
    static let headerBackgroundColor = UIColor(red: 0.080, green: 0.092, blue: 0.125, alpha: 1.0)
    static let cardBackgroundColor = UIColor(red: 0.098, green: 0.112, blue: 0.150, alpha: 1.0)
    static let fieldBackgroundColor = UIColor(red: 0.060, green: 0.070, blue: 0.098, alpha: 1.0)
    static let titleTextColor = UIColor(white: 0.97, alpha: 1.0)
    static let bodyTextColor = UIColor(white: 0.84, alpha: 1.0)
    static let secondaryTextColor = UIColor(white: 0.68, alpha: 1.0)
    static let selectionColor = UIColor.white.withAlphaComponent(0.045)

    static let accentColors: [UIColor] = [
        UIColor(red: 0.27, green: 0.74, blue: 1.00, alpha: 1.0),
        UIColor(red: 0.36, green: 0.90, blue: 0.66, alpha: 1.0),
        UIColor(red: 1.00, green: 0.64, blue: 0.30, alpha: 1.0),
        UIColor(red: 0.73, green: 0.58, blue: 1.00, alpha: 1.0),
        UIColor(red: 0.20, green: 0.84, blue: 0.92, alpha: 1.0)
    ]
}

fileprivate struct SwiftFoundationReviewModule {

    let id: String
    let title: String
    let subtitle: String
    let symbolName: String
    let tintColor: UIColor
    let items: [SwiftFoundationReviewItem]
}

fileprivate struct SwiftFoundationReviewItem {

    let title: String
    let interviewQuestion: String
    let frequentAnswer: String
    let memoryPoint: String
    let codeExample: String
    let memoryLine: String
}

final class SwiftFoundationInterviewViewController: UITableViewController {

    fileprivate enum RowKind: CaseIterable {

        case interviewQuestion
        case frequentAnswer
        case memoryPoint
        case codeExample
        case memoryLine

        var title: String {
            switch self {
            case .interviewQuestion:
                return "面试题"
            case .frequentAnswer:
                return "高频回答"
            case .memoryPoint:
                return "核心记忆点"
            case .codeExample:
                return "简短代码示例"
            case .memoryLine:
                return "一句话速记"
            }
        }

        var symbolName: String {
            switch self {
            case .interviewQuestion:
                return "questionmark.circle.fill"
            case .frequentAnswer:
                return "checkmark.seal.fill"
            case .memoryPoint:
                return "lightbulb.fill"
            case .codeExample:
                return "curlybraces.square.fill"
            case .memoryLine:
                return "bolt.fill"
            }
        }

        func text(for item: SwiftFoundationReviewItem) -> String {
            switch self {
            case .interviewQuestion:
                return item.interviewQuestion
            case .frequentAnswer:
                return item.frequentAnswer
            case .memoryPoint:
                return item.memoryPoint
            case .codeExample:
                return item.codeExample
            case .memoryLine:
                return item.memoryLine
            }
        }
    }

    private let cellReuseIdentifier = "SwiftFoundationInterviewCell"
    private let headerReuseIdentifier = "SwiftFoundationInterviewHeaderView"

    private lazy var modules: [SwiftFoundationReviewModule] = makeModules()
    private var expandedModuleIDs: Set<String> = []

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if title == nil {
            title = "Swift 基础高频面试题"
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    private func setupAppearance() {
        view.backgroundColor = SwiftFoundationInterviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = SwiftFoundationInterviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        tableView.backgroundColor = SwiftFoundationInterviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 360
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        tableView.register(
            SwiftFoundationReviewCell.self,
            forCellReuseIdentifier: cellReuseIdentifier
        )
        tableView.register(
            SwiftFoundationReviewHeaderView.self,
            forHeaderFooterViewReuseIdentifier: headerReuseIdentifier
        )
    }

    private func updateExpandButton() {
        let isAllExpanded = expandedModuleIDs.count == modules.count
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: isAllExpanded ? "收起" : "展开",
            style: .plain,
            target: self,
            action: #selector(didTapExpandButton)
        )
    }

    @objc private func didTapExpandButton() {
        if expandedModuleIDs.count == modules.count {
            expandedModuleIDs.removeAll()
        } else {
            expandedModuleIDs = Set(modules.map(\.id))
        }

        tableView.reloadData()
        updateExpandButton()
    }

    private func toggleSection(_ section: Int) {
        let moduleID = modules[section].id

        if expandedModuleIDs.contains(moduleID) {
            expandedModuleIDs.remove(moduleID)
        } else {
            expandedModuleIDs.insert(moduleID)
        }

        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        updateExpandButton()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        modules.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let module = modules[section]
        return expandedModuleIDs.contains(module.id) ? module.items.count : 0
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
        ) as? SwiftFoundationReviewCell ?? SwiftFoundationReviewCell(
            style: .default,
            reuseIdentifier: cellReuseIdentifier
        )

        let module = modules[indexPath.section]
        let item = module.items[indexPath.row]
        cell.configure(
            index: indexPath.row + 1,
            item: item,
            rows: RowKind.allCases,
            tintColor: module.tintColor
        )

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: headerReuseIdentifier
        ) as? SwiftFoundationReviewHeaderView ?? SwiftFoundationReviewHeaderView(
            reuseIdentifier: headerReuseIdentifier
        )

        let module = modules[section]
        headerView.configure(
            index: section + 1,
            module: module,
            isExpanded: expandedModuleIDs.contains(module.id)
        )
        headerView.onTap = { [weak self] in
            self?.toggleSection(section)
        }

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForHeaderInSection section: Int
    ) -> CGFloat {
        82
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension SwiftFoundationInterviewViewController {

    func makeModules() -> [SwiftFoundationReviewModule] {
        [
            makeModule(
                id: "optional",
                title: "Optional",
                subtitle: "本质、? / !、nil、optional chaining",
                symbolName: "questionmark.circle.fill",
                colorIndex: 0,
                item: SwiftFoundationReviewItem(
                    title: "Optional 本质",
                    interviewQuestion: "Swift Optional 的本质是什么？?、!、nil、optional chaining 怎么答？",
                    frequentAnswer: "Optional 本质是 enum，表示有值 some 或无值 none。\n? 是安全可选值，需要解包；! 是隐式解包，取 nil 会崩。\nnil 表示没有值，不是空对象。\noptional chaining 会在任一环节 nil 时直接返回 nil。",
                    memoryPoint: "Optional = 类型安全地表达“可能没值”，核心是先判空再用值。",
                    codeExample: """
                    var name: String? = "Swift"
                    print(name?.count ?? 0)

                    let forced: String! = "OK"
                    print(forced.count)
                    """,
                    memoryLine: "面试速记：Optional 不是语法糖，是 some / none 的安全容器。"
                )
            ),
            makeModule(
                id: "guard-if-let",
                title: "guard let / if let",
                subtitle: "区别、使用场景、标准回答",
                symbolName: "arrow.triangle.branch",
                colorIndex: 1,
                item: SwiftFoundationReviewItem(
                    title: "解包控制流",
                    interviewQuestion: "guard let 和 if let 有什么区别？分别适合什么场景？",
                    frequentAnswer: "if let 适合局部解包，作用域只在 if 内。\nguard let 适合前置校验，失败必须 return / throw / break。\nguard 解包后的变量在后续作用域可直接使用，能减少嵌套。",
                    memoryPoint: "if let 管局部，guard let 管入口；面试重点是作用域和控制流。",
                    codeExample: """
                    func show(user: User?) {
                        guard let user else { return }
                        print(user.name)
                    }
                    """,
                    memoryLine: "面试速记：能提前失败就 guard，临时判断就 if。"
                )
            ),
            makeModule(
                id: "protocol",
                title: "protocol",
                subtitle: "本质、面向协议编程、delegate 原理",
                symbolName: "puzzlepiece.extension.fill",
                colorIndex: 2,
                item: SwiftFoundationReviewItem(
                    title: "协议能力契约",
                    interviewQuestion: "protocol 的本质是什么？面向协议编程和 delegate 怎么理解？",
                    frequentAnswer: "protocol 是一组能力契约，只声明“会什么”，不关心“是谁”。\n面向协议编程强调依赖抽象，struct / class / enum 都能遵守协议。\ndelegate 是协议的经典用法：对象把事件回调给代理，常用 weak 避免循环引用。",
                    memoryPoint: "protocol 让代码依赖能力而不是具体类型，delegate 是协议 + 反向回调。",
                    codeExample: """
                    protocol LoginDelegate: AnyObject {
                        func didLogin()
                    }

                    weak var delegate: LoginDelegate?
                    delegate?.didLogin()
                    """,
                    memoryLine: "面试速记：protocol 是能力清单，delegate 是把事件交给别人处理。"
                )
            ),
            makeModule(
                id: "extension",
                title: "extension",
                subtitle: "扩展能力、限制、分类能力",
                symbolName: "plus.square.on.square.fill",
                colorIndex: 3,
                item: SwiftFoundationReviewItem(
                    title: "类型扩展",
                    interviewQuestion: "extension 能做什么？不能做什么？和分类能力怎么答？",
                    frequentAnswer: "extension 可以给已有类型加方法、计算属性、协议遵守、嵌套类型、便利初始化。\n不能新增存储属性，不能重写已有方法，不能真正改变原类型内存布局。\n它类似分类能力，适合按功能拆分代码。",
                    memoryPoint: "extension 是“扩展行为”，不是“扩展存储”。",
                    codeExample: """
                    extension String {
                        var isBlank: Bool {
                            trimmingCharacters(in: .whitespaces).isEmpty
                        }
                    }
                    """,
                    memoryLine: "面试速记：extension 加能力，不加存储。"
                )
            ),
            makeModule(
                id: "closure",
                title: "closure",
                subtitle: "闭包本质、尾随闭包、循环引用",
                symbolName: "curlybraces.square.fill",
                colorIndex: 4,
                item: SwiftFoundationReviewItem(
                    title: "闭包与捕获",
                    interviewQuestion: "闭包的本质是什么？尾随闭包和循环引用怎么答？",
                    frequentAnswer: "闭包是可以捕获上下文的代码块，本质上可作为值传递和保存。\n尾随闭包只是调用语法更简洁，常见于回调和高阶函数。\n闭包默认强捕获 self，如果 self 又持有闭包，就可能循环引用。",
                    memoryPoint: "闭包重点看两件事：会不会捕获上下文，会不会被长期持有。",
                    codeExample: """
                    numbers.map { $0 * 2 }

                    onTap = { [weak self] in
                        self?.reloadData()
                    }
                    """,
                    memoryLine: "面试速记：闭包是带捕获能力的函数值。"
                )
            ),
            makeModule(
                id: "escaping",
                title: "escaping",
                subtitle: "逃逸原因、生命周期、异步场景",
                symbolName: "arrow.up.forward.app.fill",
                colorIndex: 0,
                item: SwiftFoundationReviewItem(
                    title: "逃逸闭包",
                    interviewQuestion: "@escaping 为什么需要？和生命周期、异步有什么关系？",
                    frequentAnswer: "默认闭包是非逃逸，函数结束前执行完。\n@escaping 表示闭包可能在函数返回后才执行，常见于网络请求、GCD、动画完成回调。\n逃逸闭包生命周期更长，所以捕获 self 时更容易出现循环引用或延长生命周期。",
                    memoryPoint: "escaping 的核心是闭包逃出函数作用域，未来某个时间再调用。",
                    codeExample: """
                    func request(done: @escaping (String) -> Void) {
                        DispatchQueue.main.async {
                            done("success")
                        }
                    }
                    """,
                    memoryLine: "面试速记：函数返回后还会用的闭包，就要 @escaping。"
                )
            ),
            makeModule(
                id: "capture-list",
                title: "capture list",
                subtitle: "[weak self]、[unowned self]、生命周期差异",
                symbolName: "scope",
                colorIndex: 1,
                item: SwiftFoundationReviewItem(
                    title: "捕获列表",
                    interviewQuestion: "capture list 怎么用？weak self 和 unowned self 有什么区别？",
                    frequentAnswer: "capture list 用来控制闭包捕获变量的方式。\n[weak self] 不增加引用计数，self 会变成 Optional，释放后自动 nil。\n[unowned self] 不增加引用计数，但释放后不会置 nil，访问会崩溃。",
                    memoryPoint: "生命周期不确定用 weak；确定 self 一定比闭包活得久，才考虑 unowned。",
                    codeExample: """
                    api.load { [weak self] result in
                        self?.render(result)
                    }

                    animation.done { [unowned self] in
                        finish()
                    }
                    """,
                    memoryLine: "面试速记：weak 安全但要解包，unowned 简洁但赌生命周期。"
                )
            ),
            makeModule(
                id: "copy-on-write",
                title: "copy-on-write",
                subtitle: "值类型性能、Array 底层优化",
                symbolName: "doc.on.doc.fill",
                colorIndex: 2,
                item: SwiftFoundationReviewItem(
                    title: "写时复制",
                    interviewQuestion: "Array 为什么是值类型但性能还高？copy-on-write 怎么答？",
                    frequentAnswer: "Array / Dictionary / Set 是值类型，但底层存储可以共享。\n复制时先不真正拷贝，只共享同一份 buffer。\n当其中一个副本发生写入时，Swift 才检查引用并复制存储，这就是 COW。",
                    memoryPoint: "COW 让值语义保留安全性，同时避免无意义的深拷贝。",
                    codeExample: """
                    var a = [1, 2, 3]
                    var b = a
                    b.append(4) // 写入时才复制
                    print(a)    // [1, 2, 3]
                    """,
                    memoryLine: "面试速记：读时共享，写时复制。"
                )
            ),
            makeModule(
                id: "lazy",
                title: "lazy",
                subtitle: "初始化时机、使用场景、var 限制",
                symbolName: "clock.badge.checkmark.fill",
                colorIndex: 3,
                item: SwiftFoundationReviewItem(
                    title: "延迟初始化",
                    interviewQuestion: "lazy 的初始化时机是什么？适合什么场景？",
                    frequentAnswer: "lazy 属性第一次被访问时才初始化，之后会保存结果。\n适合初始化成本高、可能不用、或初始化时需要访问 self 的属性。\nlazy 必须用 var，因为第一次访问会改变对象状态。",
                    memoryPoint: "lazy 是延迟创建，不是每次重新创建。",
                    codeExample: """
                    lazy var formatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        return formatter
                    }()
                    """,
                    memoryLine: "面试速记：第一次用才创建，创建后就缓存。"
                )
            ),
            makeModule(
                id: "static",
                title: "static",
                subtitle: "static / class 区别、单例",
                symbolName: "s.square.fill",
                colorIndex: 4,
                item: SwiftFoundationReviewItem(
                    title: "类型成员",
                    interviewQuestion: "static 和 class 有什么区别？和单例怎么联系？",
                    frequentAnswer: "static 修饰类型成员，不能被子类重写。\nclass 只能用于 class 的类型方法 / 计算属性，允许子类 override。\n单例常用 static let，Swift 保证懒加载和线程安全初始化。",
                    memoryPoint: "static 是类型级别且不可重写；class 是类级别且可重写。",
                    codeExample: """
                    final class SessionManager {
                        static let shared = SessionManager()
                        private init() {}
                    }
                    """,
                    memoryLine: "面试速记：单例优先 static let shared。"
                )
            ),
            makeModule(
                id: "final",
                title: "final",
                subtitle: "防止继承、禁止重写、性能优化",
                symbolName: "lock.shield.fill",
                colorIndex: 0,
                item: SwiftFoundationReviewItem(
                    title: "最终派发",
                    interviewQuestion: "final 的作用是什么？为什么说它能优化性能？",
                    frequentAnswer: "final 可以修饰 class、method、property，表示不能被继承或重写。\n它能明确设计边界，防止子类破坏行为。\n编译器知道不会被 override 后，可做静态派发、内联等优化。",
                    memoryPoint: "final 既是设计约束，也是潜在性能优化信号。",
                    codeExample: """
                    final class TokenStore {
                        func save(_ token: String) {
                            print(token)
                        }
                    }
                    """,
                    memoryLine: "面试速记：不想被继承和重写，就 final。"
                )
            )
        ]
    }

    func makeModule(
        id: String,
        title: String,
        subtitle: String,
        symbolName: String,
        colorIndex: Int,
        item: SwiftFoundationReviewItem
    ) -> SwiftFoundationReviewModule {
        SwiftFoundationReviewModule(
            id: id,
            title: title,
            subtitle: subtitle,
            symbolName: symbolName,
            tintColor: SwiftFoundationInterviewStyle.accentColors[
                colorIndex % SwiftFoundationInterviewStyle.accentColors.count
            ],
            items: [item]
        )
    }
}

private final class SwiftFoundationReviewHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SwiftFoundationInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = SwiftFoundationInterviewStyle.titleTextColor
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
        label.textColor = SwiftFoundationInterviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = SwiftFoundationInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: SwiftFoundationPaddingLabel = {
        let label = SwiftFoundationPaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = SwiftFoundationInterviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = SwiftFoundationInterviewStyle.secondaryTextColor
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

    private func setupViews() {
        contentView.backgroundColor = SwiftFoundationInterviewStyle.backgroundColor
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

    func configure(
        index: Int,
        module: SwiftFoundationReviewModule,
        isExpanded: Bool
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = module.tintColor.withAlphaComponent(0.28)
        iconView.image = UIImage(systemName: module.symbolName)
        iconView.tintColor = module.tintColor
        titleLabel.text = module.title
        subtitleLabel.text = module.subtitle
        countLabel.text = "\(module.items.count) 题"
        chevronView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        containerView.layer.borderColor = module.tintColor.withAlphaComponent(isExpanded ? 0.55 : 0.18).cgColor
        containerView.layer.borderWidth = 1
    }

    @objc private func didTapHeader() {
        onTap?()
    }
}

private final class SwiftFoundationReviewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SwiftFoundationInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: SwiftFoundationPaddingLabel = {
        let label = SwiftFoundationPaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = SwiftFoundationInterviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = SwiftFoundationInterviewStyle.titleTextColor
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

    private func setupViews() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = SwiftFoundationInterviewStyle.selectionColor
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

    func configure(
        index: Int,
        item: SwiftFoundationReviewItem,
        rows: [SwiftFoundationInterviewViewController.RowKind],
        tintColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = tintColor.withAlphaComponent(0.26)
        titleLabel.text = item.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = tintColor.withAlphaComponent(0.20).cgColor

        rows.forEach { row in
            let fieldView = SwiftFoundationReviewFieldView()
            fieldView.configure(
                title: row.title,
                body: row.text(for: item),
                symbolName: row.symbolName,
                tintColor: tintColor,
                isCodeExample: row == .codeExample,
                isMemoryLine: row == .memoryLine
            )
            contentStackView.addArrangedSubview(fieldView)
        }
    }
}

private final class SwiftFoundationReviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = SwiftFoundationInterviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = SwiftFoundationInterviewStyle.bodyTextColor
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
        backgroundColor = SwiftFoundationInterviewStyle.fieldBackgroundColor
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
        isCodeExample: Bool,
        isMemoryLine: Bool
    ) {
        iconView.image = UIImage(systemName: symbolName)
        iconView.tintColor = tintColor
        titleLabel.text = title
        titleLabel.textColor = isMemoryLine ? tintColor : SwiftFoundationInterviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = font(isCodeExample: isCodeExample, isMemoryLine: isMemoryLine)
        bodyLabel.textColor = isMemoryLine
            ? SwiftFoundationInterviewStyle.titleTextColor
            : SwiftFoundationInterviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : SwiftFoundationInterviewStyle.fieldBackgroundColor
    }

    private func font(isCodeExample: Bool, isMemoryLine: Bool) -> UIFont {
        if isCodeExample {
            return .monospacedSystemFont(ofSize: 13, weight: .medium)
        }

        if isMemoryLine {
            return .systemFont(ofSize: 15, weight: .semibold)
        }

        return .systemFont(ofSize: 14, weight: .regular)
    }
}

private final class SwiftFoundationPaddingLabel: UILabel {

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
