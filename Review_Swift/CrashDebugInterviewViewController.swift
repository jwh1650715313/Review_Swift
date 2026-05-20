//
//  CrashDebugInterviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/20.
//

import UIKit

final class CrashDebugInterviewViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "崩溃与问题排查",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "崩溃与问题排查",
            modules: Self.makeModules()
        )
    }

    private static func makeModules() -> [InterviewReviewModule] {
        [
            InterviewReviewModule(
                id: "hardest-problem",
                title: "遇到最难的问题是什么？",
                subtitle: "别说太简单，按现象、排查、定位、解决、结果回答",
                symbolName: "flame.fill",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: [
                    reviewItem(
                        title: "线上疑难问题回答框架",
                        question: "你在项目中遇到过最难的问题是什么？",
                        coreAnswer: "不要回答按钮错位、接口字段写错这类太简单的问题。更适合说线上 crash、卡顿、内存泄漏。回答时一定带上：现象、排查、定位、解决、结果。",
                        mnemonic: "五步法：现象、排查、定位、解决、结果。",
                        followUp: "追问：你怎么证明问题解决了？答：复现路径不再崩、线上 crash 率下降、灰度版本监控稳定。",
                        projectScenario: "线上某版本详情页偶发 crash，用户反馈进入页面后闪退。先看 crash 平台，发现集中在某个数组取值逻辑，最后加边界保护并补充兜底展示。",
                        debugSteps: "1. 先描述影响范围。\n2. 查 crash 日志和版本分布。\n3. 符号化后看崩溃线程。\n4. 本地按数据和路径复现。\n5. 修复后回归、灰度、观察指标。",
                        codeExample: """
                        let items = dataSource

                        if indexPath.row < items.count {
                            cell.textLabel?.text = items[indexPath.row].title
                        } else {
                            cell.textLabel?.text = "数据加载中"
                        }
                        """
                    )
                ]
            ),
            InterviewReviewModule(
                id: "crash-debug",
                title: "怎么排查 crash？",
                subtitle: "日志、dSYM、崩溃线程、调用栈、复现、修复验证",
                symbolName: "cross.case.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: [
                    reviewItem(
                        title: "Crash 标准排查链路",
                        question: "线上或本地 crash 你一般怎么排查？",
                        coreAnswer: "先拿 crash 日志，再用对应版本 dSYM 符号化。重点看崩溃线程和调用栈，确认异常类型、崩溃方法和业务路径。能复现就本地复现，不能复现就结合日志、埋点、版本和机型缩小范围。",
                        mnemonic: "Crash：日志、符号、线程、栈、复现、修复。",
                        followUp: "追问：为什么要符号化？答：未符号化只有地址，看不出具体类和方法；dSYM 能把地址还原成函数名和行号。",
                        projectScenario: "线上 crash 平台只显示地址时，先找 AppStore 或 CI 产物里的 dSYM，符号化后看到崩在 cellForRowAt 的数组访问，再回到业务数据定位。",
                        debugSteps: "1. 看异常类型：NSRangeException、EXC_BAD_ACCESS、SIGABRT。\n2. 确认 app 版本、系统、机型。\n3. dSYM 符号化。\n4. 看 crashed thread。\n5. 从调用栈往上找第一段业务代码。\n6. 本地复现并修复。\n7. 加日志、单测或保护后验证。",
                        codeExample: """
                        // 常见符号化命令思路
                        atos -arch arm64 \\
                            -o MyApp.app.dSYM/Contents/Resources/DWARF/MyApp \\
                            -l 0x100000000 \\
                            0x100123abc
                        """
                    )
                ]
            ),
            InterviewReviewModule(
                id: "crash-types",
                title: "常见 crash 类型有哪些？",
                subtitle: "数组越界、nil、野指针、KVO、多线程、selector、字典 nil",
                symbolName: "exclamationmark.triangle.fill",
                tintColor: InterviewReviewStyle.accentColors[2],
                items: [
                    reviewItem(
                        title: "高频 Crash 类型速记",
                        question: "iOS 项目里常见 crash 类型有哪些？",
                        coreAnswer: "高频类型包括：数组越界、强制解包 nil、野指针、KVO 未移除或重复移除、多线程同时读写数据、selector 找不到、字典插入 nil。",
                        mnemonic: "越界、解包、野指针；KVO、线程、找不到、nil。",
                        followUp: "追问：Swift 还会数组越界吗？会，直接下标越界会触发 fatal error。Optional 强制解包 nil 也会崩。",
                        projectScenario: "接口返回空数组，但页面默认取第一个 banner；测试环境数据完整没暴露，线上部分用户数据为空导致崩溃。",
                        debugSteps: "1. 看异常名和崩溃栈。\n2. 数组越界看 index 和 count。\n3. nil 崩溃看 Optional 来源。\n4. selector 崩溃看 target-action 和方法名。\n5. KVO 看 add/remove 生命周期。\n6. 多线程问题看是否并发修改集合。",
                        codeExample: """
                        if let first = banners.first {
                            showBanner(first)
                        } else {
                            showPlaceholder()
                        }

                        if object.responds(to: selector) {
                            object.perform(selector)
                        }
                        """
                    )
                ]
            ),
            InterviewReviewModule(
                id: "memory-leak",
                title: "怎么定位内存泄漏？",
                subtitle: "Leaks、Allocations、Memory Graph、引用链、weak self",
                symbolName: "memorychip.fill",
                tintColor: InterviewReviewStyle.accentColors[3],
                items: [
                    reviewItem(
                        title: "内存泄漏排查套路",
                        question: "页面退出后不释放，你怎么定位内存泄漏？",
                        coreAnswer: "先确认页面真的退出，再看 deinit 有没有执行。用 Xcode Memory Graph 查引用链，用 Instruments Leaks 看泄漏，用 Allocations 看对象数量是否持续增长。重点查循环引用、闭包 capture list、Timer、Notification、delegate。",
                        mnemonic: "泄漏：退出页面，看 deinit，看引用链。",
                        followUp: "追问：Memory Graph 和 Leaks 区别？答：Memory Graph 适合看谁持有谁；Leaks 适合找系统判断出的泄漏对象；Allocations 看增长趋势。",
                        projectScenario: "详情页 pop 后 deinit 不走，Memory Graph 看到 Timer 的 block 持有 self，Timer 又被 RunLoop 持有，所以控制器一直释放不了。",
                        debugSteps: "1. 在 deinit 打日志。\n2. 进入页面再退出。\n3. deinit 不走就打开 Memory Graph。\n4. 找 ViewController 的引用链。\n5. 检查 closure、Timer、Notification、delegate、单例缓存。\n6. 改 weak self 或主动断开引用。\n7. 再次退出确认 deinit 执行。",
                        codeExample: """
                        private var timer: Timer?

                        timer = Timer.scheduledTimer(
                            withTimeInterval: 1,
                            repeats: true
                        ) { [weak self] _ in
                            self?.refresh()
                        }

                        deinit {
                            timer?.invalidate()
                        }
                        """
                    )
                ]
            ),
            InterviewReviewModule(
                id: "instruments",
                title: "Instruments 用过吗？",
                subtitle: "Time Profiler、Leaks、Allocations、Network、Energy",
                symbolName: "gauge.with.dots.needle.67percent",
                tintColor: InterviewReviewStyle.accentColors[4],
                items: [
                    reviewItem(
                        title: "Instruments 面试回答",
                        question: "你用过 Instruments 吗？分别用来查什么？",
                        coreAnswer: "用过。Time Profiler 查主线程耗时和卡顿；Leaks 查内存泄漏；Allocations 查内存增长和对象分配；Network 查请求；Energy 查耗电。",
                        mnemonic: "Time 查卡顿，Leaks 查泄漏，Allocations 看增长，Network 看请求，Energy 看耗电。",
                        followUp: "追问：Time Profiler 怎么看？答：先录制问题场景，勾选主线程和调用树，重点看耗时最高的业务方法。",
                        projectScenario: "列表滑动卡顿时，用 Time Profiler 发现主线程同步解码大图和计算富文本，改成后台处理加缓存后掉帧明显减少。",
                        debugSteps: "1. 选择对应模板。\n2. 真机运行并录制问题路径。\n3. 过滤主线程或业务模块。\n4. 找耗时最高或增长最快的方法。\n5. 优化后再次录制对比。",
                        codeExample: """
                        let start = CFAbsoluteTimeGetCurrent()
                        renderLargeImage()
                        let cost = CFAbsoluteTimeGetCurrent() - start
                        print("render cost:", cost)
                        """
                    )
                ]
            ),
            InterviewReviewModule(
                id: "project-answer",
                title: "项目中怎么回答？",
                subtitle: "背一个页面不释放的模板，面试现场直接套",
                symbolName: "text.badge.checkmark",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: [
                    reviewItem(
                        title: "可直接背的项目模板",
                        question: "请结合项目说一次你排查内存或 crash 的经历。",
                        coreAnswer: "我之前遇到过一个页面退出后没有释放的问题，通过 Xcode Memory Graph 发现 ViewController 没有 deinit，继续看引用链发现是 Timer 强引用 self，最后改成 weak self，并在 deinit 里 invalidate timer，问题解决。",
                        mnemonic: "先讲现象，再讲工具，再讲引用链，最后讲结果。",
                        followUp: "追问：如果没有 Memory Graph 怎么查？答：先加 deinit 日志，再逐个断开 Timer、通知、闭包、delegate、单例缓存，缩小范围。",
                        projectScenario: "页面反复进出后内存上涨，退回首页也不下降。修复后重复进出 20 次，控制器能正常 deinit，Allocations 曲线稳定。",
                        debugSteps: "1. 加 deinit 日志确认不释放。\n2. 打开 Memory Graph 搜索控制器。\n3. 找到 Timer -> closure -> self 引用链。\n4. 闭包改 [weak self]。\n5. deinit 里 invalidate。\n6. 重复进出页面验证。",
                        codeExample: """
                        final class DetailViewController: UIViewController {
                            private var timer: Timer?

                            override func viewDidLoad() {
                                super.viewDidLoad()
                                timer = Timer.scheduledTimer(
                                    withTimeInterval: 1,
                                    repeats: true
                                ) { [weak self] _ in
                                    self?.reloadStatus()
                                }
                            }

                            deinit {
                                timer?.invalidate()
                                print("DetailViewController deinit")
                            }
                        }
                        """
                    )
                ]
            ),
            InterviewReviewModule(
                id: "must-remember",
                title: "必背口诀",
                subtitle: "Crash、泄漏、卡顿、Instruments 四组高频口令",
                symbolName: "bolt.shield.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: [
                    reviewItem(
                        title: "10 分钟复习口诀",
                        question: "崩溃与排查类问题，最后怎么快速总结？",
                        coreAnswer: "Crash 看日志、符号、线程、栈、复现、修复；泄漏看退出页面、deinit、引用链；卡顿看主线程、耗时任务、图片、布局、刷新；Instruments 用 Time Profiler 查卡顿，Leaks 查泄漏。",
                        mnemonic: "Crash 六字：日志、符号、线程、栈、复现、修复。",
                        followUp: "追问：排查顺序为什么重要？答：先用日志和工具缩小范围，再复现和修复，避免凭感觉改代码。",
                        projectScenario: "面试最后可以补一句：我会优先用工具定位，再结合日志、埋点和复现路径验证，不会只靠猜。",
                        debugSteps: "Crash：日志 -> 符号 -> 线程 -> 调用栈 -> 复现 -> 修复。\n泄漏：退出页面 -> 看 deinit -> 看引用链。\n卡顿：主线程 -> 耗时任务 -> 图片 -> 布局 -> 刷新。\n工具：Time Profiler -> Leaks -> Allocations。",
                        codeExample: """
                        let crashChecklist = ["日志", "符号", "线程", "栈", "复现", "修复"]
                        let leakChecklist = ["退出页面", "deinit", "引用链"]
                        let lagChecklist = ["主线程", "耗时任务", "图片", "布局", "刷新"]

                        print(crashChecklist.joined(separator: " -> "))
                        """
                    )
                ]
            )
        ]
    }

    private static func reviewItem(
        title: String,
        question: String,
        coreAnswer: String,
        mnemonic: String,
        followUp: String,
        projectScenario: String,
        debugSteps: String,
        codeExample: String
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
                    title: "核心答案",
                    body: coreAnswer,
                    symbolName: "checkmark.seal.fill"
                ),
                InterviewReviewRow(
                    title: "口诀",
                    body: mnemonic,
                    symbolName: "bolt.fill",
                    isMemoryLine: true
                ),
                InterviewReviewRow(
                    title: "常见追问",
                    body: followUp,
                    symbolName: "bubble.left.and.bubble.right.fill"
                ),
                InterviewReviewRow(
                    title: "项目场景",
                    body: projectScenario,
                    symbolName: "briefcase.fill"
                ),
                InterviewReviewRow(
                    title: "排查步骤",
                    body: debugSteps,
                    symbolName: "list.bullet.clipboard.fill"
                ),
                InterviewReviewRow(
                    title: "代码示例",
                    body: codeExample,
                    symbolName: "curlybraces.square.fill"
                )
            ]
        )
    }
}
