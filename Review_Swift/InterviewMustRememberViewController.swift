//
//  InterviewMustRememberViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/20.
//

import UIKit

final class InterviewMustRememberViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "必背高频速记总纲",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "必背高频速记总纲",
            modules: Self.makeModules()
        )
    }

    private static func makeModules() -> [InterviewReviewModule] {
        [
            InterviewReviewModule(
                id: "review-route",
                title: "复习路线",
                subtitle: "先背什么、后背什么、面试现场怎么收口",
                symbolName: "map.fill",
                tintColor: UIColor(red: 1.00, green: 0.40, blue: 0.40, alpha: 1.0),
                items: makeReviewRouteItems()
            ),
            InterviewReviewModule(
                id: "project",
                title: "第一梯队：项目实战",
                subtitle: "项目介绍、架构、网络、登录态、列表、排查",
                symbolName: "flame.fill",
                tintColor: InterviewReviewStyle.accentColors[2],
                items: makeProjectItems()
            ),
            InterviewReviewModule(
                id: "swift-arc",
                title: "第一梯队：Swift 与 ARC",
                subtitle: "Optional、struct/class、闭包、weak self、Timer",
                symbolName: "swift",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: makeSwiftARCItems()
            ),
            InterviewReviewModule(
                id: "uikit-list",
                title: "第一梯队：UIKit 与列表",
                subtitle: "生命周期、复用、错乱、动态高度、卡顿优化",
                symbolName: "list.bullet.rectangle.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: makeUIKitListItems()
            ),
            InterviewReviewModule(
                id: "network-data",
                title: "第一梯队：网络与数据",
                subtitle: "HTTP、HTTPS、JSON、token、Keychain、缓存选型",
                symbolName: "network",
                tintColor: InterviewReviewStyle.accentColors[3],
                items: makeNetworkDataItems()
            ),
            InterviewReviewModule(
                id: "concurrency-debug",
                title: "第一梯队：并发与排查",
                subtitle: "GCD、死锁、线程安全、RunLoop、Crash、Instruments",
                symbolName: "stethoscope",
                tintColor: InterviewReviewStyle.accentColors[4],
                items: makeConcurrencyDebugItems()
            ),
            InterviewReviewModule(
                id: "bonus-special",
                title: "第二梯队：加分与专项",
                subtitle: "runtime、KVC/KVO、Block、AI、MQTT、H5、权限",
                symbolName: "sparkles",
                tintColor: UIColor(red: 0.73, green: 0.58, blue: 1.00, alpha: 1.0),
                items: makeBonusSpecialItems()
            )
        ]
    }

    private static func reviewItem(
        title: String,
        mustRemember: String,
        quickAnswer: String,
        memoryLine: String,
        followUp: String,
        relatedModule: String
    ) -> InterviewReviewItem {
        InterviewReviewItem(
            title: title,
            rows: [
                InterviewReviewRow(
                    title: "必背原因",
                    body: mustRemember,
                    symbolName: "star.fill"
                ),
                InterviewReviewRow(
                    title: "快速答案",
                    body: quickAnswer,
                    symbolName: "checkmark.seal.fill"
                ),
                InterviewReviewRow(
                    title: "一句话速记",
                    body: memoryLine,
                    symbolName: "bolt.fill",
                    isMemoryLine: true
                ),
                InterviewReviewRow(
                    title: "常见追问",
                    body: followUp,
                    symbolName: "bubble.left.and.bubble.right.fill"
                ),
                InterviewReviewRow(
                    title: "对应模块",
                    body: relatedModule,
                    symbolName: "rectangle.stack.fill"
                )
            ]
        )
    }
}

private extension InterviewMustRememberViewController {

