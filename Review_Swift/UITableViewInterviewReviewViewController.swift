//
//  UITableViewInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/18.
//

import UIKit

private enum UITableViewInterviewStyle {

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

final class UITableViewInterviewReviewViewController: UITableViewController {

    fileprivate struct InterviewQuestion {

        let title: String
        let question: String
        let standardAnswer: String
        let principle: String
        let followUp: String
        let optimization: String
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

    // 每个 section 对应一道 UITableView 高频面试题
    private struct InterviewPoint {

        let question: String
        let standardAnswer: String
        let principle: String
        let followUp: String
        let optimization: String
        let memory: String
    }

    fileprivate enum ReviewRowKind: Int, CaseIterable {

        case question
        case standardAnswer
        case principle
        case followUp
        case optimization
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
            case .optimization:
                return "实际项目优化"
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
                return "gearshape.2.fill"
            case .followUp:
                return "bubble.left.and.bubble.right.fill"
            case .optimization:
                return "speedometer"
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
            case .optimization:
                return question.optimization
            case .memory:
                return question.memoryLine
            }
        }
    }

    private let cellReuseIdentifier = "UITableViewInterviewCell"
    private let headerReuseIdentifier = "UITableViewInterviewHeaderView"

    private lazy var sections: [InterviewSection] = makeSections()
    private var expandedSectionIDs: Set<String> = []

