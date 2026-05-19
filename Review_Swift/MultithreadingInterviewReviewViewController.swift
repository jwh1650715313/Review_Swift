//
//  MultithreadingInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/18.
//

import UIKit

private enum MultithreadingInterviewStyle {

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

/// 一个 section 对应一个多线程复习模块。
fileprivate struct MultithreadingReviewModule {

    let id: String
    let title: String
    let subtitle: String
    let symbolName: String
    let tintColor: UIColor
    let items: [MultithreadingReviewItem]
}

/// 单个 cell 的复习内容，固定包含面试题、核心答案和口诀。
fileprivate struct MultithreadingReviewItem {

    let title: String
    let question: String
    let coreAnswer: String
    let memoryLine: String
}

/// iOS 多线程面试复习页：样式对齐“数据持久化面试宝典”页面。
final class MultithreadingInterviewReviewViewController: UITableViewController {

    fileprivate enum RowKind: CaseIterable {

        case question
        case coreAnswer
        case memoryLine

        var title: String {
            switch self {
            case .question:
                return "面试题"
            case .coreAnswer:
                return "核心答案"
            case .memoryLine:
                return "快速记忆口诀"
            }
        }

        var symbolName: String {
            switch self {
            case .question:
                return "questionmark.circle.fill"
            case .coreAnswer:
                return "checkmark.seal.fill"
            case .memoryLine:
                return "bolt.fill"
            }
        }

        func text(for item: MultithreadingReviewItem) -> String {
            switch self {
            case .question:
                return item.question
            case .coreAnswer:
                return item.coreAnswer
            case .memoryLine:
                return item.memoryLine
            }
        }
    }

    private let cellReuseIdentifier = "MultithreadingInterviewCell"
    private let headerReuseIdentifier = "MultithreadingInterviewHeaderView"

