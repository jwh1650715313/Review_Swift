//
//  UIKitInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/18.
//

import UIKit

private enum UIKitInterviewStyle {

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

final class UIKitInterviewReviewViewController: UIViewController {

    fileprivate struct ReviewPoint {

        let id: String
        let title: String
        let question: String
        let coreAnswer: String
        let mnemonic: String
        let followUp: String
        let codeExample: String
        let projectScenario: String
        let summary: String
    }

    private struct ReviewSection {

        let id: String
        let title: String
        let subtitle: String
        let symbolName: String
        let tintColor: UIColor
        let points: [ReviewPoint]
    }

    fileprivate enum RowKind: CaseIterable {

        case question
        case coreAnswer
        case mnemonic
        case followUp
        case codeExample
        case projectScenario
        case summary

        var title: String {
            switch self {
            case .summary:
                return "一句话总结"
            case .question:
                return "面试题"
            case .coreAnswer:
                return "核心答案"
            case .mnemonic:
                return "口诀"
            case .followUp:
                return "常见追问"
            case .codeExample:
                return "代码示例"
            case .projectScenario:
                return "项目场景"
            }
        }

        var symbolName: String {
            switch self {
            case .summary:
                return "bolt.fill"
            case .question:
                return "questionmark.circle.fill"
            case .coreAnswer:
                return "checkmark.seal.fill"
            case .mnemonic:
                return "textformat.abc"
            case .followUp:
                return "bubble.left.and.bubble.right.fill"
            case .codeExample:
                return "curlybraces.square.fill"
            case .projectScenario:
                return "briefcase.fill"
            }
        }

        func text(for point: ReviewPoint) -> String {
            switch self {
            case .summary:
                return point.summary
            case .question:
                return point.question
            case .coreAnswer:
                return point.coreAnswer
            case .mnemonic:
                return point.mnemonic
            case .followUp:
                return point.followUp
            case .codeExample:
                return point.codeExample
            case .projectScenario:
                return point.projectScenario
            }
        }
    }

    private let pointCellReuseIdentifier = "UIKitInterviewCell"
    private let categoryHeaderReuseIdentifier = "UIKitInterviewHeaderView"