    static func makeReviewRouteItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "最优复习顺序",
                mustRemember: "题库很多，但面试不是平均抽题。先背能证明项目能力的内容，再补语言和底层。",
                quickAnswer: "顺序：项目实战 -> ARC -> UITableView -> 网络登录态 -> Crash 排查 -> Swift 基础 -> 多线程 -> UIKit -> runtime -> AI/MQTT 专项。",
                memoryLine: "先项目，后八股；先高频，后加分。",
                followUp: "追问：时间很少怎么办？只背项目、ARC、列表、网络、Crash 五块，先拿基本盘。",
                relatedModule: "中小公司项目面试题、ARC 内存管理、UITableView、网络相关、崩溃与问题排查"
            ),
            reviewItem(
                title: "面试回答模板",
                mustRemember: "很多题不是考你背定义，而是看你能不能讲清项目里的落地方式。",
                quickAnswer: "回答按五步：概念是什么、为什么会有这个问题、项目里怎么用、踩过什么坑、最后怎么验证。",
                memoryLine: "概念、原因、项目、坑、验证。",
                followUp: "追问：遇到项目经历题怎么办？按现象、排查、定位、解决、结果五步讲。",
                relatedModule: "项目实战、Crash 排查、UITableView 工具与面试表达"
            ),
            reviewItem(
                title: "10 分钟临场版",
                mustRemember: "面试前最后十分钟不要翻全部题，背总口诀更有效。",
                quickAnswer: "项目讲职责和闭环；列表讲复用和卡顿；网络讲封装和 token；内存讲 strong 链和 weak self；Crash 讲日志、符号化、调用栈。",
                memoryLine: "项目闭环，列表复用，网络 token，内存 weak，Crash 看栈。",
                followUp: "追问：怎么显得有经验？每个答案补一句项目场景和排查工具。",
                relatedModule: "必背总纲全局复习卡"
            )
        ]
    }

    static func makeProjectItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "最近项目和职责",
                mustRemember: "这是开场题，答不好后面再会八股也会显得虚。",
                quickAnswer: "按业务背景、技术栈、个人职责、核心模块、结果五段回答。重点说自己负责了页面、接口、状态处理、异常兜底和问题排查。",
                memoryLine: "项目介绍 = 背景、职责、模块、难点、结果。",
                followUp: "追问：你独立负责什么？挑登录、列表、详情、支付、上传、消息这类完整链路展开。",
                relatedModule: "中小公司高频项目面试题 -> 最近项目和职责"
            ),
            reviewItem(
                title: "页面完整流程",
                mustRemember: "中小公司很爱问，能判断你是不是只写 UI。",
                quickAnswer: "进入页面后初始化 UI 和 ViewModel，读取缓存或默认状态，发请求，解析 model，回主线程刷新 UI，同时处理 loading、空态、错误态和分页。",
                memoryLine: "初始化、请求、解析、刷新、兜底。",
                followUp: "追问：接口慢怎么办？有旧缓存先展示旧数据，失败保留旧数据并提示。",
                relatedModule: "中小公司高频项目面试题 -> 页面完整流程"
            ),
            reviewItem(
                title: "项目架构与拆分",
                mustRemember: "这是把你从会写页面拉到会维护项目的关键题。",
                quickAnswer: "轻量 MVVM：Controller 管生命周期和跳转，View 管展示，ViewModel 管请求和展示数据转换，Service/Manager 管网络、缓存、登录态。",
                memoryLine: "Controller 管流程，ViewModel 管数据，Service 管能力。",
                followUp: "追问：MVVM 一定好吗？不一定，简单页面 MVC 也可以，复杂页面再拆。",
                relatedModule: "中小公司高频项目面试题 -> 项目架构、Controller 拆分"
            ),
            reviewItem(
                title: "网络层封装",
                mustRemember: "项目题和网络题会同时追问，必须能说出统一封装点。",
                quickAnswer: "网络层统一处理 baseURL、path、method、header、token、超时、取消、日志、错误码、JSON 解析和回调线程。",
                memoryLine: "页面只管业务，网络层统一请求、解析、错误、日志。",
                followUp: "追问：为什么不每页直接写 URLSession？公共 header、token、错误码、日志和环境切换不好统一。",
                relatedModule: "项目实战 -> 网络层封装；网络相关 -> URLSession"
            ),
            reviewItem(
                title: "token 过期刷新",
                mustRemember: "登录态是 App 高频业务题，答出并发刷新队列会很加分。",
                quickAnswer: "接口返回 401 或业务过期码时，只发起一次 refreshToken。刷新成功更新本地 token 并重试原请求，刷新失败清登录态并跳登录页。",
                memoryLine: "401 先刷新，只刷一次，失败登录。",
                followUp: "追问：多个接口同时 401 怎么办？用 isRefreshing 和等待队列，其余请求等刷新结果后重试。",
                relatedModule: "项目实战 -> token 过期刷新；网络相关 -> token/refreshToken"
            )
        ]
    }

    static func makeSwiftARCItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "Optional",
                mustRemember: "Swift 基础第一高频，很多 crash 和 Codable 容错都会追到 Optional。",
                quickAnswer: "Optional 本质是 enum，表示 some 或 none。? 安全可选值，! 隐式或强制解包，nil 表示没有值，optional chaining 遇 nil 返回 nil。",
                memoryLine: "Optional 是 some/none 的安全容器。",
                followUp: "追问：强制解包 nil 会怎样？直接崩溃，项目里尽量用 if let、guard let、?? 做兜底。",
                relatedModule: "Swift 基础高频面试题 -> Optional"
            ),
            reviewItem(
                title: "struct 和 class",
                mustRemember: "Swift 面试绕不开，也会和 model 设计、COW、ARC 结合问。",
                quickAnswer: "struct 是值类型，赋值传参复制值；class 是引用类型，复制引用，有对象身份、继承和 deinit，由 ARC 管生命周期。",
                memoryLine: "struct 管数据，class 管身份和生命周期。",
                followUp: "追问：model 怎么选？普通网络和展示 model 优先 struct；共享状态、继承、生命周期管理用 class。",
                relatedModule: "struct 与 class 的区别"
            ),
            reviewItem(
                title: "strong / weak / unowned",
                mustRemember: "ARC 核心题，几乎所有内存泄漏追问都从这里开始。",
                quickAnswer: "strong 表示拥有并延长生命周期；weak 不拥有，释放后自动 nil；unowned 不拥有也不置 nil，要求对方生命周期一定更长。",
                memoryLine: "拥有 strong，不拥有 weak，确定更长命才 unowned。",
                followUp: "追问：delegate 为什么 weak？delegate 是反向通知，不应该拥有调用方。",
                relatedModule: "strong、weak、unowned 的区别；UIViewController ARC 内存管理"
            ),
            reviewItem(
                title: "闭包和 weak self",
                mustRemember: "真实项目最容易泄漏的地方之一。",
                quickAnswer: "闭包默认强捕获 self。对象 strong 持有闭包，闭包又 strong 捕获 self，就形成 self -> closure -> self 的循环引用。",
                memoryLine: "self 持闭包，闭包抓 self，就成环。",
                followUp: "追问：所有闭包都要 weak self 吗？不是，关键看闭包是否逃逸、是否被长期持有、是否反向持有 self。",
                relatedModule: "Swift 基础 -> closure / escaping / capture list；ARC -> 闭包为什么写 weak self"
            ),
            reviewItem(
                title: "Timer / Notification / deinit",
                mustRemember: "这是内存泄漏项目经历最容易套的模板。",
                quickAnswer: "Timer 会被 RunLoop 持有，Timer 的 target 或 block 再持有 self 时页面不释放。Notification block 也要保存 token 并移除。deinit 不走就查 strong 引用链。",
                memoryLine: "deinit 不走，先找谁还 strong 持有 self。",
                followUp: "追问：怎么排查？加 deinit 日志，打开 Memory Graph，看 Timer、闭包、通知、delegate、单例缓存。",
                relatedModule: "UIViewController ARC 内存管理；崩溃与问题排查 -> 内存泄漏"
            )
        ]
    }

    static func makeUIKitListItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "UIViewController 生命周期",
                mustRemember: "页面刷新、埋点、弹窗、资源释放都离不开生命周期。",
                quickAnswer: "loadView 创建根视图；viewDidLoad 一次性搭 UI；viewWillAppear 每次将显示刷新；viewDidAppear 页面已显示；viewWillDisappear 暂停任务；deinit 代表释放。",
                memoryLine: "DidLoad 搭台，WillAppear 刷新，DidAppear 曝光，deinit 验释放。",
                followUp: "追问：从详情返回刷新放哪？通常放 viewWillAppear，不要放只执行一次的 viewDidLoad。",
                relatedModule: "UIKit 高频面试题 -> UIViewController 生命周期"
            ),
            reviewItem(
                title: "UITableView 复用",
                mustRemember: "UITableView 是 iOS 业务列表核心，复用机制基本必问。",
                quickAnswer: "UITableView 只创建可见和少量预加载 cell。滑出屏幕后进入复用池，新 indexPath 展示时取出旧 cell 重新配置。",
                memoryLine: "cell 不是无限创建，而是少量对象反复配置。",
                followUp: "追问：prepareForReuse 做什么？清旧状态、取消旧任务，configure 再完整赋新值。",
                relatedModule: "UITableView 面试宝典 -> 复用机制"
            ),
            reviewItem(
                title: "cell 图片错乱",
                mustRemember: "这是最能体现项目经验的列表问题。",
                quickAnswer: "错乱来自 cell 复用后旧异步请求晚回来。解决：configure 完整赋值，prepareForReuse 取消旧请求并设占位，回调用 URL/modelID/requestID 校验身份。",
                memoryLine: "完整赋值、取消旧任务、回调校验身份。",
                followUp: "追问：为什么不用 indexPath 校验？插入、删除、排序后 indexPath 会变，稳定 modelID 更可靠。",
                relatedModule: "UITableView 面试宝典 -> cell 错乱；项目实战 -> cell 图片错乱"
            ),
            reviewItem(
                title: "列表卡顿优化",
                mustRemember: "性能题高频，答案要先讲工具再讲方案。",
                quickAnswer: "先用 Instruments 定位，再减少主线程工作：cell 轻量化、减少层级、图片下采样和后台解码、高度缓存、局部刷新、避免 cellForRowAt 做复杂计算。",
                memoryLine: "卡顿先抓主线程，再看图片、布局、高度、刷新范围。",
                followUp: "追问：怎么证明有效？对比 FPS、主线程耗时、内存峰值和 Time Profiler 调用栈。",
                relatedModule: "UITableView 面试宝典 -> 性能优化；Crash 排查 -> Instruments"
            ),
            reviewItem(
                title: "AutoLayout 与响应链",
                mustRemember: "属于 UIKit 高频加分，常和按钮点不动、约束冲突一起问。",
                quickAnswer: "constraint 是布局规则，frame 是计算结果；hugging 抗拉伸，compression 抗压缩。触摸先 UIApplication 到 UIWindow，再 hitTest 找目标 view，UIControl 触发 target-action。",
                memoryLine: "约束定规则，frame 看结果；hitTest 找最终响应者。",
                followUp: "追问：按钮点不动怎么查？看交互开关、遮挡、超出父视图 bounds、hitTest 目标和 target-action。",
                relatedModule: "UIKit 高频面试题 -> AutoLayout、事件响应链"
            )
        ]
    }

    static func makeNetworkDataItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "HTTP / HTTPS",
                mustRemember: "网络基础必问，HTTPS 还能追到 TLS 和证书校验。",
                quickAnswer: "HTTP 是请求响应的应用层协议，本身无状态。HTTPS = HTTP + TLS，提供加密、防篡改和身份认证。",
                memoryLine: "HTTP 管格式，TLS 给它上锁。",
                followUp: "追问：HTTPS 为什么安全？加密防窃听，证书认证防冒充，完整性校验防篡改。",
                relatedModule: "iOS 网络相关面试宝典 -> HTTP / HTTPS"
            ),
            reviewItem(
                title: "GET / POST",
                mustRemember: "面试常从参数位置问到安全、幂等、缓存和场景。",
                quickAnswer: "GET 参数通常在 URL query，适合读和缓存；POST 参数通常在 body，适合提交、创建、上传。安全主要看 HTTPS，不是 GET/POST 本身。",
                memoryLine: "读 GET，写 POST；安全看 HTTPS。",
                followUp: "追问：GET 一定安全幂等吗？语义上应该安全幂等，但实际还要看后端实现。",
                relatedModule: "iOS 网络相关面试宝典 -> GET / POST 区别"
            ),
            reviewItem(
                title: "JSON / Codable",
                mustRemember: "接口联调、脏数据、字段变化都绕不开。",
                quickAnswer: "Codable 是 Encodable + Decodable，配合 JSONDecoder/JSONEncoder 做模型和 JSON 互转。字段缺失、null、类型不稳、字段名不一致要用 Optional、CodingKeys、自定义 init 兼容。",
                memoryLine: "名对、型对、层级对；后端不保证，前端加问号。",
                followUp: "追问：解析失败怎么定位？打印 DecodingError，看 keyNotFound、typeMismatch、valueNotFound、dataCorrupted。",
                relatedModule: "网络相关 -> JSON 解析；数据持久化 -> Codable"
            ),
            reviewItem(
                title: "token / session / cookie",
                mustRemember: "登录态题会贯穿网络层、存储和项目实战。",
                quickAnswer: "token 是客户端携带的身份凭证，移动端常放 Keychain 并放 Authorization Header。session 数据在服务端，客户端通常用 cookie 带 sessionId。",
                memoryLine: "session 服务端记，token 客户端带。",
                followUp: "追问：退出登录清什么？token、用户信息、cookie、接口缓存、未完成请求和页面状态。",
                relatedModule: "网络相关 -> token/cookie/session；项目实战 -> 登录态保存和退出"
            ),
            reviewItem(
                title: "本地存储选型",
                mustRemember: "项目题高频，能体现你有没有基本安全意识。",
                quickAnswer: "UserDefaults 放小而不敏感的配置；Keychain 放 token、密码和凭证；FileManager 放图片、日志、大 JSON；SQLite/CoreData 放结构化数据和复杂查询。",
                memoryLine: "配置 Defaults，凭证 Keychain，文件 Caches，结构化数据库。",
                followUp: "追问：token 能放 UserDefaults 吗？不推荐，凭证应该进 Keychain。",
                relatedModule: "iOS 数据持久化面试宝典；项目实战 -> 本地存储选型"
            )
        ]
    }

    static func makeConcurrencyDebugItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "GCD 与队列",
                mustRemember: "多线程基础第一问，后面会追 sync/async、死锁和主线程。",
                quickAnswer: "GCD 把任务提交到队列，由系统线程池调度。主队列串行并在主线程执行，适合 UI；全局队列并发，适合耗时任务。",
                memoryLine: "GCD = 队列管任务，系统管线程。",
                followUp: "追问：async 一定开新线程吗？不一定，async 只是不等待，提交到主队列仍在主线程。",
                relatedModule: "iOS 多线程面试知识点 -> GCD、sync/async"
            ),
            reviewItem(
                title: "死锁与线程安全",
                mustRemember: "面试喜欢让你解释 main.sync 为什么卡死。",
                quickAnswer: "主线程同步提交到主队列会死锁，因为主线程等新任务完成，新任务又要等当前主队列任务结束。线程安全看共享、可变、同时访问，方案是串行队列、锁、semaphore、actor 等。",
                memoryLine: "主线程 sync 主队列，就是我等我自己。",
                followUp: "追问：atomic 能保证线程安全吗？只保单次 getter/setter，不保业务整段逻辑。",
                relatedModule: "多线程 -> 死锁、线程安全"
            ),
            reviewItem(
                title: "RunLoop",
                mustRemember: "RunLoop 常和 Timer、列表滑动、常驻线程、卡顿监控一起问。",
                quickAnswer: "RunLoop 是线程事件循环，有事处理事件，没事休眠。主线程默认开启。Mode 用来隔离事件源，滚动时会进入 tracking mode。",
                memoryLine: "RunLoop = 有事干活，没事睡觉。",
                followUp: "追问：Timer 滚动时为什么不走？Timer 只加在 default mode，滚动进入 tracking mode 后不会触发。",
                relatedModule: "多线程 -> RunLoop；项目实战 -> RunLoop 项目体现"
            ),
            reviewItem(
                title: "Crash 定位",
                mustRemember: "线上问题闭环是项目经验的硬证据。",
                quickAnswer: "先拿 crash 日志，用对应版本 dSYM 符号化，看崩溃线程和调用栈，找第一段业务代码，结合版本、机型、埋点和接口数据复现，修复后观察指标。",
                memoryLine: "Crash：日志、符号、线程、栈、复现、修复。",
                followUp: "追问：常见 crash 有哪些？数组越界、强制解包 nil、野指针、KVO、线程读写、selector 找不到。",
                relatedModule: "iOS 崩溃与问题排查面试宝典"
            ),
            reviewItem(
                title: "Instruments",
                mustRemember: "答性能和泄漏题时，提工具会比纯背概念更像做过项目。",
                quickAnswer: "Time Profiler 查 CPU 和主线程耗时；Core Animation 查 FPS、离屏渲染；Leaks 查泄漏；Allocations 查对象分配和内存增长；Network 查请求。",
                memoryLine: "Time 查卡顿，Leaks 查泄漏，Allocations 看增长。",
                followUp: "追问：列表卡顿怎么定位？先复现，再看 FPS 和主线程调用栈，重点查图片解码、布局、高度和 reload 次数。",
                relatedModule: "崩溃与问题排查 -> Instruments；UITableView -> 工具与面试表达"
            )
        ]
    }

    static func makeBonusSpecialItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "runtime / KVC / KVO / Block",
                mustRemember: "不是每家都深问，但答出来很加分，老项目也常见。",
                quickAnswer: "runtime 管运行时消息发送和动态能力；KVC 用字符串读写属性；KVO 通过动态子类观察属性；Block 是 OC 闭包，属性用 copy，注意循环引用。",
                memoryLine: "runtime 改行为，KVC 找 key，KVO 盯变化，Block 看捕获。",
                followUp: "追问：KVO 原理？动态创建 NSKVONotifying 子类，重写 setter，插入 will/did change。",
                relatedModule: "OC runtime / KVC / KVO / Block"
            ),
            reviewItem(
                title: "AI 项目专项",
                mustRemember: "简历写了 AI 聊天、智能助手、RAG 就必须背。",
                quickAnswer: "AI 接口本质是 HTTPS POST。流式输出常用 SSE，用 URLSessionDataDelegate 接增量数据。客户端维护 messages 上下文，控制 token，Markdown 后台解析，UI 增量刷新。",
                memoryLine: "AI 面试：请求、流式、上下文、渲染、优化。",
                followUp: "追问：RAG 是什么？先检索资料，再带资料让模型回答，减少胡说并提升可追溯性。",
                relatedModule: "AI 常规高频面试题总结"
            ),
            reviewItem(
                title: "MQTT 专项",
                mustRemember: "简历有 IoT、智能设备、消息推送、长连接时必须背。",
                quickAnswer: "MQTT 是轻量发布订阅协议，基于 TCP 长连接，通过 Broker 和 Topic 解耦。QoS 管可靠性，retain 存最后一条，clean session 管离线会话，keep alive 做心跳。",
                memoryLine: "长连中转，频道订阅，可靠靠 QoS，状态靠 retain。",
                followUp: "追问：MQTT 和 WebSocket 区别？WebSocket 是通道，MQTT 是消息协议和语义。",
                relatedModule: "MQTT 面试八股"
            ),
            reviewItem(
                title: "H5、权限、上架和协作",
                mustRemember: "中小公司常问落地杂项，用来判断你能不能独立上线。",
                quickAnswer: "H5 原生交互用 WKWebView bridge；权限按用户触发场景申请并处理拒绝；SDK 接入看 Scheme、Universal Link 和回调；上架要懂证书、描述文件、Archive、TestFlight。",
                memoryLine: "能开发，也要能联调、打包、上线、排查。",
                followUp: "追问：Git 冲突怎么处理？先理解双方改动，手动合并，编译和回归关键流程。",
                relatedModule: "项目实战 -> 第二梯队常问、项目经历类必背"
            )
        ]
    }
}