    private lazy var modules: [MultithreadingReviewModule] = makeModules()
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
            title = "iOS 多线程面试"
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    private func setupAppearance() {
        view.backgroundColor = MultithreadingInterviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = MultithreadingInterviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        tableView.backgroundColor = MultithreadingInterviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 260
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        tableView.register(
            MultithreadingReviewCell.self,
            forCellReuseIdentifier: cellReuseIdentifier
        )
        tableView.register(
            MultithreadingReviewHeaderView.self,
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
        ) as? MultithreadingReviewCell ?? MultithreadingReviewCell(
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
        ) as? MultithreadingReviewHeaderView ?? MultithreadingReviewHeaderView(
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

private extension MultithreadingInterviewReviewViewController {

    func makeModules() -> [MultithreadingReviewModule] {
        [
            MultithreadingReviewModule(
                id: "gcd",
                title: "GCD",
                subtitle: "队列、任务、QoS、主线程调度",
                symbolName: "cpu.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[0],
                items: [
                    MultithreadingReviewItem(
                        title: "GCD 基础认知",
                        question: "GCD 是什么？解决什么问题？",
                        coreAnswer: "GCD 是 Apple 提供的 C 层并发编程框架，核心是把任务提交到队列，由系统线程池负责调度执行。它帮我们隐藏线程创建、复用、销毁和负载均衡细节。",
                        memoryLine: "GCD = 队列管任务，系统管线程。"
                    ),
                    MultithreadingReviewItem(
                        title: "主队列和全局队列",
                        question: "主队列和全局队列有什么区别？",
                        coreAnswer: "主队列是串行队列，任务一定在主线程执行，适合 UI 更新。全局队列是系统提供的并发队列，按 QoS 分优先级，适合耗时任务、网络回调后的数据处理。",
                        memoryLine: "UI 回主队列，耗时去全局队列。"
                    ),
                    MultithreadingReviewItem(
                        title: "QoS 优先级",
                        question: "QoS 有什么作用？",
                        coreAnswer: "QoS 表示任务优先级和资源倾向，例如 userInteractive、userInitiated、utility、background。优先级越高越容易被系统尽快调度，但不能滥用，否则会抢占资源影响续航。",
                        memoryLine: "QoS 不是越高越好，而是越符合场景越好。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "sync-async",
                title: "sync / async",
                subtitle: "是否阻塞当前线程，是否等待任务完成",
                symbolName: "arrow.left.arrow.right.circle.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[1],
                items: [
                    MultithreadingReviewItem(
                        title: "同步和异步",
                        question: "sync 和 async 的本质区别是什么？",
                        coreAnswer: "sync 会把任务提交到队列并阻塞当前线程，直到任务执行完成才继续往下走；async 只提交任务，不等待任务执行完成，当前线程会继续执行后续代码。",
                        memoryLine: "sync 等结果，async 先走人。"
                    ),
                    MultithreadingReviewItem(
                        title: "async 和新线程",
                        question: "async 一定会开新线程吗？",
                        coreAnswer: "不一定。async 只表示不阻塞当前线程，是否开启新线程取决于目标队列、系统线程池和当前调度状态。提交到主队列的 async 仍然在主线程执行。",
                        memoryLine: "async 不等于新线程，只等于不等待。"
                    ),
                    MultithreadingReviewItem(
                        title: "sync 和执行线程",
                        question: "sync 一定在当前线程执行吗？",
                        coreAnswer: "不一定。sync 表示当前线程等待任务结束。任务在哪个线程执行取决于队列；但如果对当前串行队列 sync，就会因为队列等待自己而死锁。",
                        memoryLine: "sync 管等待，不保证线程。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "queue",
                title: "串行队列 / 并发队列",
                subtitle: "任务执行顺序与同时执行能力",
                symbolName: "square.stack.3d.forward.dottedline.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[2],
                items: [
                    MultithreadingReviewItem(
                        title: "队列类型区别",
                        question: "串行队列和并发队列有什么区别？",
                        coreAnswer: "串行队列一次只执行一个任务，任务按提交顺序执行；并发队列可以同时执行多个任务，但并发能力通常需要配合 async 才体现出来。",
                        memoryLine: "串行排队一个个来，并发可同时跑多个。"
                    ),
                    MultithreadingReviewItem(
                        title: "并发队列配合同步任务",
                        question: "并发队列 + sync 会并发吗？",
                        coreAnswer: "通常不会体现并发。因为 sync 会阻塞当前线程等待当前任务完成，连续提交 sync 任务时，一个任务没结束，下一个任务不会提交出去。",
                        memoryLine: "并发队列遇到 sync，也常被等成串行。"
                    ),
                    MultithreadingReviewItem(
                        title: "自定义串行队列",
                        question: "自定义串行队列有什么实际用途？",
                        coreAnswer: "自定义串行队列常用于保护共享资源、按顺序处理文件写入、数据库操作、日志落盘等场景。它比手动加锁更容易保证顺序和隔离。",
                        memoryLine: "要顺序、要隔离，用自定义串行队列。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "deadlock",
                title: "死锁",
                subtitle: "互相等待导致任务永远无法继续",
                symbolName: "lock.trianglebadge.exclamationmark.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[3],
                items: [
                    MultithreadingReviewItem(
                        title: "主线程同步主队列",
                        question: "主线程调用 DispatchQueue.main.sync 为什么会死锁？",
                        coreAnswer: "主线程正在执行当前代码，又同步提交一个任务到主队列并等待它完成；但主队列是串行队列，新任务必须等当前任务结束才能执行，于是当前任务等新任务，新任务等当前任务，形成死锁。",
                        memoryLine: "主线程 sync 主队列：我等我自己。"
                    ),
                    MultithreadingReviewItem(
                        title: "串行队列同步自己",
                        question: "在串行队列里 sync 同一个串行队列为什么会死锁？",
                        coreAnswer: "串行队列当前任务没有执行完，后续任务不能开始。当前任务内部又 sync 提交新任务到同一个队列并等待完成，新任务排在后面永远执行不到。",
                        memoryLine: "同一串行队列 sync 自己，前门堵住后门。"
                    ),
                    MultithreadingReviewItem(
                        title: "避免死锁",
                        question: "如何避免 GCD 死锁？",
                        coreAnswer: "不要在当前串行队列中 sync 回同一个队列；UI 更新用 main.async；跨队列等待要确认没有环形依赖；能用 async、回调、Group 或 Operation 依赖表达关系时，少用嵌套 sync。",
                        memoryLine: "少嵌套 sync，多用 async 表达依赖。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "thread-safe",
                title: "线程安全",
                subtitle: "共享可变状态的正确读写",
                symbolName: "shield.lefthalf.filled",
                tintColor: MultithreadingInterviewStyle.accentColors[4],
                items: [
                    MultithreadingReviewItem(
                        title: "线程安全定义",
                        question: "什么是线程安全？",
                        coreAnswer: "多个线程同时访问同一份共享可变数据时，结果仍然正确、状态不会被破坏，就叫线程安全。问题通常来自竞态条件、读写交错、非原子操作和内存可见性。",
                        memoryLine: "线程安全看共享、可变、同时访问。"
                    ),
                    MultithreadingReviewItem(
                        title: "atomic 陷阱",
                        question: "atomic 能保证线程安全吗？",
                        coreAnswer: "Objective-C 属性的 atomic 只保证单次 getter/setter 的原子性，不保证多个操作组合后的业务线程安全。比如先读再改再写，整个过程仍可能被其他线程插入。",
                        memoryLine: "atomic 保单次，不保整段逻辑。"
                    ),
                    MultithreadingReviewItem(
                        title: "安全方案选型",
                        question: "常见线程安全方案有哪些？",
                        coreAnswer: "常见方案有串行队列、NSLock、DispatchSemaphore、pthread_mutex、读写锁、OperationQueue 限制并发数，以及 Swift 并发里的 actor。核心都是让共享可变状态有明确访问边界。",
                        memoryLine: "共享状态要么隔离，要么加锁。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "nslock",
                title: "NSLock",
                subtitle: "互斥锁、递归锁与锁粒度",
                symbolName: "lock.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[0],
                items: [
                    MultithreadingReviewItem(
                        title: "NSLock 用法",
                        question: "NSLock 怎么使用？",
                        coreAnswer: "进入临界区前调用 lock，离开时调用 unlock。为了避免异常路径忘记解锁，Swift 里常用 defer 保证成对释放。临界区只包共享数据读写，不要包耗时任务。",
                        memoryLine: "lock 后马上想 unlock，Swift 里交给 defer。"
                    ),
                    MultithreadingReviewItem(
                        title: "普通锁和递归锁",
                        question: "NSLock 和 recursive lock 有什么区别？",
                        coreAnswer: "NSLock 不允许同一线程重复加锁，否则会把自己锁住；NSRecursiveLock 允许同一线程多次进入同一把锁，适合递归调用，但滥用会掩盖设计问题。",
                        memoryLine: "普通锁不可重入，递归锁可重入。"
                    ),
                    MultithreadingReviewItem(
                        title: "加锁风险",
                        question: "加锁有什么风险？",
                        coreAnswer: "风险包括死锁、锁竞争、优先级反转、临界区过大导致性能下降。锁要遵循固定顺序、粒度尽量小，避免在持锁期间调用外部回调或做同步等待。",
                        memoryLine: "锁越久，风险越大；锁越乱，死锁越近。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "dispatch-group",
                title: "DispatchGroup",
                subtitle: "多任务汇总与统一回调",
                symbolName: "rectangle.3.group.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[1],
                items: [
                    MultithreadingReviewItem(
                        title: "任务组用途",
                        question: "DispatchGroup 用来解决什么问题？",
                        coreAnswer: "DispatchGroup 用来监听一组异步任务是否全部完成。多个请求或耗时任务并发执行后，可以在 notify 里统一刷新 UI、合并结果或进入下一步流程。",
                        memoryLine: "Group 管一组任务，全完再通知。"
                    ),
                    MultithreadingReviewItem(
                        title: "enter / leave 配对",
                        question: "enter / leave 要注意什么？",
                        coreAnswer: "手动管理异步任务时，enter 和 leave 必须严格成对出现。少 leave 会导致 notify 永远不执行，多 leave 会崩溃。所有成功、失败、取消路径都要 leave。",
                        memoryLine: "enter 一次，任何出口都 leave 一次。"
                    ),
                    MultithreadingReviewItem(
                        title: "notify 和 wait",
                        question: "notify 和 wait 有什么区别？",
                        coreAnswer: "notify 是异步通知，不阻塞当前线程；wait 会阻塞当前线程直到任务完成或超时。主线程上不要随意 wait，否则可能卡 UI，甚至和回调队列互相等待。",
                        memoryLine: "notify 更友好，wait 要谨慎。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "runloop",
                title: "RunLoop",
                subtitle: "事件循环、Mode、Timer 与线程保活",
                symbolName: "arrow.triangle.2.circlepath.circle.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[2],
                items: [
                    MultithreadingReviewItem(
                        title: "RunLoop 定义",
                        question: "RunLoop 是什么？",
                        coreAnswer: "RunLoop 是线程的事件循环机制，让线程在有事件时处理事件，没有事件时休眠，避免空转消耗 CPU。主线程默认开启 RunLoop，用来处理触摸、Timer、Source、界面刷新等事件。",
                        memoryLine: "RunLoop = 有事干活，没事睡觉。"
                    ),
                    MultithreadingReviewItem(
                        title: "RunLoop Mode",
                        question: "RunLoop Mode 有什么作用？",
                        coreAnswer: "Mode 用来隔离不同场景下的事件源。滚动 UIScrollView 时主线程进入 tracking mode，如果 Timer 只加在 default mode，滚动期间就不会触发。",
                        memoryLine: "Mode 不同，事件源互不打扰。"
                    ),
                    MultithreadingReviewItem(
                        title: "常驻线程",
                        question: "RunLoop 和常驻线程有什么关系？",
                        coreAnswer: "子线程执行完任务默认会退出。如果想让线程长期等待事件，可以给线程配置 RunLoop 并添加 Source、Port 或 Timer，让 RunLoop 跑起来维持线程生命周期。",
                        memoryLine: "线程想常驻，RunLoop 要有事可等。"
                    )
                ]
            ),
            MultithreadingReviewModule(
                id: "operation-queue",
                title: "OperationQueue",
                subtitle: "可取消、可依赖、可控制并发数",
                symbolName: "list.bullet.rectangle.portrait.fill",
                tintColor: MultithreadingInterviewStyle.accentColors[3],
                items: [
                    MultithreadingReviewItem(
                        title: "GCD 和 OperationQueue",
                        question: "OperationQueue 和 GCD 有什么区别？",
                        coreAnswer: "GCD 更轻量，适合简单异步调度；OperationQueue 基于 Operation 抽象，支持取消、依赖、优先级、最大并发数和 KVO 状态，更适合复杂任务编排。",
                        memoryLine: "简单调度用 GCD，复杂编排用 OperationQueue。"
                    ),
                    MultithreadingReviewItem(
                        title: "Operation 取消机制",
                        question: "Operation 的取消是强制停止吗？",
                        coreAnswer: "不是。cancel 只是把 isCancelled 标记设为 true，任务内部需要主动检查并尽早退出。系统不会粗暴杀掉正在执行的代码。",
                        memoryLine: "cancel 是提醒，不是强杀。"
                    ),
                    MultithreadingReviewItem(
                        title: "控制并发数",
                        question: "如何控制 OperationQueue 并发数？",
                        coreAnswer: "通过 maxConcurrentOperationCount 控制同时执行的 Operation 数量。设置为 1 时接近串行队列，适合顺序任务；设置为合理并发数可避免网络、CPU 或 IO 被打满。",
                        memoryLine: "maxConcurrentOperationCount 控并发，1 就是顺序跑。"
                    )
                ]
            )
        ]
    }
}

private final class MultithreadingReviewHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = MultithreadingInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = MultithreadingInterviewStyle.titleTextColor
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
        label.textColor = MultithreadingInterviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = MultithreadingInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: MultithreadingPaddingLabel = {
        let label = MultithreadingPaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = MultithreadingInterviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = MultithreadingInterviewStyle.secondaryTextColor
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
        module: MultithreadingReviewModule,
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

    private func setupViews() {
        contentView.backgroundColor = MultithreadingInterviewStyle.backgroundColor
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

private final class MultithreadingReviewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = MultithreadingInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: MultithreadingPaddingLabel = {
        let label = MultithreadingPaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = MultithreadingInterviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = MultithreadingInterviewStyle.titleTextColor
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
        item: MultithreadingReviewItem,
        rows: [MultithreadingInterviewReviewViewController.RowKind],
        tintColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = tintColor.withAlphaComponent(0.26)
        titleLabel.text = item.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = tintColor.withAlphaComponent(0.20).cgColor

        rows.forEach { row in
            let fieldView = MultithreadingReviewFieldView()
            fieldView.configure(
                title: row.title,
                body: row.text(for: item),
                symbolName: row.symbolName,
                tintColor: tintColor,
                isMemoryLine: row == .memoryLine
            )
            contentStackView.addArrangedSubview(fieldView)
        }
    }

    private func setupViews() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = MultithreadingInterviewStyle.selectionColor
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

private final class MultithreadingReviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = MultithreadingInterviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = MultithreadingInterviewStyle.bodyTextColor
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
        titleLabel.textColor = isMemoryLine ? tintColor : MultithreadingInterviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = isMemoryLine
            ? .systemFont(ofSize: 15, weight: .semibold)
            : .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = isMemoryLine
            ? MultithreadingInterviewStyle.titleTextColor
            : MultithreadingInterviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : MultithreadingInterviewStyle.fieldBackgroundColor
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = MultithreadingInterviewStyle.fieldBackgroundColor
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
}

private final class MultithreadingPaddingLabel: UILabel {

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