    private lazy var sections: [ReviewSection] = makeSections()
    private var expandedSectionIDs: Set<String> = []

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIKitInterviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 360
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        return tableView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if title == nil {
            title = "UIKit 高频面试题"
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    private func setupAppearance() {
        view.backgroundColor = UIKitInterviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = UIKitInterviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UIKitReviewPointCell.self,
            forCellReuseIdentifier: pointCellReuseIdentifier
        )
        tableView.register(
            UIKitReviewCategoryHeaderView.self,
            forHeaderFooterViewReuseIdentifier: categoryHeaderReuseIdentifier
        )

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

    private func makeSections() -> [ReviewSection] {
        [
            ReviewSection(
                id: "uiview-lifecycle",
                title: "UIView 生命周期",
                subtitle: "创建、入层级、布局、绘制、强制刷新",
                symbolName: "rectangle.3.group.fill",
                tintColor: UIKitInterviewStyle.accentColors[0],
                points: makeUIViewLifecyclePoints()
            ),
            ReviewSection(
                id: "viewcontroller-lifecycle",
                title: "UIViewController 生命周期",
                subtitle: "loadView 到 deinit，区分一次和多次",
                symbolName: "macwindow.on.rectangle",
                tintColor: UIKitInterviewStyle.accentColors[1],
                points: makeViewControllerLifecyclePoints()
            ),
            ReviewSection(
                id: "autolayout",
                title: "AutoLayout 原理",
                subtitle: "约束方程、固有尺寸、优先级、冲突",
                symbolName: "ruler.fill",
                tintColor: UIKitInterviewStyle.accentColors[2],
                points: makeAutoLayoutPoints()
            ),
            ReviewSection(
                id: "responder-chain",
                title: "事件响应链",
                subtitle: "hitTest、pointInside、firstResponder、按钮点击",
                symbolName: "hand.tap.fill",
                tintColor: UIKitInterviewStyle.accentColors[3],
                points: makeResponderChainPoints()
            ),
            ReviewSection(
                id: "gesture-conflict",
                title: "手势冲突处理",
                subtitle: "delegate、同时识别、失败依赖、侧滑返回",
                symbolName: "hand.draw.fill",
                tintColor: UIKitInterviewStyle.accentColors[4],
                points: makeGestureConflictPoints()
            )
        ]
    }

    private func makeUIViewLifecyclePoints() -> [ReviewPoint] {
        [
            ReviewPoint(
                id: "uiview-init",
                title: "init",
                question: "UIView 的 init 什么时候调用？适合做什么？",
                coreAnswer: "创建视图对象时调用。代码创建走 init(frame:)，Storyboard/Xib 走 init(coder:)。适合初始化属性、创建固定子视图、设置默认样式；不要依赖 superview、window 和最终尺寸。",
                mnemonic: "口诀：init 只造视图，不问舞台。",
                followUp: "追问：为什么 init 里不要写依赖父视图的逻辑？因为此时还没加入视图层级，superview/window 通常是 nil，bounds 也可能不是最终值。",
                codeExample: """
                final class BadgeView: UIView {
                    override init(frame: CGRect) {
                        super.init(frame: frame)
                        setupUI()
                    }

                    required init?(coder: NSCoder) {
                        super.init(coder: coder)
                        setupUI()
                    }

                    private func setupUI() {
                        backgroundColor = .systemBlue
                        layer.cornerRadius = 8
                    }
                }
                """,
                projectScenario: "项目里自定义 Header、Cell 子控件通常在 init 创建 UI；需要父视图大小、埋点曝光、动画启动的逻辑放到后续生命周期。",
                summary: "一句话：init 负责把视图对象搭起来，不负责层级和最终布局。"
            ),
            ReviewPoint(
                id: "uiview-didMoveToSuperview",
                title: "didMoveToSuperview",
                question: "didMoveToSuperview 什么时候触发？",
                coreAnswer: "UIView 被添加到父视图或从父视图移除后调用。调用时 superview 已经更新，加入时有值，移除时可能为 nil。适合做和父视图相关的轻量配置。",
                mnemonic: "口诀：进出父视图，看 superview。",
                followUp: "追问：它和 init 的区别？init 是对象创建；didMoveToSuperview 是层级关系变化，同一个 view 可以被多次添加和移除。",
                codeExample: """
                final class HintView: UIView {
                    override func didMoveToSuperview() {
                        super.didMoveToSuperview()
                        isHidden = superview == nil
                    }
                }
                """,
                projectScenario: "封装空态视图、角标视图时，可以在加入父视图后读取父视图背景色或注册轻量事件；移除时停止不必要的观察。",
                summary: "一句话：didMoveToSuperview 关心的是 view 和父视图的关系变化。"
            ),
            ReviewPoint(
                id: "uiview-didMoveToWindow",
                title: "didMoveToWindow",
                question: "didMoveToWindow 有什么用？",
                coreAnswer: "UIView 进入或离开 UIWindow 时调用。window 有值表示视图真正进入屏幕窗口；window 为 nil 表示离屏或被移除。适合启动/停止动画、定时器、DisplayLink 等可见性相关任务。",
                mnemonic: "口诀：有 window 才算上屏。",
                followUp: "追问：它和 didMoveToSuperview 谁更接近曝光？didMoveToWindow 更接近，因为加入父视图不代表一定显示在窗口上。",
                codeExample: """
                final class PulseView: UIView {
                    private var displayLink: CADisplayLink?

                    override func didMoveToWindow() {
                        super.didMoveToWindow()
                        window == nil ? stopPulse() : startPulse()
                    }

                    private func startPulse() {
                        displayLink = CADisplayLink(target: self, selector: #selector(tick))
                        displayLink?.add(to: .main, forMode: .common)
                    }

                    private func stopPulse() {
                        displayLink?.invalidate()
                        displayLink = nil
                    }

                    @objc private func tick() {}
                }
                """,
                projectScenario: "列表 cell 内动画、播放器预览、CADisplayLink 最好在进入 window 后启动，离开 window 后停止，避免离屏还占资源。",
                summary: "一句话：didMoveToWindow 是判断视图是否真正进入屏幕窗口的关键点。"
            ),
            ReviewPoint(
                id: "uiview-layoutSubviews",
                title: "layoutSubviews",
                question: "layoutSubviews 什么时候调用？应该注意什么？",
                coreAnswer: "系统需要重新布局子视图时调用，比如 bounds 变化、约束变化、setNeedsLayout 后的布局周期。适合设置子视图 frame 或更新依赖尺寸的 layer；不要在里面无限触发布局。",
                mnemonic: "口诀：layoutSubviews 只排版，不做重活。",
                followUp: "追问：为什么别在 layoutSubviews 里反复 setNeedsLayout？容易形成布局循环，导致卡顿甚至死循环。",
                codeExample: """
                final class AvatarView: UIView {
                    private let imageView = UIImageView()

                    override func layoutSubviews() {
                        super.layoutSubviews()
                        imageView.frame = bounds
                        imageView.layer.cornerRadius = bounds.width / 2
                        imageView.layer.masksToBounds = true
                    }
                }
                """,
                projectScenario: "头像圆角、渐变 layer frame、自定义布局容器常在 layoutSubviews 更新，因为这里能拿到更可靠的 bounds。",
                summary: "一句话：layoutSubviews 是把已有子视图按当前尺寸摆好的地方。"
            ),
            ReviewPoint(
                id: "uiview-drawRect",
                title: "drawRect / draw(_:)",
                question: "drawRect 是什么？和 layoutSubviews 有什么区别？",
                coreAnswer: "Objective-C 叫 drawRect，Swift 中重写 draw(_:)。它负责自定义绘制内容，由 setNeedsDisplay 触发。layoutSubviews 负责布局子视图；draw 负责画图，不适合创建子视图或做复杂业务。",
                mnemonic: "口诀：layout 排位置，draw 画像素。",
                followUp: "追问：为什么 draw 里不要做耗时操作？绘制发生在渲染链路上，耗时会直接影响帧率；复杂绘制应缓存或异步生成图片。",
                codeExample: """
                final class RingView: UIView {
                    override func draw(_ rect: CGRect) {
                        let path = UIBezierPath(
                            ovalIn: rect.insetBy(dx: 8, dy: 8)
                        )
                        UIColor.systemCyan.setStroke()
                        path.lineWidth = 4
                        path.stroke()
                    }
                }
                """,
                projectScenario: "进度环、水印、简单图形背景可以用 draw(_:)；复杂图文列表要谨慎，优先考虑缓存图片或 layer 方案。",
                summary: "一句话：drawRect 管绘制，layoutSubviews 管布局，二者别混用。"
            ),
            ReviewPoint(
                id: "uiview-setNeedsLayout",
                title: "setNeedsLayout",
                question: "setNeedsLayout 的作用是什么？",
                coreAnswer: "它只是标记视图需要重新布局，不会立刻调用 layoutSubviews。系统会在下一次布局周期统一处理，多次调用会被合并，适合状态变化后异步刷新布局。",
                mnemonic: "口诀：setNeedsLayout 是预约布局。",
                followUp: "追问：调用后为什么 frame 没马上变？因为它只是打标记，真正布局要等 run loop 的布局阶段，或者配合 layoutIfNeeded 立即执行。",
                codeExample: """
                final class ExpandableView: UIView {
                    var isExpanded = false {
                        didSet {
                            setNeedsLayout()
                        }
                    }

                    override func layoutSubviews() {
                        super.layoutSubviews()
                        alpha = isExpanded ? 1.0 : 0.6
                    }
                }
                """,
                projectScenario: "按钮选中、卡片展开、内容变化后需要重新排版时，用 setNeedsLayout 合并多次布局请求，避免每次都立即算布局。",
                summary: "一句话：setNeedsLayout 只是告诉系统“之后要重新布局”。"
            ),
            ReviewPoint(
                id: "uiview-layoutIfNeeded",
                title: "layoutIfNeeded",
                question: "layoutIfNeeded 和 setNeedsLayout 有什么区别？",
                coreAnswer: "layoutIfNeeded 会在当前有待布局标记时立即触发布局；setNeedsLayout 只是异步标记。做约束动画时，通常先改约束，再在动画 block 中对共同父视图调用 layoutIfNeeded。",
                mnemonic: "口诀：set 是预约，ifNeeded 是马上结账。",
                followUp: "追问：约束动画为什么常对父视图调用 layoutIfNeeded？因为约束求解发生在包含相关约束的最近公共父视图上，对正确层级调用才能刷新到位。",
                codeExample: """
                final class PanelController: UIViewController {
                    private let panel = UIView()
                    private var topConstraint: NSLayoutConstraint!

                    override func viewDidLoad() {
                        super.viewDidLoad()
                        panel.translatesAutoresizingMaskIntoConstraints = false
                        panel.backgroundColor = .systemBlue
                        view.addSubview(panel)

                        topConstraint = panel.topAnchor.constraint(
                            equalTo: view.safeAreaLayoutGuide.topAnchor,
                            constant: 240
                        )
                        NSLayoutConstraint.activate([
                            topConstraint,
                            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                            panel.heightAnchor.constraint(equalToConstant: 120)
                        ])
                    }

                    func expandPanel() {
                        topConstraint.constant = 80
                        UIView.animate(withDuration: 0.25) {
                            self.view.layoutIfNeeded()
                        }
                    }
                }
                """,
                projectScenario: "筛选面板展开、输入框上移、底部弹层动画，本质都是改约束常量后 layoutIfNeeded 让 AutoLayout 立刻计算新 frame。",
                summary: "一句话：layoutIfNeeded 用来把待处理的布局现在就算出来。"
            )
        ]
    }

    private func makeViewControllerLifecyclePoints() -> [ReviewPoint] {
        [
            ReviewPoint(
                id: "vc-loadView",
                title: "loadView",
                question: "loadView 什么时候调用？重写时要注意什么？",
                coreAnswer: "控制器的 view 第一次被访问且还没有创建时调用。纯代码页面可以重写 loadView 并直接给 self.view 赋值。完全自定义根视图时通常不需要调用 super.loadView()。",
                mnemonic: "口诀：loadView 造根视图。",
                followUp: "追问：loadView 和 viewDidLoad 的区别？loadView 负责创建 view；viewDidLoad 表示 view 已经创建完成，适合继续搭 UI 和绑定数据。",
                codeExample: """
                final class ProfileController: UIViewController {
                    override func loadView() {
                        let rootView = UIView()
                        rootView.backgroundColor = .systemBackground
                        view = rootView
                    }
                }
                """,
                projectScenario: "纯代码开发中，想用自定义 View 作为控制器根视图时重写 loadView；普通页面更多在 viewDidLoad 添加子视图。",
                summary: "一句话：loadView 是控制器 view 的创建入口。"
            ),
            ReviewPoint(
                id: "vc-viewDidLoad",
                title: "viewDidLoad",
                question: "viewDidLoad 适合做什么？会调用几次？",
                coreAnswer: "viewDidLoad 在 view 加载完成后调用，通常只调用一次。适合创建子视图、注册 cell、绑定 ViewModel、发起首屏数据请求；不要把每次显示都要刷新的逻辑只放这里。",
                mnemonic: "口诀：DidLoad 一次性搭台。",
                followUp: "追问：viewDidLoad 里 frame 一定准确吗？不一定，AutoLayout 还没完成最终布局，依赖尺寸的逻辑应放 viewDidLayoutSubviews 或布局回调。",
                codeExample: """
                final class ListController: UIViewController {
                    private let tableView = UITableView()

                    override func viewDidLoad() {
                        super.viewDidLoad()
                        view.backgroundColor = .systemBackground
                        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
                        view.addSubview(tableView)
                    }
                }
                """,
                projectScenario: "注册 tableView cell、添加导航按钮、设置静态 UI 都放 viewDidLoad；从详情页返回要刷新列表则放 viewWillAppear。",
                summary: "一句话：viewDidLoad 只负责页面第一次加载后的基础搭建。"
            ),
            ReviewPoint(
                id: "vc-viewWillAppear",
                title: "viewWillAppear",
                question: "viewWillAppear 的特点是什么？",
                coreAnswer: "页面即将显示时调用，每次 push 回来、tab 切换回来、modal dismiss 回来都可能触发。适合刷新可见数据、更新导航栏、状态栏、埋点预备。",
                mnemonic: "口诀：WillAppear 每次上场前准备。",
                followUp: "追问：为什么不要把一次性 UI 创建放 viewWillAppear？它会多次调用，重复 addSubview 或重复注册通知容易出 bug。",
                codeExample: """
                final class OrderListController: UIViewController {
                    override func viewWillAppear(_ animated: Bool) {
                        super.viewWillAppear(animated)
                        navigationController?.setNavigationBarHidden(false, animated: animated)
                        reloadVisibleOrders()
                    }

                    private func reloadVisibleOrders() {}
                }
                """,
                projectScenario: "订单列表从详情返回后需要刷新状态、用户资料页每次进入更新头像昵称，都适合放 viewWillAppear。",
                summary: "一句话：viewWillAppear 处理每次即将可见前的刷新和外观同步。"
            ),
            ReviewPoint(
                id: "vc-viewDidAppear",
                title: "viewDidAppear",
                question: "viewDidAppear 适合做什么？",
                coreAnswer: "页面已经完全显示并且转场动画结束后调用。适合启动动画、播放视频、开始相机、弹窗、曝光埋点、让输入框 becomeFirstResponder。",
                mnemonic: "口诀：DidAppear 已经站稳。",
                followUp: "追问：为什么有些弹窗要放 viewDidAppear？因为 viewDidLoad/viewWillAppear 时页面可能还没进入窗口层级，present 可能报警或体验不稳定。",
                codeExample: """
                final class SearchController: UIViewController {
                    private let textField = UITextField()

                    override func viewDidLoad() {
                        super.viewDidLoad()
                        textField.borderStyle = .roundedRect
                        textField.placeholder = "Search"
                        textField.frame = CGRect(x: 24, y: 120, width: 240, height: 40)
                        view.addSubview(textField)
                    }

                    override func viewDidAppear(_ animated: Bool) {
                        super.viewDidAppear(animated)
                        textField.becomeFirstResponder()
                    }
                }
                """,
                projectScenario: "新手引导弹窗、页面曝光、自动聚焦搜索框、进入页面后播放动画，都适合等 viewDidAppear 再启动。",
                summary: "一句话：viewDidAppear 表示页面真的可见了，可以开始和用户交互相关的动作。"
            ),
            ReviewPoint(
                id: "vc-viewWillDisappear",
                title: "viewWillDisappear",
                question: "viewWillDisappear 什么时候调用？",
                coreAnswer: "页面即将消失时调用，可能是 push、pop、dismiss、tab 切换或被覆盖。适合暂停动画、保存草稿、取消临时任务、恢复导航栏外观。",
                mnemonic: "口诀：WillDisappear 离场前收尾。",
                followUp: "追问：viewWillDisappear 调用是否代表控制器会释放？不代表。页面可能只是被 push 覆盖或切到别的 tab，真正释放要看 deinit。",
                codeExample: """
                final class EditorController: UIViewController {
                    override func viewWillDisappear(_ animated: Bool) {
                        super.viewWillDisappear(animated)
                        saveDraft()
                    }

                    private func saveDraft() {}
                }
                """,
                projectScenario: "编辑页离开前保存草稿，播放器页面离开前暂停，沉浸式页面离开前恢复导航栏，都放这里比较自然。",
                summary: "一句话：viewWillDisappear 是页面即将不可见前的暂停和保存点。"
            ),
            ReviewPoint(
                id: "vc-viewDidDisappear",
                title: "viewDidDisappear",
                question: "viewDidDisappear 和 viewWillDisappear 有什么区别？",
                coreAnswer: "viewDidDisappear 在页面完全消失后调用，转场动画已经结束。适合停止更重的资源，比如相机、定位、播放器、计时器；也可以结合 isMovingFromParent/isBeingDismissed 判断是否真正离开。",
                mnemonic: "口诀：DidDisappear 已经退场。",
                followUp: "追问：如何判断是 pop/dismiss 还是被覆盖？常用 isMovingFromParent、isBeingDismissed，导航栈场景还可检查 navigationController 的 viewControllers。",
                codeExample: """
                final class CameraController: UIViewController {
                    override func viewDidDisappear(_ animated: Bool) {
                        super.viewDidDisappear(animated)

                        if isMovingFromParent || isBeingDismissed {
                            stopCameraSession()
                        }
                    }

                    private func stopCameraSession() {}
                }
                """,
                projectScenario: "相机扫码页、地图页、播放器详情页消失后停止重资源，能减少后台耗电和页面间资源争抢。",
                summary: "一句话：viewDidDisappear 是页面已经不可见后的重资源清理点。"
            ),
            ReviewPoint(
                id: "vc-deinit",
                title: "deinit",
                question: "deinit 在生命周期里代表什么？",
                coreAnswer: "deinit 表示控制器对象真的释放了。适合移除通知、取消任务、invalidate 定时器、打印释放日志。它不是页面消失回调，viewDidDisappear 不等于 deinit。",
                mnemonic: "口诀：deinit 才是真释放。",
                followUp: "追问：页面 pop 后 deinit 不走怎么查？先看闭包强持有 self、Timer、Notification block、delegate strong、单例缓存和异步任务。",
                codeExample: """
                final class DetailController: UIViewController {
                    private var timer: Timer?

                    deinit {
                        timer?.invalidate()
                        NotificationCenter.default.removeObserver(self)
                        print("DetailController released")
                    }
                }
                """,
                projectScenario: "排查内存泄漏时先给控制器加 deinit 日志；如果 pop 后不打印，继续用 Memory Graph 找强引用链。",
                summary: "一句话：deinit 是对象释放证明，不是普通页面消失事件。"
            )
        ]
    }

    private func makeAutoLayoutPoints() -> [ReviewPoint] {
        [
            ReviewPoint(
                id: "autolayout-engine",
                title: "约束计算原理",
                question: "AutoLayout 的约束计算原理是什么？",
                coreAnswer: "AutoLayout 把约束转换成线性方程和优先级，布局引擎求解出每个 view 的 frame。大致流程是更新约束、计算布局、再显示；约束是规则，frame 是最终结果。",
                mnemonic: "口诀：约束是方程，frame 是答案。",
                followUp: "追问：为什么约束太多会影响性能？因为求解方程和更新布局有成本，复杂层级和频繁改约束会增加主线程压力。",
                codeExample: """
                final class ConstraintDemoController: UIViewController {
                    private let titleLabel = UILabel()

                    override func viewDidLoad() {
                        super.viewDidLoad()
                        titleLabel.text = "AutoLayout"
                        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                        view.addSubview(titleLabel)

                        NSLayoutConstraint.activate([
                            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
                        ])
                    }
                }
                """,
                projectScenario: "复杂列表 cell 不要在复用时反复创建约束；初始化时建好约束，滚动中只更新文本、图片和必要的 constraint constant。",
                summary: "一句话：AutoLayout 是用约束规则算出最终 frame。"
            ),
            ReviewPoint(
                id: "autolayout-intrinsicContentSize",
                title: "intrinsicContentSize",
                question: "intrinsicContentSize 是什么？",
                coreAnswer: "它是 view 自己的固有内容尺寸，比如 UILabel 根据文字给出自然大小，UIButton 根据标题和内边距给出大小。自定义 view 可以重写它，内容变化后调用 invalidateIntrinsicContentSize。",
                mnemonic: "口诀：固有尺寸就是“我自己想多大”。",
                followUp: "追问：有 intrinsicContentSize 还要不要约束？要。它只能提供自然宽高，位置和必要的限制仍然靠约束决定。",
                codeExample: """
                final class TagView: UIView {
                    var text = "" {
                        didSet { invalidateIntrinsicContentSize() }
                    }

                    override var intrinsicContentSize: CGSize {
                        CGSize(width: text.count * 12 + 24, height: 32)
                    }
                }
                """,
                projectScenario: "标签、徽章、自适应按钮都依赖固有尺寸；文案变化后要让系统知道尺寸失效，避免布局不更新。",
                summary: "一句话：intrinsicContentSize 是控件基于内容给 AutoLayout 的自然尺寸建议。"
            ),
            ReviewPoint(
                id: "autolayout-hugging",
                title: "hugging",
                question: "Content Hugging Priority 怎么理解？",
                coreAnswer: "hugging 表示控件抗拒被拉大的能力。优先级越高，越想保持 intrinsicContentSize；优先级低的控件更容易被拉伸填充多余空间。",
                mnemonic: "口诀：hugging 高，不想长胖。",
                followUp: "追问：两个 label 横排，多余空间给谁？通常给 hugging 更低的那个，因为它更愿意被拉伸。",
                codeExample: """
                func setupHugging(titleLabel: UILabel, subtitleLabel: UILabel) {
                    titleLabel.setContentHuggingPriority(.required, for: .horizontal)
                    subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                }
                """,
                projectScenario: "表单行里左侧标题固定、右侧内容自适应时，常提高标题 hugging，让右侧控件吃掉多余空间。",
                summary: "一句话：hugging 决定谁更不愿意被撑大。"
            ),
            ReviewPoint(
                id: "autolayout-compression",
                title: "compression resistance",
                question: "Compression Resistance Priority 怎么理解？",
                coreAnswer: "compression resistance 表示控件抗拒被压小的能力。优先级越高，越不容易被压缩；优先级低的控件在空间不够时更先变窄、截断或换行。",
                mnemonic: "口诀：compression 高，不想变瘦。",
                followUp: "追问：标题和时间同排，空间不够时让谁截断？通常提高时间的 compression，让标题承担截断或换行。",
                codeExample: """
                func setupCompression(titleLabel: UILabel, timeLabel: UILabel) {
                    timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                    titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                    titleLabel.lineBreakMode = .byTruncatingTail
                }
                """,
                projectScenario: "消息列表中时间、价格、状态标签通常不能被压没；长标题、描述文案可以降低 compression 优先级。",
                summary: "一句话：compression resistance 决定空间不够时谁先被压缩。"
            ),
            ReviewPoint(
                id: "autolayout-frame-vs-constraint",
                title: "frame 和 constraint 区别",
                question: "frame 和 constraint 的区别是什么？",
                coreAnswer: "constraint 是布局规则，frame 是规则计算后的结果。使用 AutoLayout 时，不应该长期手动改 frame；要改位置或大小，优先改约束常量，再 layoutIfNeeded。",
                mnemonic: "口诀：约束定规则，frame 看结果。",
                followUp: "追问：为什么手动 set frame 后又变回去了？因为下一次 AutoLayout 布局会重新按约束计算 frame，覆盖手动设置。",
                codeExample: """
                final class SheetController: UIViewController {
                    private let sheetView = UIView()
                    private var bottomConstraint: NSLayoutConstraint!

                    override func viewDidLoad() {
                        super.viewDidLoad()
                        sheetView.translatesAutoresizingMaskIntoConstraints = false
                        sheetView.backgroundColor = .systemGray6
                        view.addSubview(sheetView)

                        bottomConstraint = sheetView.bottomAnchor.constraint(
                            equalTo: view.bottomAnchor,
                            constant: 240
                        )
                        NSLayoutConstraint.activate([
                            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                            sheetView.heightAnchor.constraint(equalToConstant: 240),
                            bottomConstraint
                        ])
                    }

                    func showSheet() {
                        bottomConstraint.constant = 0
                        UIView.animate(withDuration: 0.25) {
                            self.view.layoutIfNeeded()
                        }
                    }
                }
                """,
                projectScenario: "弹窗、键盘避让、展开收起都建议改约束而不是直接改 frame，避免 AutoLayout 下一轮布局把手动 frame 覆盖。",
                summary: "一句话：AutoLayout 页面里，改约束才是改布局的稳定方式。"
            ),
            ReviewPoint(
                id: "autolayout-conflict",
                title: "约束冲突原因",
                question: "常见约束冲突原因有哪些？",
                coreAnswer: "约束冲突就是布局方程无解。常见原因：同时给了互相矛盾的宽高/边距、缺少必要约束、重复约束、translatesAutoresizingMaskIntoConstraints 没关、优先级都设成 required。",
                mnemonic: "口诀：冲突就是方程打架。",
                followUp: "追问：怎么排查？看控制台 Unable to simultaneously satisfy constraints，给关键约束加 identifier，用 Debug View Hierarchy 找冲突视图。",
                codeExample: """
                func addFlexibleWidth(to button: UIButton) {
                    let width = button.widthAnchor.constraint(equalToConstant: 120)
                    width.identifier = "LoginButton.width"
                    width.priority = .defaultHigh
                    width.isActive = true
                }
                """,
                projectScenario: "多语言、动态字体、接口文案变长时最容易暴露冲突；关键按钮、价格、标签要用优先级和可压缩策略兜底。",
                summary: "一句话：约束冲突的本质是系统无法同时满足所有 required 规则。"
            )
        ]
    }

    private func makeResponderChainPoints() -> [ReviewPoint] {
        [
            ReviewPoint(
                id: "responder-hitTest",
                title: "hitTest",
                question: "hitTest 的作用是什么？",
                coreAnswer: "hitTest 用来从 UIWindow 开始寻找真正接收触摸的最深层 view。系统会先判断 hidden、alpha、isUserInteractionEnabled，再调用 point(inside:with:)，然后从后往前遍历子视图。",
                mnemonic: "口诀：hitTest 找最终接球人。",
                followUp: "追问：为什么后添加的子视图优先响应？因为遍历 subviews 时通常从数组末尾开始，越靠后的视图视觉层级越靠上。",
                codeExample: """
                final class PassThroughView: UIView {
                    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
                        let target = super.hitTest(point, with: event)
                        return target == self ? nil : target
                    }
                }
                """,
                projectScenario: "浮层只想让按钮可点、空白区域透传给下面列表时，可以重写 hitTest 做事件透传。",
                summary: "一句话：hitTest 决定本次触摸最终落到哪个 view 上。"
            ),
            ReviewPoint(
                id: "responder-pointInside",
                title: "pointInside",
                question: "pointInside 和 hitTest 有什么关系？",
                coreAnswer: "pointInside 判断触摸点是否在当前 view 的可响应区域内，hitTest 会先用它过滤。重写 pointInside 可以扩大或缩小点击区域，但不改变 view 的视觉大小。",
                mnemonic: "口诀：pointInside 判断进没进门。",
                followUp: "追问：如何扩大 UIButton 点击热区？可以在按钮或父视图里重写 point(inside:with:)，用 bounds.insetBy(dx: -10, dy: -10) 扩大区域。",
                codeExample: """
                final class LargeTapButton: UIButton {
                    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
                        let hitFrame = bounds.insetBy(dx: -12, dy: -12)
                        return hitFrame.contains(point)
                    }
                }
                """,
                projectScenario: "导航栏小图标、关闭按钮、复选框视觉很小时，常扩大点击热区提升可用性。",
                summary: "一句话：pointInside 定义当前 view 的有效点击范围。"
            ),
            ReviewPoint(
                id: "responder-firstResponder",
                title: "firstResponder",
                question: "firstResponder 是什么？",
                coreAnswer: "firstResponder 是当前最先接收键盘、菜单、motion、action 等事件的对象。UITextField 成为第一响应者会弹键盘；自定义对象要返回 canBecomeFirstResponder 为 true。",
                mnemonic: "口诀：firstResponder 是当前焦点。",
                followUp: "追问：为什么 becomeFirstResponder 没效果？可能控件还没进 window、canBecomeFirstResponder 为 false，或者时机太早。",
                codeExample: """
                final class ShortcutView: UIView {
                    override var canBecomeFirstResponder: Bool { true }

                    override func didMoveToWindow() {
                        super.didMoveToWindow()
                        becomeFirstResponder()
                    }
                }
                """,
                projectScenario: "搜索页自动弹键盘、输入框焦点管理、键盘快捷键响应，都要理解 firstResponder。",
                summary: "一句话：firstResponder 表示当前事件焦点在谁身上。"
            ),
            ReviewPoint(
                id: "responder-event-flow",
                title: "事件传递流程",
                question: "iOS 触摸事件传递流程怎么讲？",
                coreAnswer: "触摸事件先到 UIApplication，再到 UIWindow；Window 通过 hitTest 找到目标 view。事件先给手势识别器和目标 view 处理，未处理的 action 可以沿 responder chain 向上找下一个 responder。",
                mnemonic: "口诀：App 到 Window，hitTest 找 view，处理不了往上走。",
                followUp: "追问：响应链往上通常是谁？UIView 的 next 通常是 superview；UIViewController 的根 view next 是 controller；再往上可能是 window、application。",
                codeExample: """
                final class ActionController: UIViewController {
                    @objc func saveAction() {
                        print("save")
                    }

                    func triggerSaveFromAnySubview() {
                        UIApplication.shared.sendAction(
                            #selector(saveAction),
                            to: nil,
                            from: self,
                            for: nil
                        )
                    }
                }
                """,
                projectScenario: "菜单命令、键盘快捷键、复杂容器里子视图不直接持有控制器时，可以利用 responder chain 传递 action。",
                summary: "一句话：触摸先定位目标 view，处理不了的动作再沿响应链向上找。"
            ),
            ReviewPoint(
                id: "responder-uibutton-flow",
                title: "UIButton 点击事件传递过程",
                question: "UIButton 点击从触摸到回调发生了什么？",
                coreAnswer: "用户按下后，Window 通过 hitTest 找到 UIButton。UIButton 作为 UIControl 开始 tracking，手指在按钮内抬起时触发 touchUpInside，然后通过 target-action 调用绑定方法。",
                mnemonic: "口诀：hitTest 找按钮，UIControl 发 action。",
                followUp: "追问：为什么按钮点了没反应？常见原因是按钮或父视图 userInteractionEnabled 为 false、被透明视图盖住、超出父视图 bounds、没绑定 target-action、isEnabled 为 false。",
                codeExample: """
                final class LoginController: UIViewController {
                    private let button = UIButton(type: .system)

                    override func viewDidLoad() {
                        super.viewDidLoad()
                        button.addTarget(self, action: #selector(login), for: .touchUpInside)
                    }

                    @objc private func login() {
                        print("login tapped")
                    }
                }
                """,
                projectScenario: "排查按钮失效时，先看是否被遮挡和交互开关，再看 hitTest 目标和 target-action 是否正确。",
                summary: "一句话：UIButton 先通过命中测试拿到触摸，再由 UIControl 触发 target-action。"
            )
        ]
    }

    private func makeGestureConflictPoints() -> [ReviewPoint] {
        [
            ReviewPoint(
                id: "gesture-delegate",
                title: "UIGestureRecognizerDelegate",
                question: "UIGestureRecognizerDelegate 能解决什么问题？",
                coreAnswer: "它用来决定手势能不能开始、是否接收某次 touch、是否允许同时识别、是否要求另一个手势失败。面试重点是用 delegate 做方向判断、区域过滤和冲突协调。",
                mnemonic: "口诀：delegate 是手势交通警察。",
                followUp: "追问：shouldBegin 常用来干什么？常用来按滑动方向、页面状态、起点位置决定这个手势本次要不要开始。",
                codeExample: """
                final class CardController: UIViewController, UIGestureRecognizerDelegate {
                    private let panGesture = UIPanGestureRecognizer()

                    override func viewDidLoad() {
                        super.viewDidLoad()
                        panGesture.delegate = self
                        view.addGestureRecognizer(panGesture)
                    }

                    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
                        let velocity = panGesture.velocity(in: view)
                        return abs(velocity.x) > abs(velocity.y)
                    }
                }
                """,
                projectScenario: "卡片横滑、抽屉侧滑、图片浏览器下拉关闭，都需要在 shouldBegin 里判断方向，避免和列表纵向滚动抢事件。",
                summary: "一句话：UIGestureRecognizerDelegate 用来决定手势是否开始以及如何共存。"
            ),
            ReviewPoint(
                id: "gesture-simultaneous",
                title: "simultaneousRecognition",
                question: "shouldRecognizeSimultaneouslyWith 怎么用？",
                coreAnswer: "返回 true 表示两个手势可以同时识别。它适合确实需要共存的场景，比如缩放和拖动、外层容器手势和内层滚动手势协作；不能无脑返回 true。",
                mnemonic: "口诀：同时识别，只给能共存的手势。",
                followUp: "追问：为什么不能全部返回 true？会让互斥手势同时触发，导致页面状态混乱，比如侧滑返回和横滑删除同时响应。",
                codeExample: """
                final class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {
                    func gestureRecognizer(
                        _ gestureRecognizer: UIGestureRecognizer,
                        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
                    ) -> Bool {
                        let isPan = gestureRecognizer is UIPanGestureRecognizer
                            || otherGestureRecognizer is UIPanGestureRecognizer
                        let isPinch = gestureRecognizer is UIPinchGestureRecognizer
                            || otherGestureRecognizer is UIPinchGestureRecognizer
                        return isPan && isPinch
                    }
                }
                """,
                projectScenario: "图片编辑器里用户一边双指缩放一边移动画布，就需要允许 pan 和 pinch 同时识别。",
                summary: "一句话：simultaneousRecognition 是允许两个手势一起成功的开关。"
            ),
            ReviewPoint(
                id: "gesture-require-fail",
                title: "requireGestureRecognizerToFail",
                question: "requireGestureRecognizerToFail 的作用是什么？",
                coreAnswer: "它让一个手势必须等待另一个手势失败后才能成功。常用于单击和双击、轻扫和拖动等有优先级的冲突场景。",
                mnemonic: "口诀：谁优先，谁被等待。",
                followUp: "追问：单击和双击为什么要加失败依赖？不加的话第一次点击可能先触发单击，导致双击还没判断完单击就执行了。",
                codeExample: """
                final class PhotoController: UIViewController {
                    override func viewDidLoad() {
                        super.viewDidLoad()
                        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
                        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
                        doubleTap.numberOfTapsRequired = 2

                        singleTap.require(toFail: doubleTap)
                        view.addGestureRecognizer(singleTap)
                        view.addGestureRecognizer(doubleTap)
                    }

                    @objc private func handleSingleTap() {}
                    @objc private func handleDoubleTap() {}
                }
                """,
                projectScenario: "图片浏览页单击隐藏工具栏、双击放大图片时，必须让单击等待双击失败，否则两个动作容易一起触发。",
                summary: "一句话：requireGestureRecognizerToFail 用来表达手势优先级。"
            ),
            ReviewPoint(
                id: "gesture-table-pop",
                title: "UITableView 和侧滑返回冲突",
                question: "UITableView 和侧滑返回冲突怎么处理？",
                coreAnswer: "先判断冲突来源：系统边缘返回、全屏返回、cell 侧滑、横向滚动。常用做法是在 delegate 里按起点、方向、导航栈数量和 contentOffset 决定是否开始，必要时允许安全的同时识别。",
                mnemonic: "口诀：边缘给返回，内容给列表。",
                followUp: "追问：为什么不要直接禁用 interactivePopGestureRecognizer？会破坏系统返回体验。更好的做法是按场景过滤手势开始条件。",
                codeExample: """
                final class MessageListController: UITableViewController, UIGestureRecognizerDelegate {
                    override func viewDidLoad() {
                        super.viewDidLoad()
                        navigationController?.interactivePopGestureRecognizer?.delegate = self
                    }

                    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
                        guard gestureRecognizer == navigationController?.interactivePopGestureRecognizer,
                              let pan = gestureRecognizer as? UIPanGestureRecognizer else {
                            return true
                        }

                        let canPop = (navigationController?.viewControllers.count ?? 0) > 1
                        let translation = pan.translation(in: view)
                        return canPop && translation.x > abs(translation.y)
                    }

                    func gestureRecognizer(
                        _ gestureRecognizer: UIGestureRecognizer,
                        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
                    ) -> Bool {
                        gestureRecognizer == navigationController?.interactivePopGestureRecognizer
                            && otherGestureRecognizer == tableView.panGestureRecognizer
                    }
                }
                """,
                projectScenario: "聊天页、订单页、设置页如果有 cell 侧滑操作或横向内容，侧滑返回要按边缘、方向和当前滚动位置精细判断，避免误返回或误触发删除。",
                summary: "一句话：列表和返回手势冲突时，用 delegate 按方向和区域分配手势归属。"
            )
        ]
    }
}

extension UIKitInterviewReviewViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionModel = sections[section]
        return expandedSectionIDs.contains(sectionModel.id) ? sectionModel.points.count : 0
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: pointCellReuseIdentifier,
            for: indexPath
        ) as? UIKitReviewPointCell ?? UIKitReviewPointCell(
            style: .default,
            reuseIdentifier: pointCellReuseIdentifier
        )