    private let points: [InterviewPoint] = [
        InterviewPoint(
            question: "UITableView cell 复用机制是什么？",
            standardAnswer: "UITableView 不会为所有数据一次性创建 cell，而是只创建屏幕上可见和少量即将出现的 cell。cell 滑出屏幕后会进入复用池，新的 IndexPath 需要展示时再从复用池取出来重新配置。",
            principle: "UITableView 通过 reuseIdentifier 维护不同类型的复用池。滚动过程中，旧 cell 从视图层级移除后等待复用，新 cell 绑定新的数据模型再显示，所以核心是“少量 cell + 多次配置”。",
            followUp: "追问：复用会不会导致数据错乱？答：复用本身不会错乱，错乱通常是旧状态、旧图片请求、旧异步回调没有清理。",
            optimization: "项目里要给不同样式的 cell 使用不同 reuseIdentifier，cellForRowAt 只做轻量绑定，复杂计算提前放到 ViewModel 或缓存里。",
            memory: "UITableView 性能第一句：cell 不是无限创建，而是滑出屏幕后进复用池。"
        ),
        InterviewPoint(
            question: "prepareForReuse 什么时候调用？应该做什么？",
            standardAnswer: "prepareForReuse 会在一个复用 cell 即将被重新拿来显示前调用。它适合重置与旧数据有关的 UI 状态，比如图片、选中状态、隐藏状态、进度、文本颜色和取消旧异步任务。",
            principle: "复用 cell 的对象没变，只是承载的数据变了。如果旧状态没有恢复到默认值，新数据配置又没有覆盖完整，就会把上一个 IndexPath 的状态带到下一个 IndexPath。",
            followUp: "追问：prepareForReuse 里要不要清空所有文本？答：可以清旧图和状态，但最终仍要在 configure 方法里完整赋值，不能只依赖 prepareForReuse。",
            optimization: "网络图片 cell 要在 prepareForReuse 里取消旧请求或校验 token，并把 imageView.image 设为占位图，避免滑动时闪旧图。",
            memory: "prepareForReuse 只记一句：清旧状态，取消旧任务，configure 再完整赋新值。"
        ),
        InterviewPoint(
            question: "dequeueReusableCell 的底层原理是什么？",
            standardAnswer: "dequeueReusableCell 会先根据 reuseIdentifier 去复用池查找可用 cell；如果有就返回，没有就根据注册的 class 或 nib 创建新 cell。带 for indexPath 的方法能保证一定返回非空 cell。",
            principle: "它的核心不是“重新生成 UI”，而是对象复用。UITableView 根据 cell 的标识把可复用对象分类管理，滚动时重复执行数据绑定，减少对象创建和销毁。",
            followUp: "追问：为什么必须 register？答：注册后系统知道没拿到复用 cell 时应该创建哪种类型，避免手动判空创建。",
            optimization: "真实项目中建议统一封装 register/dequeue，避免 reuseIdentifier 写错；复杂页面可按 cell 类型拆分，减少 cell 内部 if-else。",
            memory: "dequeue = 先找复用池，没有就按注册信息创建。"
        ),
        InterviewPoint(
            question: "为什么 cell 复用能优化性能？",
            standardAnswer: "因为它减少了 cell 对象、子视图、Auto Layout 约束和图层的重复创建成本，也降低内存占用。屏幕上只需要十几个 cell，就能展示几千条数据。",
            principle: "创建 UIView、UILabel、UIImageView、CALayer 和约束都需要时间和内存。复用把这些成本从“每条数据一次”变成“少量可见 cell 一次”。",
            followUp: "追问：复用是不是越多越好？答：复用是基础优化，但真正流畅还要配合高度缓存、图片解码、异步加载和减少主线程计算。",
            optimization: "cell 初始化时创建固定子视图，滚动时只更新内容；不要在 cellForRowAt 里反复 addSubview、创建约束、同步读大图。",
            memory: "复用优化的是创建成本、内存成本和图层成本。"
        ),
        InterviewPoint(
            question: "UITableView cell 错乱问题怎么解决？",
            standardAnswer: "先保证 cell 配置完整，再处理异步回调。每次 configure 都要覆盖文本、图片、隐藏、颜色、选中等状态；图片异步加载完成后要校验当前 cell 是否仍然对应同一个数据。",
            principle: "错乱的根因是 cell 对象被复用后，旧任务晚回来或旧状态没清掉。也就是数据和当前 IndexPath 不再匹配，但 UI 还被旧回调更新了。",
            followUp: "追问：为什么快速滑动更容易错图？答：快速滑动会让同一个 cell 短时间绑定多个模型，旧图片请求如果不取消或不校验，就会覆盖新内容。",
            optimization: "用 URL、modelID 或 requestID 做回调校验；prepareForReuse 取消请求；图片组件负责缓存、取消和占位；configure 方法保证所有状态都有默认值。",
            memory: "错乱三板斧：完整赋值、取消旧任务、回调校验身份。"
        ),
        InterviewPoint(
            question: "reloadData 会发生什么？",
            standardAnswer: "reloadData 会让 UITableView 重新向 dataSource 查询 section 和 row 数量，并重新加载可见区域的 cell，同时触发布局和高度计算。它不会自动带行级动画。",
            principle: "reloadData 本质是整表刷新。旧的可见 cell 可能进入复用池，表格重新走 numberOfSections、numberOfRows、cellForRowAt、heightForRowAt 或自动高度布局流程。",
            followUp: "追问：reloadData 后马上取 cell 一定有值吗？答：不一定，因为布局刷新可能要等下一个 run loop，可以先 layoutIfNeeded 或在主队列下一次取。",
            optimization: "数据变化范围明确时优先用 insert/delete/reloadRows 或 diffable data source，减少整表重算和重绘。",
            memory: "reloadData = 重新问数据源 + 刷新可见 cell + 重新布局。"
        ),
        InterviewPoint(
            question: "reloadData 为什么可能卡顿？",
            standardAnswer: "因为它可能在主线程触发大量 cell 配置、高度计算、Auto Layout 布局、图片解码和文本排版。如果数据多、cell 复杂、同步任务重，就会阻塞滑动。",
            principle: "UITableView 的 UI 更新必须在主线程完成。reloadData 会集中触发可见 cell 重新创建或配置，复杂布局和动态高度会把多个耗时点叠在同一帧里。",
            followUp: "追问：是不是数据越多 reloadData 越卡？答：不完全是，真正卡的是可见 cell 配置、高度计算、布局和主线程任务；但数据多会增加 diff、排序和状态同步成本。",
            optimization: "拆成局部刷新；提前计算高度；图片后台解码；减少约束层级；避免 cellForRowAt 同步读文件、算富文本、转图片。",
            memory: "reloadData 卡顿不是因为方法名重，而是主线程活太多。"
        ),
        InterviewPoint(
            question: "reloadRows 和 reloadSections 有什么区别？",
            standardAnswer: "reloadRows 只刷新指定 IndexPath 的行，reloadSections 刷新指定 section 内的所有行和 header/footer。更新范围越小，影响越小。",
            principle: "两者都会让对应范围内的 cell 重新配置和布局。reloadSections 的范围更大，可能影响 section header、footer、行数和动画；reloadRows 更适合单个状态变化。",
            followUp: "追问：什么时候不用 reloadRows？答：如果数据源行数发生变化，要配合 insert/delete/move，或者使用 performBatchUpdates 保证数据源和 UI 一致。",
            optimization: "点赞、开关、下载进度这类单行变化用 reloadRows；折叠展开一组内容用 reloadSections；大批变化用 batch update 或 diffable。",
            memory: "单行变用 reloadRows，一组变用 reloadSections，结构变用批量更新。"
        ),
        InterviewPoint(
            question: "UITableView 高度缓存怎么做？",
            standardAnswer: "高度缓存就是把已经算过的 cell 高度按 modelID 或 indexPath 存起来，下次直接返回，避免重复 Auto Layout 计算或文本测量。",
            principle: "动态高度通常要计算文字排版、图片比例、约束布局。滚动时如果反复计算，会增加主线程压力。缓存可以把重复计算变成一次计算多次读取。",
            followUp: "追问：高度缓存用 indexPath 还是 modelID？答：列表会插入、删除、排序时优先用稳定 modelID；静态列表可以用 indexPath。",
            optimization: "缓存 key 用稳定业务 ID；内容变化时清除对应缓存；预计算文本高度；尽量让 cell 结构固定，减少自动布局求解成本。",
            memory: "高度缓存 = 算一次，滚动反复用；数据变了再清。"
        ),
        InterviewPoint(
            question: "estimatedRowHeight 的原理是什么？",
            standardAnswer: "estimatedRowHeight 是估算高度。UITableView 先用估算值快速计算 contentSize 和滚动条位置，真正显示到某一行时再计算真实高度。",
            principle: "没有估算高度时，表格可能需要提前计算大量行高才能确定内容尺寸。估算值让系统先用近似高度占位，按需计算真实高度，提高初始加载速度。",
            followUp: "追问：估算不准会怎样？答：滚动条可能跳动，contentSize 会不断修正，严重时会出现滑动手感不稳。",
            optimization: "给一个接近真实平均值的 estimatedRowHeight；高度差异特别大的列表可做高度缓存；固定高度直接设置 rowHeight。",
            memory: "estimatedRowHeight = 先估算撑起列表，显示时再算真实高度。"
        ),
        InterviewPoint(
            question: "UITableView 卡顿优化方案有哪些？",
            standardAnswer: "核心是减少主线程工作：cell 轻量化、减少层级、缓存高度、异步加载图片、后台解码、局部刷新、预加载数据，避免滑动中做同步耗时操作。",
            principle: "屏幕 60Hz 下每帧约 16.67ms，120Hz 下每帧约 8.33ms。主线程如果在一帧内做不完布局、绘制和数据处理，就会掉帧。",
            followUp: "追问：你项目里怎么做？答：先用 Instruments 找主线程耗时，再针对图片、布局、高度、网络回调和刷新范围逐个处理。",
            optimization: "具体做法：ViewModel 提前整理展示数据；cellForRowAt 不做复杂计算；图片缩放解码放后台；高度缓存；预取下一页；滚动时延后低优先级任务。",
            memory: "卡顿优化先抓主线程，再看图片、布局、高度、刷新范围。"
        ),
        InterviewPoint(
            question: "UITableView 里什么是异步绘制？",
            standardAnswer: "异步绘制是把文字、图片、圆角等绘制工作放到后台线程生成位图，主线程只负责把最终图片或 layer 内容显示出来。",
            principle: "UIKit 大部分 UI 操作必须在主线程，但 Core Graphics 绘制位图可以在后台做。复杂富文本、头像圆角、气泡背景等适合提前绘制成图片。",
            followUp: "追问：所有 cell 都要异步绘制吗？答：不用。普通列表优先优化布局和图片，只有复杂绘制或富文本场景才考虑异步绘制。",
            optimization: "复杂图文流可以用 TextKit/CoreText 预排版，后台绘制缓存结果；复用时校验绘制任务是否仍属于当前 model，避免错乱。",
            memory: "异步绘制 = 后台画好一张图，主线程只负责贴上去。"
        ),
        InterviewPoint(
            question: "离屏渲染是什么？UITableView 为什么要关注？",
            standardAnswer: "离屏渲染是 GPU 不能直接把内容画到当前屏幕缓冲区，需要先开一个离屏缓冲区处理，再合成到屏幕。大量离屏渲染会增加 GPU 开销，导致滑动掉帧。",
            principle: "常见触发点包括 masksToBounds + cornerRadius、阴影 shadow、group opacity、mask、shouldRasterize 等。cell 多且快速滚动时，这些开销会被放大。",
            followUp: "追问：圆角一定会离屏吗？答：不一定，系统版本和实现有关，但头像圆角、大图圆角、阴影叠加一直是列表优化重点。",
            optimization: "头像圆角可用预裁剪图片；阴影用 shadowPath；避免 cell 大面积 mask；必要时用 Instruments 的 Core Animation 检查 Color Offscreen-Rendered。",
            memory: "离屏渲染记住：圆角裁剪、阴影、mask 多了，滑动就容易掉帧。"
        ),
        InterviewPoint(
            question: "UITableView 图片加载怎么优化？",
            standardAnswer: "图片加载要做缓存、取消、占位、后台解码和尺寸裁剪。cell 复用时取消旧请求，回调时校验 modelID，避免错图。",
            principle: "网络下载、磁盘读取、图片解码、缩放都会耗时。尤其图片第一次显示时如果在主线程解码，滑动会明显卡顿。",
            followUp: "追问：为什么图片要按显示尺寸裁剪？答：原图太大会占内存，也会增加解码和渲染成本，列表只需要展示尺寸对应的缩略图。",
            optimization: "使用内存+磁盘缓存；按屏幕 scale 生成缩略图；后台解码；滑动很快时降低请求优先级；预取下一屏图片。",
            memory: "图片优化五个字：缓存、取消、解码、裁剪、校验。"
        ),
        InterviewPoint(
            question: "RunLoop 与 UITableView 滑动优化有什么关系？",
            standardAnswer: "滑动时主线程 RunLoop 会进入 UITrackingRunLoopMode，优先处理触摸和滚动事件。可以把不紧急任务延后到默认模式或空闲时执行，减少滑动期间的主线程压力。",
            principle: "RunLoop 按 mode 处理事件。滚动中如果定时器、图片回调、布局刷新等任务抢占主线程，就可能影响手势和绘制。合理安排任务时机能提升滑动流畅度。",
            followUp: "追问：Timer 为什么滑动时可能不执行？答：Timer 如果只加在 default mode，滚动时 RunLoop 切到 tracking mode，它就会暂停。",
            optimization: "滑动中暂停低优先级图片解码或富文本计算；用 performSelector:afterDelay:inModes 或 DispatchQueue 控制任务时机；预加载放到空闲阶段。",
            memory: "RunLoop 优化就是：滑动时少干活，空闲时补任务。"
        ),
        InterviewPoint(
            question: "如何定位 UITableView 卡顿？",
            standardAnswer: "先复现卡顿路径，再看 FPS 和主线程调用栈。重点检查 cellForRowAt、heightForRowAt、layoutSubviews、图片解码、文本排版、reloadData 次数和主线程同步任务。",
            principle: "卡顿本质是某一帧主线程或渲染线程耗时超过预算。定位要从现象到证据，用工具确认是 CPU、GPU、布局、图片还是数据刷新问题。",
            followUp: "追问：你会先猜还是先测？答：先测。小公司项目也要有工具意识，先用 Time Profiler 和 Core Animation 找最大耗时点。",
            optimization: "加埋点记录 reload 次数、cell 配置耗时、图片解码耗时；开启 Debug View Hierarchy 看层级；用主线程卡顿监控捕获堆栈。",
            memory: "定位卡顿四步：复现、看 FPS、抓主线程、查图片和布局。"
        ),
        InterviewPoint(
            question: "FPS 检测怎么做？",
            standardAnswer: "常见做法是用 CADisplayLink 监听屏幕刷新，根据一段时间内回调次数估算 FPS。FPS 下降说明渲染或主线程可能跟不上刷新节奏。",
            principle: "CADisplayLink 会和屏幕刷新同步回调。理论 60Hz 设备每秒回调约 60 次，120Hz 设备可更高。如果主线程卡住，回调次数减少，FPS 下降。",
            followUp: "追问：FPS 低一定是 UITableView 问题吗？答：不一定，可能是网络回调、主线程计算、GPU 渲染、动画或其他页面逻辑造成，要结合调用栈分析。",
            optimization: "开发期可接入 FPS 面板；线上可做轻量卡顿监控，记录页面、设备、滑动场景和主线程堆栈，帮助复现。",
            memory: "FPS 用 CADisplayLink 看刷新次数，低了再抓堆栈找原因。"
        ),
        InterviewPoint(
            question: "Instruments 怎么排查 UITableView 卡顿？",
            standardAnswer: "用 Time Profiler 看 CPU 和主线程耗时，用 Core Animation 看 FPS、离屏渲染和图层问题，用 Allocations/Leaks 看内存增长和泄漏。",
            principle: "Time Profiler 能看到方法调用栈，Core Animation 能看到渲染性能，Allocations 能看到对象创建和内存峰值。三者组合能覆盖大部分列表卡顿问题。",
            followUp: "追问：看到 Time Profiler 里 cellForRowAt 很重怎么办？答：展开调用栈，找具体是布局、图片、富文本、JSON、磁盘 IO 还是业务计算，再拆到后台或缓存。",
            optimization: "排查顺序建议：先 Core Animation 看是否掉帧，再 Time Profiler 找 CPU 热点，最后用 Allocations 查是否频繁创建 cell 或图片内存暴涨。",
            memory: "Instruments 三件套：Time Profiler 查 CPU，Core Animation 查渲染，Allocations 查内存。"
        ),
        InterviewPoint(
            question: "面试时怎么回答更像有项目经验？",
            standardAnswer: "不要只背概念，要按“现象、原因、方案、工具、结果”回答。比如：列表快速滑动错图，我先确认是 cell 复用和异步图片回调导致，再用取消请求、modelID 校验和占位图解决。",
            principle: "面试官想判断你是否真的处理过列表问题。项目化表达要有业务场景、排查路径、取舍和最终收益，而不是只说“用复用、用缓存”。",
            followUp: "追问：能举个项目例子吗？答：商品列表、聊天列表、订单列表都可以，说清楚图片、动态高度、局部刷新和性能监控即可。",
            optimization: "回答模板：我们的列表有图片和动态高度；问题是滑动掉帧/错图；我用 Instruments 定位；最后做了高度缓存、图片解码、局部刷新，FPS 稳定很多。",
            memory: "像有经验 = 讲场景 + 讲定位 + 讲方案 + 讲结果。"
        ),
        InterviewPoint(
            question: "小公司最爱问哪些 UITableView 问题？",
            standardAnswer: "最常问：cell 复用机制、prepareForReuse、错图错乱、reloadData、动态高度、图片加载、卡顿优化、离屏渲染、RunLoop、Instruments。",
            principle: "小公司更关注能不能快速上手业务列表。UITableView 覆盖了网络图文、订单列表、聊天页、设置页、商品流等常见场景，所以非常高频。",
            followUp: "追问：怎么准备最有效？答：先把复用和错乱讲熟，再准备一个卡顿优化项目案例，最后补 Instruments 和 RunLoop 加分项。",
            optimization: "优先背这几句：复用池减少创建；prepareForReuse 清旧状态；错乱靠取消和校验；reloadData 是整表刷新；卡顿先查主线程。",
            memory: "小公司 UITableView 高频核心：复用、错乱、刷新、动态高度、卡顿。"
        ),
        InterviewPoint(
            question: "UITableView 面试哪些回答属于加分项？",
            standardAnswer: "能说出高度缓存、图片后台解码、预取、RunLoop 任务延后、diffable data source、Instruments 定位、FPS 监控和离屏渲染排查，都是加分项。",
            principle: "加分项的关键不是名词多，而是能说明为什么需要、解决什么问题、什么时候不用。比如异步绘制适合复杂绘制，不是所有 cell 都要上。",
            followUp: "追问：加分项会不会过度设计？答：会。小项目先保证复用正确、图片不错乱、刷新范围合理；性能问题出现后再用工具驱动优化。",
            optimization: "面试时可以强调渐进优化：先做正确性，再做局部刷新和缓存；有证据后再引入复杂方案，避免为了技术而技术。",
            memory: "加分项不是堆术语，是能用工具证明问题，再选合适方案。"
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
            title = "UITableView 面试宝典"
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    private func setupAppearance() {
        view.backgroundColor = UITableViewInterviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = UITableViewInterviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        view.backgroundColor = UITableViewInterviewStyle.backgroundColor
        tableView.backgroundColor = UITableViewInterviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 360
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        tableView.register(
            UITableViewInterviewCell.self,
            forCellReuseIdentifier: cellReuseIdentifier
        )
        tableView.register(
            UITableViewInterviewHeaderView.self,
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
        ) as? UITableViewInterviewCell ?? UITableViewInterviewCell(
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
        ) as? UITableViewInterviewHeaderView ?? UITableViewInterviewHeaderView(
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
                id: "reuse",
                title: "复用机制",
                subtitle: "复用池、prepareForReuse、dequeue、状态错乱",
                symbolName: "square.stack.3d.forward.dottedline.fill",
                colorIndex: 0,
                range: 0..<5
            ),
            makeSection(
                id: "reload-height",
                title: "刷新与高度",
                subtitle: "reloadData、局部刷新、动态高度、估算高度",
                symbolName: "arrow.clockwise.circle.fill",
                colorIndex: 1,
                range: 5..<10
            ),
            makeSection(
                id: "performance",
                title: "性能优化",
                subtitle: "卡顿治理、异步绘制、离屏渲染",
                symbolName: "speedometer",
                colorIndex: 2,
                range: 10..<13
            ),
            makeSection(
                id: "image-runloop",
                title: "图片与 RunLoop",
                subtitle: "图片加载、滑动模式、卡顿定位",
                symbolName: "photo.on.rectangle.angled",
                colorIndex: 3,
                range: 13..<16
            ),
            makeSection(
                id: "tools-expression",
                title: "工具与面试表达",
                subtitle: "FPS、Instruments、项目经验表达",
                symbolName: "wrench.and.screwdriver.fill",
                colorIndex: 4,
                range: 16..<points.count
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
            tintColor: UITableViewInterviewStyle.accentColors[
                colorIndex % UITableViewInterviewStyle.accentColors.count
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
            optimization: point.optimization,
            memoryLine: point.memory
        )
    }
}

private final class UITableViewInterviewHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UITableViewInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = UITableViewInterviewStyle.titleTextColor
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
        label.textColor = UITableViewInterviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UITableViewInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: UITableViewInterviewPaddingLabel = {
        let label = UITableViewInterviewPaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = UITableViewInterviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UITableViewInterviewStyle.secondaryTextColor
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
        section: UITableViewInterviewReviewViewController.InterviewSection,
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
        contentView.backgroundColor = UITableViewInterviewStyle.backgroundColor
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

private final class UITableViewInterviewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UITableViewInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UITableViewInterviewPaddingLabel = {
        let label = UITableViewInterviewPaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = UITableViewInterviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UITableViewInterviewStyle.titleTextColor
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
        question: UITableViewInterviewReviewViewController.InterviewQuestion,
        rows: [UITableViewInterviewReviewViewController.ReviewRowKind],
        accentColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = accentColor.withAlphaComponent(0.26)
        titleLabel.text = question.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = accentColor.withAlphaComponent(0.20).cgColor

        rows.forEach { row in
            let fieldView = UITableViewInterviewFieldView()
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
        selectedBackgroundView?.backgroundColor = UITableViewInterviewStyle.selectionColor
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

private final class UITableViewInterviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = UITableViewInterviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UITableViewInterviewStyle.bodyTextColor
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
        backgroundColor = UITableViewInterviewStyle.fieldBackgroundColor
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
        titleLabel.textColor = isMemoryLine ? tintColor : UITableViewInterviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = isMemoryLine
            ? .systemFont(ofSize: 15, weight: .semibold)
            : .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = isMemoryLine ? UITableViewInterviewStyle.titleTextColor : UITableViewInterviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : UITableViewInterviewStyle.fieldBackgroundColor
    }
}

private final class UITableViewInterviewPaddingLabel: UILabel {

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

private final class ReviewSectionHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UITableViewInterviewStyle.headerBackgroundColor
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
        label.textColor = UITableViewInterviewStyle.titleTextColor
        label.numberOfLines = 0
        return label
    }()

    private let memoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UITableViewInterviewStyle.secondaryTextColor
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
        containerView.backgroundColor = UITableViewInterviewStyle.headerBackgroundColor
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

private final class ReviewDetailCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UITableViewInterviewStyle.cardBackgroundColor
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
        label.textColor = UITableViewInterviewStyle.bodyTextColor
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
        rowKind: UITableViewInterviewReviewViewController.ReviewRowKind,
        text: String,
        accentColor: UIColor,
        highlightedWords: [String]
    ) {
        let isMemoryRow = rowKind == .memory
        iconImageView.image = UIImage(systemName: rowKind.iconName)
        iconImageView.tintColor = isMemoryRow
            ? UITableViewInterviewStyle.highlightedTextColor
            : accentColor
        titleLabel.text = rowKind.title
        titleLabel.textColor = isMemoryRow
            ? UITableViewInterviewStyle.highlightedTextColor
            : accentColor
        bodyLabel.attributedText = makeHighlightedText(
            text,
            accentColor: accentColor,
            highlightedWords: highlightedWords,
            isProminent: isMemoryRow
        )
        containerView.backgroundColor = isMemoryRow
            ? accentColor.withAlphaComponent(0.18)
            : UITableViewInterviewStyle.cardBackgroundColor
        containerView.layer.borderColor = accentColor
            .withAlphaComponent(isMemoryRow ? 0.58 : 0.22)
            .cgColor
        containerView.layer.borderWidth = 1
    }

    private func setupViews() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UITableViewInterviewStyle.selectionColor
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
                    ? UITableViewInterviewStyle.highlightedTextColor
                    : UITableViewInterviewStyle.bodyTextColor,
                .paragraphStyle: paragraphStyle
            ]
        )

        for word in highlightedWords {
            let ranges = rangesOfWord(word, in: text)
            for range in ranges {
                result.addAttributes(
                    [
                        .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                        .foregroundColor: UITableViewInterviewStyle.highlightedTextColor,
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
