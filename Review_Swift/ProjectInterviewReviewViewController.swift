//
//  ProjectInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/20.
//

import UIKit

final class ProjectInterviewReviewViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "中小公司项目面试题",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "中小公司项目面试题",
            modules: Self.makeModules()
        )
    }

    private static func makeModules() -> [InterviewReviewModule] {
        [
            InterviewReviewModule(
                id: "first-tier",
                title: "第一梯队必背",
                subtitle: "项目职责、架构、网络、登录态、列表、缓存、Crash、线程安全",
                symbolName: "flame.fill",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: makeFirstTierItems()
            ),
            InterviewReviewModule(
                id: "second-tier",
                title: "第二梯队常问",
                subtitle: "第三方库、脏数据、错误处理、弱网、启动优化、H5、权限、协作",
                symbolName: "list.bullet.rectangle.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: makeSecondTierItems()
            ),
            InterviewReviewModule(
                id: "project-experience",
                title: "项目经历类必背",
                subtitle: "最难问题、独立功能、性能优化、线上问题、重构、联调、需求变更",
                symbolName: "briefcase.fill",
                tintColor: InterviewReviewStyle.accentColors[2],
                items: makeProjectExperienceItems()
            ),
            InterviewReviewModule(
                id: "ios-basics-in-project",
                title: "Swift / iOS 结合项目",
                subtitle: "weak self、delegate、struct/class、Codable、RunLoop、Timer、通知、KVO",
                symbolName: "swift",
                tintColor: InterviewReviewStyle.accentColors[3],
                items: makeIOSBasicsItems()
            )
        ]
    }

    private static func reviewItem(
        title: String,
        question: String,
        standardAnswer: String,
        projectScenario: String,
        followUp: String,
        pitfall: String,
        script: String
    ) -> InterviewReviewItem {
        InterviewReviewItem(
            title: title,
            rows: [
                InterviewReviewRow(
                    title: "面试题",
                    body: question,
                    symbolName: "questionmark.circle.fill"
                ),
                InterviewReviewRow(
                    title: "标准回答",
                    body: standardAnswer,
                    symbolName: "checkmark.seal.fill"
                ),
                InterviewReviewRow(
                    title: "项目场景",
                    body: projectScenario,
                    symbolName: "briefcase.fill"
                ),
                InterviewReviewRow(
                    title: "常见追问",
                    body: followUp,
                    symbolName: "bubble.left.and.bubble.right.fill"
                ),
                InterviewReviewRow(
                    title: "避坑提醒",
                    body: pitfall,
                    symbolName: "exclamationmark.triangle.fill"
                ),
                InterviewReviewRow(
                    title: "可背话术",
                    body: script,
                    symbolName: "text.book.closed.fill",
                    isMemoryLine: true
                )
            ]
        )
    }

    private static func makeFirstTierItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "最近项目和职责",
                question: "你最近做的项目是什么？你负责哪些模块？",
                standardAnswer: "按业务背景、技术栈、个人职责、核心模块、结果五段回答。不要只说项目名字，要说清楚自己负责了哪些页面、接口、状态处理和问题排查。",
                projectScenario: "例如：我负责登录注册、首页列表、详情页和个人中心，工作包括 UI 搭建、接口联调、分页、图片缓存、登录态保存、异常状态和线上问题修复。",
                followUp: "追问：项目几个人做？你独立负责什么？答：说清产品、后端、测试协作方式，再挑一个自己独立交付的完整模块展开。",
                pitfall: "不要说我都参与了但讲不出细节。中小公司更想确认你能不能独立把功能从需求做到上线。",
                script: "我会从业务、职责、技术和结果讲。我主要负责核心业务页面，包含页面搭建、网络请求、数据展示、异常处理和后续问题排查。"
            ),
            reviewItem(
                title: "页面完整流程",
                question: "你负责的某个页面，从进入页面到数据显示，完整流程是什么？",
                standardAnswer: "先初始化页面和 ViewModel，再读取缓存或默认状态，进入页面触发请求，网络层返回后解析 model，回主线程刷新 UI，同时处理 loading、空数据、错误和分页状态。",
                projectScenario: "首页列表：viewDidLoad 配置 tableView 和刷新控件，触发第一页请求，成功后更新 dataSource 并刷新列表，失败时展示错误页或 toast。",
                followUp: "追问：接口慢时怎么显示？答：首屏 loading，有旧缓存先展示旧数据再静默刷新，失败时保留旧数据并提示。",
                pitfall: "不要只说请求接口然后刷新 UI。要带上 loading、缓存、空态、错误态、线程切换和分页状态。",
                script: "我会把页面流程拆成状态初始化、发请求、解析数据、刷新 UI、异常兜底几步。这样成功、失败、空数据和弱网都有明确表现。"
            ),
            reviewItem(
                title: "项目架构",
                question: "项目整体架构是怎样的？MVC 还是 MVVM？为什么这么分？",
                standardAnswer: "中小项目常见是 MVC 或轻量 MVVM。Controller 负责生命周期和跳转，View 负责展示，ViewModel 负责接口请求、数据转换和状态输出，Service/Manager 负责网络、缓存、登录态等基础能力。",
                projectScenario: "列表页使用 ViewModel 拉接口并转换成 cell model，Controller 只绑定回调和刷新 tableView，NetworkClient 统一处理 token、错误码和日志。",
                followUp: "追问：MVVM 一定更好吗？答：不是。简单页面 MVC 更快，复杂页面用 ViewModel 能减少 Controller 体积并复用展示逻辑。",
                pitfall: "不要把 MVVM 说成万能答案。面试官更关心职责是否清楚，是否真的降低维护成本。",
                script: "我们项目偏轻量 MVVM。Controller 管生命周期和跳转，ViewModel 管请求和展示数据转换，View 只负责展示，简单页面不会过度拆。"
            ),
            reviewItem(
                title: "Controller 拆分",
                question: "ViewController 代码太多时，你怎么拆？",
                standardAnswer: "按职责拆：UI 搭建放自定义 View，数据请求和格式化放 ViewModel，网络放 Service，工具能力放 Manager，tableView 的 delegate/dataSource 可以独立成 adapter 或扩展。",
                projectScenario: "订单页原来 Controller 很重，后来把筛选栏封成 OrderFilterView，把列表数据整理放 OrderListViewModel，把请求放 OrderService，Controller 只保留绑定和跳转。",
                followUp: "追问：拆太细会不会复杂？答：会，所以以复用和复杂度为标准。一次性简单页面不硬拆，多状态、多接口、多 cell 的页面才拆。",
                pitfall: "不要为了架构而架构。中小公司项目要强调够用、清晰、能维护。",
                script: "我拆 Controller 的原则是按职责拆，不按文件数量拆。UI、请求、数据转换、跳转分别放到合适位置。"
            ),
            reviewItem(
                title: "网络层封装",
                question: "网络层是怎么封装的？",
                standardAnswer: "封装请求构建、公共参数、header、token、超时、日志、错误码、JSON 解析和回调线程。业务层只关心接口路径、参数和返回模型，不直接处理底层细节。",
                projectScenario: "项目里有 NetworkClient 统一发请求，API 枚举描述 path、method、parameters。成功返回 Decodable 模型，失败统一转成 NetworkError。",
                followUp: "追问：为什么不每个页面直接写 URLSession？答：重复代码多，token、错误码、日志、超时、环境切换都不好统一。",
                pitfall: "不要只回答用了 Alamofire。第三方库只是工具，重点是你怎么统一处理业务规则。",
                script: "网络层我会统一封装请求、公共 header、token、错误码、解析和日志。页面层只拿结果，不关心底层请求细节。"
            ),
            reviewItem(
                title: "token 过期刷新",
                question: "token 过期怎么处理？refresh token 怎么设计？",
                standardAnswer: "请求返回 token 过期错误时，先暂停或排队后续请求，只发起一次 refresh token。刷新成功后更新本地 token 并重试原请求；刷新失败则清登录态并跳登录页。",
                projectScenario: "多个接口同时 401 时，用 isRefreshing 标记和等待队列，避免同时刷新多次。刷新成功后把队列里的请求重新执行。",
                followUp: "追问：refresh token 也过期怎么办？答：说明登录态失效，清除本地 token、用户信息和缓存状态，跳登录页。",
                pitfall: "不要每个 401 都立刻刷新一次，否则并发接口会造成多次刷新和 token 覆盖。",
                script: "token 过期我会做单飞刷新：同一时间只刷新一次，其他请求排队。成功重试原请求，失败统一退出登录。"
            ),
            reviewItem(
                title: "登录态保存和退出",
                question: "登录态怎么保存？退出登录要清哪些东西？",
                standardAnswer: "敏感凭证如 access token、refresh token 放 Keychain，非敏感展示信息可放 UserDefaults 或数据库。退出登录要清 token、用户信息、接口缓存、图片或业务缓存、通知状态，并回到登录页。",
                projectScenario: "启动时读 Keychain 判断是否有 token，再校验过期时间或请求用户信息。退出登录时删除 Keychain 凭证，清内存用户对象，取消未完成请求并重置根页面。",
                followUp: "追问：Keychain 卸载后还在吗？答：可能还在，所以首次安装或退出登录要有明确清理策略。",
                pitfall: "不要把 token 放 UserDefaults，也不要退出登录只跳页面不清数据，容易账号串用。",
                script: "登录态我会分层保存：凭证进 Keychain，展示信息另存。退出时清凭证、用户状态、缓存和未完成请求，再统一切回登录态页面。"
            ),
            reviewItem(
                title: "列表分页刷新",
                question: "列表页怎么做分页、下拉刷新、上拉加载？",
                standardAnswer: "维护 page、pageSize、hasMore、isLoading。下拉刷新重置 page 和数据源，上拉加载下一页，成功后追加数据，失败时回退页码或保持状态，最后结束刷新动画。",
                projectScenario: "订单列表第一页失败展示错误页，第一页为空展示空态，加载更多失败只提示不清空已有数据，没有更多时隐藏 footer 或显示没有更多。",
                followUp: "追问：分页数据重复怎么办？答：用稳定 id 去重，刷新和加载更多分开处理，接口最好返回 cursor 或 hasMore。",
                pitfall: "不要在上拉失败时把整个列表清空，也不要忘记处理并发加载导致页码错乱。",
                script: "分页我会维护页码、加载状态和是否还有更多。刷新重置，加载更多追加，失败保留旧数据。"
            ),
            reviewItem(
                title: "列表卡顿优化",
                question: "列表出现卡顿，你怎么优化？",
                standardAnswer: "先用工具确认瓶颈，再减少主线程工作。常见方向：cell 轻量化、减少层级、图片后台解码和下采样、高度缓存、局部刷新、预加载、避免 cellForRowAt 做复杂计算。",
                projectScenario: "商品列表滑动掉帧，用 Time Profiler 看到主线程同步解码大图和计算富文本。后来做图片下采样、富文本预计算和高度缓存，滑动稳定很多。",
                followUp: "追问：怎么证明优化有效？答：对比优化前后的 FPS、主线程耗时、内存峰值和用户反馈。",
                pitfall: "不要一上来就说异步绘制。先讲定位，再讲针对性优化。",
                script: "列表卡顿我会先测再改。通常从主线程、图片、布局、高度和刷新范围入手，优化后用 FPS 和 Time Profiler 对比。"
            ),
            reviewItem(
                title: "cell 图片错乱",
                question: "cell 图片错乱、重复请求、闪烁怎么解决？",
                standardAnswer: "复用时先设置占位图，取消旧请求；图片回调时校验 URL 或 modelID 是否仍匹配当前 cell；图片组件做内存和磁盘缓存，避免重复下载。",
                projectScenario: "商品列表快速滑动时头像错乱，后来在 prepareForReuse 里取消请求并清占位，回调里判断 currentImageURL，问题消失。",
                followUp: "追问：为什么会错乱？答：cell 被复用后旧请求才返回，旧图片设置到了新的 model 上。",
                pitfall: "不要只根据 indexPath 校验，因为插入、删除、排序后 indexPath 会变，稳定业务 id 更可靠。",
                script: "图片错乱本质是异步回调晚于 cell 复用。我会取消旧任务、设置占位、回调校验 modelID，并配合缓存。"
            ),
            reviewItem(
                title: "图片缓存设计",
                question: "图片缓存怎么设计？内存缓存和磁盘缓存怎么配合？",
                standardAnswer: "先查内存缓存，未命中查磁盘，磁盘未命中再下载。下载后按展示尺寸压缩或下采样，写入磁盘并回填内存。内存用 NSCache，磁盘放 Caches 目录并设置容量和过期清理。",
                projectScenario: "头像和商品图用 URL hash 作为 key，缩略图按目标尺寸缓存。大图不直接放内存，列表只加载缩略图，降低内存和解码压力。",
                followUp: "追问：为什么要按显示尺寸裁剪？答：原图太大，解码和渲染成本高，列表只需要显示尺寸对应的缩略图。",
                pitfall: "不要把原图直接塞进内存缓存，也不要把缓存放 Documents，缓存应该可清理且不参与备份。",
                script: "图片缓存一般是内存、磁盘、网络三级。列表里还要做取消、占位、下采样和回调校验。"
            ),
            reviewItem(
                title: "Crash 定位",
                question: "项目里遇到过 crash 吗？你怎么定位？",
                standardAnswer: "先看 crash 平台或日志，确认版本、机型、系统和崩溃线程。用 dSYM 符号化后看第一段业务代码，结合埋点和数据复现，修复后验证并观察线上指标。",
                projectScenario: "线上某列表偶发数组越界，符号化后定位到 cellForRowAt，发现接口返回空数组时仍读取第一个元素，最后加边界判断和空态兜底。",
                followUp: "追问：没有复现怎么办？答：加日志、埋点、保护代码，结合用户路径、接口数据和版本分布缩小范围。",
                pitfall: "不要只说看日志。要讲出符号化、崩溃线程、业务栈、复现和验证。",
                script: "Crash 我会先拿日志和 dSYM 符号化，找到崩溃线程里的业务代码，再结合数据和路径复现，修复后看线上指标是否下降。"
            ),
            reviewItem(
                title: "内存泄漏排查",
                question: "页面退出后不释放，你怎么查内存泄漏？",
                standardAnswer: "先在 deinit 打日志确认是否释放，再用 Xcode Memory Graph 看引用链，用 Instruments Leaks/Allocations 看泄漏和增长趋势。重点查闭包、Timer、Notification、delegate、单例缓存。",
                projectScenario: "详情页 pop 后 deinit 不走，Memory Graph 显示 ViewModel 的回调闭包持有 controller，最后 closure 改成 weak self 并在退出时取消请求。",
                followUp: "追问：没有工具怎么查？答：先加 deinit 日志，再逐个断开 Timer、通知、闭包、delegate、单例缓存，缩小范围。",
                pitfall: "不要只靠肉眼猜。先用 deinit 和工具确认引用链，效率更高。",
                script: "内存泄漏我会先确认 deinit，再看引用链。常查闭包、Timer、通知、delegate 和单例缓存，修复后重复进出页面验证。"
            ),
            reviewItem(
                title: "本地存储选型",
                question: "本地数据怎么存？UserDefaults、Keychain、文件、数据库分别放什么？",
                standardAnswer: "UserDefaults 放少量配置，Keychain 放 token 和密码类凭证，文件放图片、日志、JSON 缓存等大块数据，SQLite/CoreData 放结构化数据和复杂查询。",
                projectScenario: "access token 和 refresh token 放 Keychain，昵称头像等非敏感展示信息放 UserDefaults 或数据库，图片放 Caches，离线列表放数据库。",
                followUp: "追问：token 为什么不放 UserDefaults？答：UserDefaults 本质是偏好 plist，不适合保存敏感凭证，Keychain 有系统安全保护和访问控制。",
                pitfall: "不要把大 JSON、大数组、图片、token 都塞进 UserDefaults。它不是缓存库，也不是安全存储。",
                script: "我会按数据类型选存储：配置进 UserDefaults，凭证进 Keychain，大文件进 Caches，结构化数据进数据库。"
            ),
            reviewItem(
                title: "多线程与线程安全",
                question: "多线程用在哪些地方？怎么保证线程安全？",
                standardAnswer: "耗时任务、图片解码、文件读写、数据库操作、网络回调后的数据处理常放后台。共享可变状态要用串行队列、锁、actor 或主线程约束，UI 更新必须回主线程。",
                projectScenario: "图片下载后在后台队列解码和裁剪，完成后回主线程设置 UIImageView。缓存字典通过串行队列读写，避免多个线程同时修改。",
                followUp: "追问：只要异步就安全吗？答：不是。异步只是换执行时机，多个线程同时读写共享可变数据仍然有竞态。",
                pitfall: "不要在后台线程更新 UI，也不要多个线程直接改同一个数组或字典。",
                script: "项目里我会把耗时任务放后台，把 UI 更新放主线程。共享可变数据必须有访问边界，比如串行队列、锁或 actor。"
            )
        ]
    }

    private static func makeSecondTierItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "代理闭包通知",
                question: "代理、闭包、通知分别适合什么场景？",
                standardAnswer: "delegate 适合一对一、需要明确协议的回调；closure 适合简单局部回调，比如 cell 点击；Notification 适合一对多、跨模块广播，比如登录态变化。",
                projectScenario: "详情页回传选择结果用闭包，自定义输入框把事件回调给控制器用 delegate，退出登录后多个页面刷新状态用 Notification。",
                followUp: "追问：闭包为什么要 weak self？答：闭包被对象持有时，如果闭包又强持有 self，就会形成循环引用。",
                pitfall: "不要滥用通知。通知太多会导致调用链不清楚，调试困难。",
                script: "我按关系选：一对一复杂回调用代理，简单局部事件用闭包，跨模块一对多状态变化才用通知。"
            ),
            reviewItem(
                title: "第三方库选型",
                question: "你项目里用过哪些第三方库？为什么用？",
                standardAnswer: "回答库名、解决的问题、为什么不用手写、风险控制和替换方案。常见如 Alamofire、Kingfisher、SnapKit、MJRefresh、Masonry、FMDB、Realm 等。",
                projectScenario: "图片加载用 Kingfisher，因为它提供下载、内存缓存、磁盘缓存、取消和占位；项目里再封一层 ImageLoader，避免业务强依赖具体库。",
                followUp: "追问：第三方库有问题怎么办？答：先看 issue 和源码定位，必要时 fork 修复或替换库，业务层通过封装降低迁移成本。",
                pitfall: "不要只报库名。要说清解决了什么问题，以及你有没有二次封装和风险意识。",
                script: "我用第三方库会看稳定性、维护情况和团队成本。业务层尽量隔一层封装，后面换库时影响更小。"
            ),
            reviewItem(
                title: "URLSession / Alamofire 封装",
                question: "Alamofire / URLSession 请求怎么封装？",
                standardAnswer: "无论底层用什么，都要封装统一 API：baseURL、path、method、headers、parameters、超时、token、错误码、日志、解析和取消。页面不直接依赖底层实现。",
                projectScenario: "NetworkClient 暴露 request<T: Decodable>，内部可用 URLSession 或 Alamofire。业务只写 UserAPI.profile，不关心具体请求库。",
                followUp: "追问：Alamofire 和 URLSession 怎么选？答：小项目 URLSession 足够；需要拦截、上传下载、链式调用和成熟封装时 Alamofire 更省事。",
                pitfall: "不要把 Alamofire 的调用散落在每个 Controller，后期错误码、token、日志都难统一。",
                script: "我会把 URLSession 或 Alamofire 包在 NetworkClient 后面，页面只关心 API 和模型，不直接碰底层库。"
            ),
            reviewItem(
                title: "JSON 脏数据",
                question: "JSON 解析失败怎么处理脏数据？",
                standardAnswer: "模型字段尽量区分必需和可选。非核心字段用 Optional 或默认值，字段名用 CodingKeys，类型不稳定时可自定义 init 解码兼容，解析失败要记录日志并给页面兜底。",
                projectScenario: "后端有时把价格返回字符串，有时返回数字。客户端自定义 Price 解码，兼容 String 和 Double，避免整页解析失败。",
                followUp: "追问：所有字段都 Optional 好吗？答：不好。核心字段应该校验，非核心字段可以容错，否则脏数据会悄悄进入业务。",
                pitfall: "不要强制解包接口字段。中小公司接口变动频繁，客户端必须有容错边界。",
                script: "解析接口我会把核心字段和非核心字段分开处理，非核心字段容错，核心字段缺失就兜底并上报。"
            ),
            reviewItem(
                title: "统一错误处理",
                question: "接口报错怎么统一处理？",
                standardAnswer: "网络层区分网络错误、HTTP 状态码错误、业务错误码、解析错误和取消错误。公共错误统一处理，业务错误交给页面决定展示方式。",
                projectScenario: "无网络展示网络异常页，token 过期走刷新逻辑，服务器维护弹全局提示，表单校验错误在当前页面展示。",
                followUp: "追问：所有错误都弹 toast 可以吗？答：不合适。首屏失败适合错误页，分页失败适合底部提示，表单失败适合字段旁提示。",
                pitfall: "不要把所有错误都吞掉，也不要所有错误都弹窗。错误处理要结合页面状态。",
                script: "我会先在网络层把错误分类，再按场景展示。公共错误集中处理，业务错误留给页面做更合适的交互。"
            ),
            reviewItem(
                title: "重复点击和重复请求",
                question: "如何避免按钮重复点击、接口重复请求？",
                standardAnswer: "按钮层可以短时间禁用或节流；网络层可以按 request key 合并或取消重复请求；业务层用 loading 状态保护，提交类接口要以后端幂等为最终保障。",
                projectScenario: "支付按钮点击后立即禁用并显示 loading，请求结束再恢复；列表搜索输入使用 debounce；同一个详情接口重复进入时复用进行中的请求。",
                followUp: "追问：只靠前端禁用按钮够吗？答：不够。前端改善体验，真正的支付、下单要后端支持幂等号。",
                pitfall: "不要只用一个全局 loading 锁住所有请求。不同页面或不同接口需要分开控制。",
                script: "我会在 UI 层防重复点击，在网络层做请求去重，在提交类业务里配合后端幂等。"
            ),
            reviewItem(
                title: "弱网超时无网络",
                question: "弱网、超时、无网络怎么处理？",
                standardAnswer: "请求设置合理超时时间，无网络时提前提示，弱网失败支持重试。页面上区分首屏失败、分页失败和静默刷新失败；关键操作要明确告诉用户结果。",
                projectScenario: "首页首屏无网络展示错误页和重试按钮；上拉加载失败只提示并保留已有数据；提交订单超时后查询订单状态，避免重复下单。",
                followUp: "追问：所有接口都应该自动重试吗？答：不是。GET 查询可重试，支付、下单、提交表单要谨慎，最好配合幂等或状态查询。",
                pitfall: "不要超时后直接让用户重复提交关键操作，容易造成重复订单或重复支付。",
                script: "弱网处理我会分场景：查询接口可以重试，提交接口要谨慎。页面保留已有数据，给用户明确的失败和重试入口。"
            ),
            reviewItem(
                title: "启动优化",
                question: "App 启动慢怎么优化？",
                standardAnswer: "先区分冷启动和热启动，使用 Time Profiler 或启动埋点定位耗时。优化方向是减少 main 之前和 didFinishLaunching 里的重任务，延迟初始化 SDK，异步加载非首屏数据，减少首屏同步 IO。",
                projectScenario: "原来启动时初始化多个 SDK、读取大配置、请求广告。后来把非首屏 SDK 延迟到首页后，配置读取放后台，首屏时间明显下降。",
                followUp: "追问：启动优化怎么量化？答：埋点记录进程启动、didFinishLaunching、首屏 viewDidAppear 或首帧渲染时间。",
                pitfall: "不要凭感觉说优化了。启动优化一定要先测量，再针对最大耗时点处理。",
                script: "启动优化我会先埋点和用工具测，再把非必要初始化延后，把同步 IO 和大任务移出首屏路径。"
            ),
            reviewItem(
                title: "大图内存优化",
                question: "图片太大导致内存高怎么处理？",
                standardAnswer: "避免直接加载原图到内存。按显示尺寸下采样，后台解码，列表用缩略图，及时释放临时对象，缓存设置成本限制，大图预览按需加载。",
                projectScenario: "用户上传 4000 像素照片时，先按目标尺寸压缩再显示和上传，列表只展示缩略图，避免一次性解码多张原图导致内存飙升。",
                followUp: "追问：压缩和下采样区别？答：下采样是在解码阶段按目标尺寸生成小图，更适合减少内存峰值。",
                pitfall: "不要先 UIImage(data:) 解出原图再缩小，那时内存峰值已经上去了。",
                script: "大图处理我会按显示尺寸下采样，后台解码，列表只用缩略图，缓存也设置容量限制。"
            ),
            reviewItem(
                title: "页面状态设计",
                question: "如何做空页面、错误页面、loading 状态？",
                standardAnswer: "页面状态通常有 loading、content、empty、error、offline。首屏和局部加载要区分，失败时保留可用旧数据，空态给明确文案和操作入口。",
                projectScenario: "订单列表首屏请求中展示 loading，成功有数据展示列表，空数据展示空态，失败展示错误页和重试按钮，上拉失败只在底部提示。",
                followUp: "追问：为什么要状态机？答：状态清楚后，loading、空态、错误态不会互相覆盖，页面逻辑更稳定。",
                pitfall: "不要 loading、empty、error 几个 view 互相乱 hidden，最后容易出现重叠和状态错乱。",
                script: "我会把页面按状态管理：加载、内容、空、错误、无网络。首屏和分页分开处理，避免一个失败影响已有内容。"
            ),
            reviewItem(
                title: "H5 原生交互",
                question: "H5 和原生怎么交互？",
                standardAnswer: "常见方式是 WKWebView 加载页面，H5 通过 script message 调原生，原生通过 evaluateJavaScript 回调 H5。要统一 bridge 协议，校验方法名和参数，注意循环引用和安全白名单。",
                projectScenario: "活动页由 H5 实现，点击分享按钮时 H5 调用 nativeShare，原生弹系统分享；支付成功后原生回调 JS 通知 H5 刷新状态。",
                followUp: "追问：WKScriptMessageHandler 为什么可能内存泄漏？答：userContentController 会强持有 handler，handler 如果是 controller 容易循环引用，需要 weak 包装或移除。",
                pitfall: "不要让任意网页都能调用原生敏感能力。要限制域名、方法和参数。",
                script: "H5 交互我会用 WKWebView bridge，约定方法名和参数，原生负责能力实现，同时做好白名单和 handler 释放。"
            ),
            reviewItem(
                title: "权限处理",
                question: "推送、定位、相册、相机权限怎么处理？",
                standardAnswer: "先判断授权状态，未决定时请求权限，被拒绝时给出说明并引导去设置。权限请求要放在用户触发相关功能时，不要启动就一次性弹很多权限。",
                projectScenario: "用户点击上传头像时再请求相册权限；定位只在进入附近门店功能时请求；被拒绝后弹说明页，引导用户去系统设置开启。",
                followUp: "追问：为什么不启动就申请？答：用户不知道用途，拒绝率高，也不符合隐私最小化原则。",
                pitfall: "不要忘记 Info.plist 权限说明，也不要在权限拒绝后反复弹无意义提示。",
                script: "权限我会按需申请，先说明用途，再请求权限。拒绝后不强打扰，只在用户再次使用功能时引导去设置。"
            ),
            reviewItem(
                title: "支付分享登录 SDK",
                question: "支付、分享、登录 SDK 接入过吗？遇到过什么坑？",
                standardAnswer: "接入 SDK 要关注平台配置、URL Scheme、Universal Link、回调处理、签名参数、支付结果二次校验、错误码和审核合规。",
                projectScenario: "微信支付调起成功但回调失败，最后发现 URL Scheme 和 Associated Domains 配置不一致。支付结果以服务端查询为准，客户端回调只做体验提示。",
                followUp: "追问：支付成功回调就能发货吗？答：不能，只能作为参考，必须以服务端验签或订单查询结果为准。",
                pitfall: "不要只依赖客户端回调判断支付成功，也不要把敏感签名逻辑放客户端。",
                script: "SDK 接入我会先核对平台配置和回调链路。支付这类关键业务一定以后端验签或订单状态为准。"
            ),
            reviewItem(
                title: "上架证书",
                question: "App 上架、证书、描述文件有没有处理过？",
                standardAnswer: "可以说清证书、Bundle ID、Provisioning Profile、开发/发布环境、Archive、TestFlight、App Store Connect。即使不是主负责人，也要知道基本流程和常见问题。",
                projectScenario: "测试包用 Development 或 Ad Hoc，正式包用 Distribution 证书和 App Store 描述文件，Archive 后上传 TestFlight，测试通过后提交审核。",
                followUp: "追问：推送证书和 bundle id 有什么关系？答：推送能力绑定 App ID，需要开启 Push Notifications，并使用匹配的 profile。",
                pitfall: "不要硬说自己全负责但答不出证书类型。可以诚实说参与过打包或协助处理。",
                script: "我参与过打包上架流程，知道证书、描述文件、Bundle ID 和 TestFlight 的关系。签名问题会先检查 target、profile、证书和 capability。"
            ),
            reviewItem(
                title: "Git 协作冲突",
                question: "Git 冲突怎么解决？多人协作怎么做？",
                standardAnswer: "开发前拉最新代码，功能分支开发，小步提交。冲突时先理解双方改动，再手动合并并编译验证。合并后跑关键流程，避免只解决文本冲突不验证业务。",
                projectScenario: "两个人同时改订单页，一个改 UI，一个改接口字段。解决冲突时保留新 UI 结构，同时接入新的 model 字段，最后跑订单列表和详情流程。",
                followUp: "追问：会不会直接用 ours/theirs？答：只有明确知道对方改动不需要时才用，大多数业务代码要逐块看。",
                pitfall: "不要用强制覆盖解决冲突，也不要提交无法编译的代码。",
                script: "冲突我会先看双方意图，再手动合并，最后必须编译和跑关键流程。Git 冲突解决完不代表业务就没问题。"
            )
        ]
    }

    private static func makeProjectExperienceItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "最难问题",
                question: "你项目中遇到过最难的问题是什么？",
                standardAnswer: "用现象、排查、定位、解决、结果五步回答。适合说线上 crash、列表卡顿、内存泄漏、token 并发刷新、图片内存过高。",
                projectScenario: "详情页退出后内存不下降。先在 deinit 打日志确认没释放，再用 Memory Graph 看引用链，发现 Timer 的闭包持有 self，最后改 weak self 并 invalidate。",
                followUp: "追问：怎么证明修好了？答：重复进出页面，deinit 正常打印；Allocations 曲线稳定；线上对应问题不再出现。",
                pitfall: "不要回答接口调不通这种太弱的问题。要选能体现排查能力、工具意识和结果验证的问题。",
                script: "我会按现象、排查、定位、解决、结果来讲。比如页面不释放，我先确认 deinit，再看引用链，定位到 Timer 闭包，修复后反复验证。"
            ),
            reviewItem(
                title: "独立完整功能",
                question: "你有没有独立负责过一个完整功能？",
                standardAnswer: "回答一个具体功能，说明需求理解、接口约定、UI 实现、数据流、异常处理、测试回归和上线后跟踪。重点突出你不是只写了一个按钮。",
                projectScenario: "独立做过订单列表：支持状态筛选、分页、下拉刷新、空态、订单详情跳转、取消订单后的局部刷新，以及 token 过期时自动重新登录。",
                followUp: "追问：怎么保证质量？答：自测主流程和异常流程，和后端对齐字段，测试环境回归分页、空数据、失败、重复点击等场景。",
                pitfall: "不要选太小的功能，比如改文字、加埋点。最好选登录、列表、详情、支付、上传、消息这类完整链路。",
                script: "我独立负责过完整业务模块，不只是写 UI，也包括接口联调、状态管理、异常兜底和上线后的问题跟进。"
            ),
            reviewItem(
                title: "性能优化结果",
                question: "有没有做过性能优化？优化前后有什么效果？",
                standardAnswer: "要讲清优化对象、量化指标、定位工具、具体改动和结果。常见指标包括启动时间、FPS、主线程耗时、内存峰值、崩溃率。",
                projectScenario: "商品列表卡顿，优化前快速滑动明显掉帧。用 Time Profiler 定位到图片解码和富文本计算，优化后主线程耗时下降，滑动更稳定。",
                followUp: "追问：有没有数据？答：可以说优化前后 FPS、首屏耗时或内存峰值的对比，即使是粗略值也比纯感觉强。",
                pitfall: "不要只说做了缓存、异步加载。要说为什么做、怎么验证有效。",
                script: "我做性能优化会先定位瓶颈，再做针对性改动，最后用指标对比。没有数据的优化很难说明价值。"
            ),
            reviewItem(
                title: "线上问题",
                question: "有没有处理过线上问题？",
                standardAnswer: "线上问题要按影响范围、版本分布、日志定位、临时止损、修复发布、后续预防来讲。中小公司很看重你是否有闭环意识。",
                projectScenario: "某版本登录后偶发跳回登录页。通过日志发现 refresh token 并发刷新导致旧 token 覆盖新 token，修复为单飞刷新并加失败兜底。",
                followUp: "追问：线上不能马上发版怎么办？答：看是否能通过服务端配置、开关、降级或热修复止损，不能就尽快发审核并监控。",
                pitfall: "不要只说修了 bug。线上问题要强调影响、定位、止损和复盘。",
                script: "线上问题我会先确认影响范围和版本，再定位根因，必要时先做降级止损，修复后继续观察指标并补预防措施。"
            ),
            reviewItem(
                title: "代码重构",
                question: "有没有重构过代码？为什么重构？怎么保证不出问题？",
                standardAnswer: "重构原因通常是 Controller 太重、重复代码多、职责混乱、难测试。保证方式是小步提交、保留外部行为、补关键用例、灰度验证和回归主流程。",
                projectScenario: "把订单模块的网络请求、状态处理和 cell model 从 Controller 拆到 ViewModel/Service，外部页面流程不变，只调整内部职责。",
                followUp: "追问：重构和重写区别？答：重构是不改变外部行为的内部优化，重写是重新实现，风险更高。",
                pitfall: "不要为了好看而大改。重构必须有明确收益和验证方式。",
                script: "我重构会控制范围，小步改动，保证外部行为不变。每一步都能编译和回归，避免一次性推倒重来。"
            ),
            reviewItem(
                title: "设计不足反思",
                question: "你觉得项目里哪里设计得不好？如果重来你会怎么改？",
                standardAnswer: "可以挑一个真实但不致命的问题，比如网络错误处理分散、Controller 过重、缓存策略不统一、埋点缺少规范。回答要带改进方案。",
                projectScenario: "以前错误处理散在各页面，导致 toast 文案不统一。重来会在网络层做错误分类，页面只处理业务展示，并沉淀统一错误视图。",
                followUp: "追问：为什么当时没这么做？答：早期需求变化快，先保证交付；后面业务稳定后再逐步抽象。",
                pitfall: "不要把锅全甩给前同事或后端。要体现你能复盘，也能给可落地方案。",
                script: "我会选一个真实问题讲，比如错误处理分散。然后说明如果重来，会先统一错误模型和页面状态，让后续维护更稳定。"
            ),
            reviewItem(
                title: "后端联调",
                question: "你如何和后端联调接口？",
                standardAnswer: "先对齐接口文档、请求参数、错误码和数据类型。联调用 Charles/Proxyman 或日志看请求响应，有问题带着具体参数、响应和复现路径沟通。",
                projectScenario: "登录接口返回字段和文档不一致，抓包截图后和后端确认，最终约定字段类型和空值规则，客户端也增加了容错。",
                followUp: "追问：接口还没好怎么开发？答：先用 mock 数据或本地 JSON，把 UI 和流程跑通，接口好后再替换真实请求。",
                pitfall: "不要只说后端接口有问题。要拿证据沟通，别空口描述。",
                script: "联调我会先对文档，再抓包确认真实数据。遇到问题用请求参数、响应和复现路径沟通，效率更高。"
            ),
            reviewItem(
                title: "字段经常变",
                question: "接口字段经常变，你怎么降低影响？",
                standardAnswer: "客户端模型要做可选值、默认值和兼容解码；网络层记录解析错误；展示层有兜底文案。更重要的是推动接口文档、版本管理和字段变更通知。",
                projectScenario: "用户等级字段从 Int 改成 String，客户端自定义解码兼容两种类型，同时和后端约定后续字段变更必须同步文档。",
                followUp: "追问：字段缺失页面怎么办？答：非核心字段展示默认值或隐藏模块，核心字段缺失走错误兜底并上报。",
                pitfall: "不要为了兼容把所有字段都 Optional 后完全不校验，脏数据会进入业务流程。",
                script: "字段变化我会在客户端做容错，但不会只靠容错解决。还要推动接口文档和变更流程，避免反复踩坑。"
            ),
            reviewItem(
                title: "临时改需求",
                question: "产品临时改需求，你怎么处理？",
                standardAnswer: "先确认变更范围、影响页面、接口依赖、风险和排期。小改动可以快速调整，大改动要同步风险和时间，必要时拆成本期必须和后续优化。",
                projectScenario: "上线前产品要求订单列表新增筛选条件。先确认接口是否支持，再评估 UI、缓存、分页和埋点影响，最终先上线基础筛选，复杂排序放下一版。",
                followUp: "追问：产品很急怎么办？答：先把风险说清楚，给可交付方案，而不是直接拒绝或盲目答应。",
                pitfall: "不要情绪化说不做。中小公司节奏快，关键是评估影响并给方案。",
                script: "临时需求我会先评估影响，再给方案和风险。能安全做就做，风险大就拆版本，保证上线质量。"
            ),
            reviewItem(
                title: "代码交接",
                question: "你离职/换工作后，别人接手你的代码是否方便？",
                standardAnswer: "方便接手的代码要职责清楚、命名清晰、关键流程有文档、接口和配置有说明、复杂逻辑有必要注释，并且没有强依赖个人本地环境。",
                projectScenario: "订单模块交接时整理了页面入口、接口列表、状态流转、常见问题和打包注意事项，新同事按文档能快速跑通主流程。",
                followUp: "追问：代码注释是不是越多越好？答：不是。清晰命名优先，注释只解释复杂业务规则和容易踩坑的地方。",
                pitfall: "不要说我代码别人一看就懂。最好讲具体做过哪些交接文档或规范。",
                script: "我会尽量让代码职责清楚、命名明确。复杂业务会补文档和必要注释，交接时把入口、流程、接口和坑点说明白。"
            )
        ]
    }

    private static func makeIOSBasicsItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "weak self",
                question: "为什么闭包里要写 [weak self]？",
                standardAnswer: "当对象强持有闭包，闭包又强捕获 self 时会形成循环引用。用 weak self 可以避免闭包延长控制器生命周期，适合网络回调、cell 回调、Timer、动画完成回调等场景。",
                projectScenario: "详情页 ViewModel 有回调 closure，Controller 持有 ViewModel，ViewModel 持有 closure，如果 closure 里强用 self，页面 pop 后 deinit 不走。",
                followUp: "追问：是不是所有闭包都要 weak self？答：不是。非逃逸闭包或生命周期很短的闭包不一定需要，关键看是否形成持有环。",
                pitfall: "不要机械加 weak self 后不处理 self 为 nil 的分支。关键逻辑要想清楚对象释放后的行为。",
                script: "我写 weak self 是为了打断持有环。是否需要看闭包是否逃逸、谁持有闭包、闭包里是否反过来持有 self。"
            ),
            reviewItem(
                title: "delegate weak",
                question: "delegate 为什么一般用 weak？",
                standardAnswer: "delegate 通常是反向通知关系，被委托对象不应该拥有委托方。用 weak 可以避免 A 持有 B，B 的 delegate 又强持有 A 造成循环引用。",
                projectScenario: "Controller 持有自定义 View，自定义 View 的 delegate 指回 Controller。如果 delegate 是 strong，Controller 和 View 会互相持有。",
                followUp: "追问：protocol 为什么要 AnyObject？答：weak 只能用于 class 实例，协议继承 AnyObject 后才能声明 weak delegate。",
                pitfall: "不要把 delegate 写成 strong。除非是特殊所有权设计，否则会有泄漏风险。",
                script: "delegate 表达的是非拥有关系，所以一般 weak。View 可以回调 Controller，但不应该决定 Controller 的生命周期。"
            ),
            reviewItem(
                title: "struct / class model",
                question: "struct 和 class 在 model 里怎么选？",
                standardAnswer: "普通网络 model、展示 model 优先 struct，因为值语义简单、安全、适合 Codable。需要身份、共享可变状态、继承、引用语义或和 OC 框架交互时选 class。",
                projectScenario: "接口返回的 UserDTO、OrderCellModel 用 struct；需要被多个页面共享并持续修改的登录用户状态，可以用 class 或统一状态管理对象。",
                followUp: "追问：Array 是值类型为什么性能还行？答：Swift 集合有写时复制，读和传递时不会每次都深拷贝，写入时才复制。",
                pitfall: "不要所有 model 都 class。引用语义会让状态被多处修改，排查更难。",
                script: "我一般网络和展示模型用 struct，状态共享或需要身份的对象用 class。选择核心看值语义还是引用语义。"
            ),
            reviewItem(
                title: "Codable 坑点",
                question: "Codable 解析接口有什么坑？",
                standardAnswer: "常见坑有字段缺失、null、字段名不一致、类型不稳定、日期格式不同、嵌套结构变化。可以用 Optional、CodingKeys、自定义 init、默认值和解码策略处理。",
                projectScenario: "后端有时返回 user_id，有时返回 userId，客户端用 CodingKeys 统一映射；时间字段用 dateDecodingStrategy 或自定义 DateFormatter。",
                followUp: "追问：decodeIfPresent 有什么用？答：字段缺失或 null 时返回 nil，适合非必需字段。",
                pitfall: "不要对接口字段强制解包，也不要让一个非核心字段解析失败导致整页不可用。",
                script: "Codable 好用，但接口不稳定时要做容错。字段名、可选值、类型兼容和日期格式是我最先检查的几个点。"
            ),
            reviewItem(
                title: "RunLoop 项目体现",
                question: "RunLoop 在项目里哪里能体现？",
                standardAnswer: "RunLoop 负责线程事件循环，项目里常见在 Timer、滑动模式、主线程事件处理、常驻线程、卡顿监控中体现。滚动时 RunLoop mode 会影响 Timer 和部分任务执行时机。",
                projectScenario: "列表快速滑动时默认模式 Timer 可能不触发，如果需要滚动中继续触发，可以加入 common modes。卡顿监控也可以通过监听主线程 RunLoop 状态判断耗时。",
                followUp: "追问：RunLoop 和线程关系？答：每个线程都可以有 RunLoop，主线程默认开启，子线程需要自己配置 source 或 timer 才能常驻。",
                pitfall: "不要把 RunLoop 说成线程。它是线程上的事件循环机制。",
                script: "项目里 RunLoop 主要体现在 Timer、滚动模式、卡顿监控和线程保活。面试讲这些就比较落地。"
            ),
            reviewItem(
                title: "主线程耗时",
                question: "主线程为什么不能做耗时任务？",
                standardAnswer: "主线程负责事件响应、布局、绘制和动画。如果在主线程做大 JSON 解析、图片解码、文件 IO、复杂计算，就会阻塞一帧渲染，表现为卡顿、掉帧甚至无响应。",
                projectScenario: "列表 cellForRowAt 里同步解码图片和计算富文本，快速滑动掉帧。改成后台预处理后，主线程只做轻量绑定。",
                followUp: "追问：所有任务都放后台吗？答：不是。UI 更新必须主线程，后台处理完再回主线程刷新。",
                pitfall: "不要在后台线程直接改 UI，也不要把数据安全问题藏进异步里。",
                script: "主线程要保持轻量，负责 UI 和交互。耗时计算、IO、图片解码放后台，完成后再回主线程更新界面。"
            ),
            reviewItem(
                title: "async/await 和回调",
                question: "async/await 和回调有什么区别？",
                standardAnswer: "回调通过 closure 传结果，层级深时容易回调嵌套和状态分散。async/await 让异步代码写起来像同步流程，错误用 throws 传递，也更方便和 Task 取消结合。",
                projectScenario: "登录流程先请求 token，再请求用户信息，再进首页。用回调会嵌套多层，用 async/await 可以按顺序写，失败统一 catch。",
                followUp: "追问：async/await 会自动到后台线程吗？答：不会。它是异步模型，不等于开新线程；UI 相关代码仍要关注 MainActor。",
                pitfall: "不要把 async/await 当作性能优化本身。它主要改善异步代码结构，耗时任务仍要合理调度。",
                script: "async/await 让异步流程更直观，错误和取消也更好处理。但它不等于自动多线程，UI 更新仍要回主线程或 MainActor。"
            ),
            reviewItem(
                title: "Timer 不释放",
                question: "Timer 为什么可能导致页面不释放？",
                standardAnswer: "Timer 会被 RunLoop 持有，如果 Timer 的 target 或 block 又强持有 self，就会形成 RunLoop 持有 Timer，Timer 持有 self 的链路，导致控制器不释放。",
                projectScenario: "倒计时页面 pop 后 deinit 不走，原因是 scheduledTimer 的 block 里强用 self。改成 weak self，并在 deinit 或页面消失时 invalidate。",
                followUp: "追问：CADisplayLink 呢？答：类似，也会持有 target，需要 invalidate，或用 weak proxy 打断引用。",
                pitfall: "不要只写 weak self 却忘记 invalidate。Timer 仍可能继续运行，造成无意义回调。",
                script: "Timer 泄漏常见链路是 RunLoop 持有 Timer，Timer 持有 self。我会 weak self 加 invalidate 一起处理。"
            ),
            reviewItem(
                title: "Notification 移除",
                question: "Notification 需要移除吗？",
                standardAnswer: "selector 方式在现代系统里通知中心会做一定自动清理，但 block 方式会返回 token，必须管理 token 生命周期。项目里建议明确移除，尤其是 block 观察和跨生命周期对象。",
                projectScenario: "登录状态变化用 Notification 广播，页面 deinit 时移除观察者；block 方式保存 observer token，在 deinit 里 removeObserver。",
                followUp: "追问：不移除会怎样？答：可能造成重复回调、对象无法释放或野回调，尤其 block 方式更明显。",
                pitfall: "不要在 add 多次后只 remove 一次，容易重复响应。要管理好观察者注册时机。",
                script: "通知我会按生命周期管理。block 方式一定保存 token 并移除，selector 方式也倾向明确移除，避免重复和调试困难。"
            ),
            reviewItem(
                title: "KVO 项目使用",
                question: "KVO 你在项目里遇到过吗？",
                standardAnswer: "KVO 常用于观察系统对象属性，比如 contentOffset、operation 状态、AVPlayerItem 状态等。它底层通过动态子类和 isa-swizzling 实现，使用时要注意生命周期和移除。",
                projectScenario: "视频播放页观察 AVPlayerItem 的 status 和 loadedTimeRanges，更新 loading 和进度；退出页面时移除观察，避免回调到已释放对象。",
                followUp: "追问：Swift 中 KVO 有什么限制？答：通常需要 NSObject、@objc dynamic，纯 Swift struct 不支持传统 KVO。",
                pitfall: "不要对所有业务状态都用 KVO。新代码可以优先用闭包、delegate、Combine、Observation 或 async stream。",
                script: "我遇到 KVO 多是在系统框架里，比如播放器和滚动状态。业务代码会谨慎用，重点管理好观察者生命周期。"
            )
        ]
    }
}