        let section = sections[indexPath.section]
        let point = section.points[indexPath.row]
        cell.configure(
            index: indexPath.row + 1,
            point: point,
            rows: RowKind.allCases,
            tintColor: section.tintColor
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: categoryHeaderReuseIdentifier
        ) as? UIKitReviewCategoryHeaderView ?? UIKitReviewCategoryHeaderView(
            reuseIdentifier: categoryHeaderReuseIdentifier
        )

        let model = sections[section]
        headerView.configure(
            index: section + 1,
            title: model.title,
            subtitle: model.subtitle,
            count: model.points.count,
            symbolName: model.symbolName,
            tintColor: model.tintColor,
            isExpanded: expandedSectionIDs.contains(model.id)
        )
        headerView.onTap = { [weak self] in
            self?.toggleSection(section)
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForHeaderInSection section: Int
    ) -> CGFloat {
        82
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private final class UIKitReviewCategoryHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIKitInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = UIKitInterviewStyle.titleTextColor
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
        label.textColor = UIKitInterviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIKitInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: UIKitPaddingLabel = {
        let label = UIKitPaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = UIKitInterviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIKitInterviewStyle.secondaryTextColor
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
        iconView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        countLabel.text = nil
        chevronView.image = nil
    }

    private func setupViews() {
        contentView.backgroundColor = UIKitInterviewStyle.backgroundColor
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
        title: String,
        subtitle: String,
        count: Int,
        symbolName: String,
        tintColor: UIColor,
        isExpanded: Bool
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = tintColor.withAlphaComponent(0.28)
        iconView.image = UIImage(systemName: symbolName)
        iconView.tintColor = tintColor
        titleLabel.text = title
        subtitleLabel.text = subtitle
        countLabel.text = "\(count) 题"
        chevronView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        containerView.layer.borderColor = tintColor.withAlphaComponent(isExpanded ? 0.55 : 0.18).cgColor
        containerView.layer.borderWidth = 1
    }

    @objc private func didTapHeader() {
        onTap?()
    }
}

private final class UIKitReviewPointCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIKitInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UIKitPaddingLabel = {
        let label = UIKitPaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = UIKitInterviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIKitInterviewStyle.titleTextColor
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
        selectedBackgroundView?.backgroundColor = UIKitInterviewStyle.selectionColor
        contentView.backgroundColor = .clear
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
        point: UIKitInterviewReviewViewController.ReviewPoint,
        rows: [UIKitInterviewReviewViewController.RowKind],
        tintColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = tintColor.withAlphaComponent(0.26)
        titleLabel.text = point.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = tintColor.withAlphaComponent(0.20).cgColor

        rows.forEach { row in
            let fieldView = UIKitReviewFieldView()
            fieldView.configure(
                title: row.title,
                body: row.text(for: point),
                symbolName: row.symbolName,
                tintColor: tintColor,
                isMemoryLine: row == .summary,
                isCode: row == .codeExample
            )
            contentStackView.addArrangedSubview(fieldView)
        }
    }
}

private final class UIKitReviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIKitInterviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIKitInterviewStyle.bodyTextColor
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
        backgroundColor = UIKitInterviewStyle.fieldBackgroundColor
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
        isMemoryLine: Bool,
        isCode: Bool
    ) {
        iconView.image = UIImage(systemName: symbolName)
        iconView.tintColor = tintColor
        titleLabel.text = title
        titleLabel.textColor = isMemoryLine ? tintColor : UIKitInterviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = isCode
            ? .monospacedSystemFont(ofSize: 12, weight: .regular)
            : .systemFont(ofSize: isMemoryLine ? 15 : 14, weight: isMemoryLine ? .semibold : .regular)
        bodyLabel.textColor = isMemoryLine ? UIKitInterviewStyle.titleTextColor : UIKitInterviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : UIKitInterviewStyle.fieldBackgroundColor
    }
}

private final class UIKitPaddingLabel: UILabel {

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
