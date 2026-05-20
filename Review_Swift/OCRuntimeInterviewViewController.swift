//
//  OCRuntimeInterviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/20.
//

import UIKit

final class OCRuntimeInterviewViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "OC runtime / KVC / KVO / Block",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "OC runtime / KVC / KVO / Block",
            modules: Self.makeModules()
        )
    }

    private static func makeModules() -> [InterviewReviewModule] {
        [
            InterviewReviewModule(
                id: "runtime",
                title: "Objective-C runtime",
                subtitle: "动态语言、消息发送、缓存、解析、转发、Swizzling",
                symbolName: "cpu.fill",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: makeRuntimeItems()
            ),
            InterviewReviewModule(
                id: "kvc",
                title: "KVC",
                subtitle: "字符串读写、查找顺序、私有属性、模型赋值、风险",
                symbolName: "key.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: makeKVCItems()
            ),
            InterviewReviewModule(
                id: "kvo",
                title: "KVO",
                subtitle: "属性观察、动态子类、isa-swizzling、崩溃与安全移除",
                symbolName: "eye.fill",
                tintColor: InterviewReviewStyle.accentColors[2],
                items: makeKVOItems()
            ),
            InterviewReviewModule(
                id: "block",
                title: "Block",
                subtitle: "变量捕获、__block、copy、循环引用、delegate 对比",
                symbolName: "curlybraces.square.fill",
                tintColor: InterviewReviewStyle.accentColors[3],
                items: makeBlockItems()
            )
        ]
    }

    private static func reviewItem(
        title: String,
        question: String,
        coreAnswer: String,
        mnemonic: String,
        followUp: String,
        codeExample: String,
        projectScenario: String
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
                    title: "代码示例",
                    body: codeExample,
                    symbolName: "curlybraces.square.fill"
                ),
                InterviewReviewRow(
                    title: "项目场景",
                    body: projectScenario,
                    symbolName: "briefcase.fill"
                )
            ]
        )
    }
}

private extension OCRuntimeInterviewViewController {

    static func makeRuntimeItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "runtime 是什么",
                question: "runtime 是什么？和编译期有什么区别？",
                coreAnswer: "runtime 是 OC 的运行时系统。类、对象、方法、消息发送都可在运行时处理。编译期给结构，运行时做查找和调用。",
                mnemonic: "编译期给蓝图，runtime 管现场。",
                followUp: "追问：runtime 能做什么？查类/方法/属性，动态加方法，消息转发，交换实现，关联对象。",
                codeExample: """
                let cls = NSClassFromString("UIViewController")
                print(cls as Any)
                """,
                projectScenario: "埋点统计、字典转模型、AOP、SDK 兼容判断、崩溃兜底。"
            ),
            reviewItem(
                title: "OC 为什么是动态语言",
                question: "为什么说 Objective-C 是动态语言？",
                coreAnswer: "OC 调方法本质是发消息。对象的真实类型、方法实现、转发目标都可在运行时决定和修改。",
                mnemonic: "OC 不急着绑定，运行时再决定。",
                followUp: "追问：Swift 也是这样吗？Swift 默认更静态；继承 NSObject、@objc dynamic 后才更多走 OC runtime。",
                codeExample: """
                let selector = NSSelectorFromString("viewDidLoad")
                print(UIViewController.instancesRespond(to: selector))
                """,
                projectScenario: "根据字符串创建页面、插件化路由、动态判断某个 selector 是否可响应。"
            ),
            reviewItem(
                title: "消息发送机制 objc_msgSend",
                question: "objc_msgSend 做了什么？",
                coreAnswer: "[obj run] 会变成 objc_msgSend(obj, @selector(run))。先拿 receiver 的 isa 找类，再用 SEL 找 IMP，最后调用函数实现。",
                mnemonic: "对象收消息，SEL 找 IMP。",
                followUp: "追问：给 nil 发消息会怎样？直接返回 0/nil，不会崩溃，这是 OC 的常见特性。",
                codeExample: """
                ((void (*)(id, SEL))objc_msgSend)(obj, @selector(run));
                """,
                projectScenario: "理解 selector、target-action、响应链、动态调用 API 的底层基础。"
            ),
            reviewItem(
                title: "方法查找流程",
                question: "OC 方法查找流程是什么？",
                coreAnswer: "先判断 receiver 是否为 nil；再查当前类 cache；未命中查 method list；再沿 superclass 查；都没有就进入解析和转发。",
                mnemonic: "nil、cache、list、super、forward。",
                followUp: "追问：类方法怎么查？类方法存在元类里，类对象的 isa 指向元类，查找流程类似。",
                codeExample: """
                let method = class_getInstanceMethod(
                    UIViewController.self,
                    #selector(UIViewController.viewDidLoad)
                )
                print(method as Any)
                """,
                projectScenario: "排查 unrecognized selector、分类方法覆盖、SDK 方法兼容时很常用。"
            ),
            reviewItem(
                title: "方法缓存 cache",
                question: "runtime 的方法缓存有什么用？",
                coreAnswer: "每个类有方法缓存，缓存 SEL 到 IMP。第一次查找慢一点，后续命中 cache 可直接调用，减少方法列表遍历。",
                mnemonic: "查一次，缓存下次快。",
                followUp: "追问：为什么动态语言性能还能接受？因为消息发送有 cache，热点方法大多会命中。",
                codeExample: """
                // 第一次走完整查找，后续同一 SEL 常命中 cache
                view.setNeedsLayout()
                view.setNeedsLayout()
                """,
                projectScenario: "高频 UI 方法、生命周期方法、事件响应方法都会受益于 cache。"
            ),
            reviewItem(
                title: "动态方法解析",
                question: "什么是动态方法解析？",
                coreAnswer: "方法找不到时，runtime 先调用 +resolveInstanceMethod: 或 +resolveClassMethod:。可以用 class_addMethod 动态补一个实现。",
                mnemonic: "找不到，先给一次补课机会。",
                followUp: "追问：返回 YES 后会怎样？runtime 会重新走一次消息发送，去查刚添加的方法。",
                codeExample: """
                + (BOOL)resolveInstanceMethod:(SEL)sel {
                    if (sel == @selector(run)) {
                        class_addMethod(self, sel, (IMP)runIMP, "v@:");
                        return YES;
                    }
                    return [super resolveInstanceMethod:sel];
                }
                """,
                projectScenario: "动态属性、热修复兜底、按需加载方法实现，但业务中要谨慎使用。"
            ),
            reviewItem(
                title: "消息转发流程",
                question: "消息转发完整流程是什么？",
                coreAnswer: "动态解析失败后，先走 forwardingTargetForSelector 快速转发；再走 methodSignatureForSelector 和 forwardInvocation 慢速转发；最后崩溃。",
                mnemonic: "解析、快转、签名、慢转、崩溃。",
                followUp: "追问：快速转发和慢速转发区别？快速转给另一个对象；慢速可拿到 NSInvocation，能改参数、改目标、做兜底。",
                codeExample: """
                - (id)forwardingTargetForSelector:(SEL)aSelector {
                    if (aSelector == @selector(run)) {
                        return self.backup;
                    }
                    return [super forwardingTargetForSelector:aSelector];
                }
                """,
                projectScenario: "容错路由、代理聚合、埋点转发、解决部分 unrecognized selector 崩溃。"
            ),
            reviewItem(
                title: "Method Swizzling",
                question: "Method Swizzling 是什么？有什么风险？",
                coreAnswer: "Swizzling 是交换两个方法的 IMP。常用于 AOP 和统一埋点。风险是影响全局行为、顺序敏感、易和第三方冲突。",
                mnemonic: "换实现很强，也很危险。",
                followUp: "追问：怎么写更稳？只执行一次；先 class_addMethod 再 exchange；保留原实现；控制影响范围。",
                codeExample: """
                if let original = class_getInstanceMethod(cls, originalSEL),
                   let swizzled = class_getInstanceMethod(cls, swizzledSEL) {
                    method_exchangeImplementations(original, swizzled)
                }
                """,
                projectScenario: "页面曝光埋点、按钮点击统计、图片加载监控、系统 bug 兜底。"
            ),
            reviewItem(
                title: "runtime 常见使用场景",
                question: "项目里 runtime 常见用在哪些地方？",
                coreAnswer: "常见有关联对象、属性列表、字典转模型、方法交换、动态添加方法、消息转发、对象归档、埋点统计。",
                mnemonic: "查结构、改行为、补能力。",
                followUp: "追问：runtime 是不是越多越高级？不是。它绕过编译期检查，能不用就少用，公共能力要封装好。",
                codeExample: """
                private var tapKey: UInt8 = 0
                objc_setAssociatedObject(
                    button,
                    &tapKey,
                    handler,
                    .OBJC_ASSOCIATION_COPY_NONATOMIC
                )
                """,
                projectScenario: "给分类加存储属性、无侵入埋点、模型自动映射、老接口兼容。"
            )
        ]
    }

    static func makeKVCItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "KVC 是什么",
                question: "KVC 是什么？",
                coreAnswer: "KVC 是 Key-Value Coding，用字符串 key 读写对象属性。它依赖 NSObject 和访问器/实例变量查找规则。",
                mnemonic: "KVC：用字符串读写属性。",
                followUp: "追问：KVC 和点语法区别？点语法有编译检查；KVC 更动态，但类型和 key 都不安全。",
                codeExample: """
                person.setValue("Tom", forKey: "name")
                let name = person.value(forKey: "name")
                """,
                projectScenario: "快速给模型赋值、读取动态字段、调试时查看对象内部状态。"
            ),
            reviewItem(
                title: "valueForKey / setValue:forKey",
                question: "valueForKey 和 setValue:forKey 分别做什么？",
                coreAnswer: "valueForKey 读值，setValue:forKey 写值。key 正确时走访问器或 ivar；key 错误时会走 undefinedKey。",
                mnemonic: "value 读，setValue 写。",
                followUp: "追问：forKeyPath 呢？forKey 只处理一级 key；forKeyPath 支持 person.address.city 这种路径。",
                codeExample: """
                let city = user.value(forKeyPath: "address.city")
                user.setValue("Shanghai", forKeyPath: "address.city")
                """,
                projectScenario: "服务端字段层级不固定时，可用 keyPath 做简单读取，但要注意空值和崩溃。"
            ),
            reviewItem(
                title: "KVC 查找顺序",
                question: "KVC 的查找顺序是什么？",
                coreAnswer: "读先找 getter，写先找 setter。没有访问器时，看 accessInstanceVariablesDirectly；允许则找 _key、_isKey、key、isKey；最后走 undefinedKey。",
                mnemonic: "先方法，后变量，再 undefined。",
                followUp: "追问：怎么禁止直接访问 ivar？重写 accessInstanceVariablesDirectly 返回 false。",
                codeExample: """
                override class func accessInstanceVariablesDirectly() -> Bool {
                    false
                }
                """,
                projectScenario: "排查为什么没有公开属性也能被 KVC 改值，以及为什么某些 key 会崩。"
            ),
            reviewItem(
                title: "访问私有属性",
                question: "KVC 为什么能访问私有属性？",
                coreAnswer: "KVC 可按规则直接找实例变量，绕过属性可见性。能访问不代表应该访问，私有字段变化会导致线上风险。",
                mnemonic: "能绕封装，不等于安全。",
                followUp: "追问：能不能访问系统私有属性？技术上可能，审核和兼容风险都高，不建议。",
                codeExample: """
                textField.setValue(
                    UIColor.systemRed,
                    forKeyPath: "_placeholderLabel.textColor"
                )
                """,
                projectScenario: "早期项目常用 KVC 改系统控件样式，现在更推荐公开 API 或自定义视图。"
            ),
            reviewItem(
                title: "setValue:nil forKey 崩溃原因",
                question: "为什么 setValue:nil forKey 可能崩溃？",
                coreAnswer: "如果目标是 Int、Bool、CGFloat 等非对象类型，nil 无法赋值。KVC 会调用 setNilValueForKey，默认抛异常。",
                mnemonic: "nil 只能给对象，基本类型要兜底。",
                followUp: "追问：怎么处理？重写 setNilValueForKey，给默认值；或模型赋值前先过滤 NSNull/nil。",
                codeExample: """
                override func setNilValueForKey(_ key: String) {
                    if key == "age" {
                        age = 0
                        return
                    }
                    super.setNilValueForKey(key)
                }
                """,
                projectScenario: "接口返回 null，但本地模型字段是 Int/Bool 时，字典转模型最容易踩。"
            ),
            reviewItem(
                title: "setValue:forUndefinedKey",
                question: "setValue:forUndefinedKey 什么时候触发？",
                coreAnswer: "key 找不到 setter，也找不到可访问 ivar 时触发。默认会抛异常，可重写做忽略、映射或日志。",
                mnemonic: "找不到 key，进 undefined。",
                followUp: "追问：valueForUndefinedKey 呢？读取未知 key 时触发，默认也会抛异常。",
                codeExample: """
                override func setValue(_ value: Any?, forUndefinedKey key: String) {
                    print("ignore unknown key:", key)
                }
                """,
                projectScenario: "后端新增字段，本地旧模型不认识；重写后可避免直接崩溃。"
            ),
            reviewItem(
                title: "KVC 和模型赋值",
                question: "KVC 怎么做模型赋值？优缺点是什么？",
                coreAnswer: "遍历字典，用 setValue:forKey 给模型赋值。优点简单；缺点是类型转换弱、key 无检查、nil 和未知字段易崩。",
                mnemonic: "KVC 转模型快，但不够稳。",
                followUp: "追问：线上更推荐什么？Swift 项目优先 Codable；复杂映射用成熟模型库或手写转换。",
                codeExample: """
                dict.forEach { key, value in
                    guard !(value is NSNull) else { return }
                    model.setValue(value, forKey: key)
                }
                """,
                projectScenario: "老 OC 项目常用 KVC 转模型；Swift 新项目更常用 Codable。"
            ),
            reviewItem(
                title: "KVC 的风险",
                question: "KVC 有哪些风险？",
                coreAnswer: "字符串 key 无编译检查，类型不安全，可破坏封装。key 写错、nil 给基本类型、私有字段变化都会导致崩溃。",
                mnemonic: "KVC 三怕：错 key、错类型、碰私有。",
                followUp: "追问：如何降低风险？统一映射表，过滤 NSNull，重写 undefinedKey，关键模型写单测。",
                codeExample: """
                guard let value = dict["name"], !(value is NSNull) else { return }
                model.setValue(value, forKey: "name")
                """,
                projectScenario: "接口字段频繁变化、多人重构属性名时，KVC 崩溃会明显增多。"
            )
        ]
    }

    static func makeKVOItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "KVO 是什么",
                question: "KVO 是什么？",
                coreAnswer: "KVO 是 Key-Value Observing，用来监听对象某个属性变化。变化后可拿到 old/new，并执行回调。",
                mnemonic: "KVO：盯属性变化。",
                followUp: "追问：所有属性都能 KVO 吗？不一定。通常要求 NSObject 派生，并通过 KVO 兼容的 setter 修改。",
                codeExample: """
                observation = user.observe(\\.name, options: [.old, .new]) { _, change in
                    print(change.newValue ?? "")
                }
                """,
                projectScenario: "监听进度、播放状态、contentSize、operation 状态、简单数据绑定。"
            ),
            reviewItem(
                title: "KVO 实现原理",
                question: "KVO 底层怎么实现？",
                coreAnswer: "系统动态创建 NSKVONotifying_xxx 子类，重写 setter，在赋值前后插入 willChange/didChange 通知。",
                mnemonic: "动态子类，重写 setter。",
                followUp: "追问：为什么直接改 ivar 不触发？因为绕过了 setter，也就绕过了 KVO 注入的通知逻辑。",
                codeExample: """
                print(type(of: user))
                print(object_getClass(user) as Any)
                """,
                projectScenario: "解释为什么属性必须通过 setter 改，为什么某些内部变量变化观察不到。"
            ),
            reviewItem(
                title: "isa-swizzling",
                question: "KVO 的 isa-swizzling 是什么？",
                coreAnswer: "添加观察后，对象的 isa 会指向动态子类。外部看 class 仍像原类，但真实类已经变成 KVO 子类。",
                mnemonic: "isa 偷换，class 伪装。",
                followUp: "追问：移除观察后会怎样？通常会恢复原 isa；但不要依赖私有实现细节写业务逻辑。",
                codeExample: """
                let publicType = type(of: user)
                let runtimeType = object_getClass(user)
                print(publicType, runtimeType as Any)
                """,
                projectScenario: "调试 KVO 时看到 NSKVONotifying_ 前缀类，不要误以为对象类型错了。"
            ),
            reviewItem(
                title: "自动通知 / 手动通知",
                question: "KVO 自动通知和手动通知有什么区别？",
                coreAnswer: "默认自动通知，setter 自动触发。手动通知要关闭自动通知，自己调用 willChangeValue 和 didChangeValue。",
                mnemonic: "自动靠 setter，手动靠 will/did。",
                followUp: "追问：什么时候用手动？一个属性由多个字段计算而来，或需要合并多次变化时。",
                codeExample: """
                override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
                    key == "progress" ? false : super.automaticallyNotifiesObservers(forKey: key)
                }

                willChangeValue(forKey: "progress")
                progress = newValue
                didChangeValue(forKey: "progress")
                """,
                projectScenario: "下载进度、组合状态、批量更新时，手动通知能减少无意义回调。"
            ),
            reviewItem(
                title: "observeValue 回调",
                question: "老式 KVO 的 observeValue 回调要注意什么？",
                coreAnswer: "要判断 keyPath、object 和 context。自己不处理的回调必须交给 super，避免吞掉父类观察逻辑。",
                mnemonic: "先验明身份，再处理回调。",
                followUp: "追问：为什么推荐 context？keyPath 字符串可能重复，context 能准确区分是谁加的观察。",
                codeExample: """
                override func observeValue(
                    forKeyPath keyPath: String?,
                    of object: Any?,
                    change: [NSKeyValueChangeKey: Any]?,
                    context: UnsafeMutableRawPointer?
                ) {
                    guard context == Self.kvoContext else {
                        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                        return
                    }
                }
                """,
                projectScenario: "老项目混用多个 KVO 时，context 能减少误处理和难查崩溃。"
            ),
            reviewItem(
                title: "KVO 崩溃原因",
                question: "KVO 常见崩溃原因有哪些？",
                coreAnswer: "重复移除、未移除就释放、观察者释放后仍回调、keyPath 写错、观察非 KVO 属性、回调没传 super、线程时序问题。",
                mnemonic: "错 key、乱移除、生命周期没对齐。",
                followUp: "追问：现在还会未移除崩吗？现代系统改善了部分场景，但老式 API 仍建议严格管理生命周期。",
                codeExample: """
                observation?.invalidate()
                observation = nil
                """,
                projectScenario: "页面销毁、cell 复用、网络任务取消、播放器释放时最容易出现 KVO 时序崩溃。"
            ),
            reviewItem(
                title: "如何安全移除观察者",
                question: "如何安全移除 KVO 观察者？",
                coreAnswer: "Swift 推荐保存 NSKeyValueObservation token，deinit 或不需要时 invalidate。老式 API 要保证 add/remove 一一对应。",
                mnemonic: "有 token 管 token，老 API 一加一减。",
                followUp: "追问：能不能 try-catch remove？不推荐。更好的方式是记录状态，避免重复 remove。",
                codeExample: """
                private var observation: NSKeyValueObservation?

                deinit {
                    observation?.invalidate()
                }
                """,
                projectScenario: "封装播放器、滚动监听、Operation 状态监听时，用 token 管理最省心。"
            ),
            reviewItem(
                title: "KVO 和 Notification 区别",
                question: "KVO 和 Notification 有什么区别？",
                coreAnswer: "KVO 是点对点观察属性变化；Notification 是一对多广播事件。KVO 关注值变化，通知关注事件发生。",
                mnemonic: "KVO 盯值，通知喊事。",
                followUp: "追问：登录成功用哪个？登录成功是事件，更适合 Notification 或业务回调；用户 name 改变才更像 KVO。",
                codeExample: """
                NotificationCenter.default.post(
                    name: Notification.Name("didLogin"),
                    object: nil
                )
                """,
                projectScenario: "播放进度用 KVO；登录态变化、主题切换、全局刷新更常用通知。"
            ),
            reviewItem(
                title: "Swift 中 KVO 使用注意点",
                question: "Swift 中使用 KVO 要注意什么？",
                coreAnswer: "被观察对象通常要继承 NSObject，属性要 @objc dynamic。纯 Swift struct/enum 和普通 Swift 属性默认不支持 OC KVO。",
                mnemonic: "NSObject + @objc dynamic。",
                followUp: "追问：SwiftUI/Combine 还用 KVO 吗？新代码更常用 Observable、Combine、闭包或 async stream；对接 OC API 时仍会遇到 KVO。",
                codeExample: """
                final class User: NSObject {
                    @objc dynamic var name = ""
                }
                """,
                projectScenario: "监听 AVPlayer、Operation、WKWebView estimatedProgress 等 Apple API 时常见。"
            )
        ]
    }

    static func makeBlockItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "Block 是什么",
                question: "Block 是什么？",
                coreAnswer: "Block 是 OC 的闭包。它可以像对象一样传递，保存一段代码，也可以捕获外部上下文。",
                mnemonic: "Block：能传来传去的代码块。",
                followUp: "追问：Block 和 Swift closure 类似吗？思路类似，都是闭包；内存和捕获细节不同。",
                codeExample: """
                void (^done)(BOOL) = ^(BOOL success) {
                    NSLog(@"%@", success ? @"YES" : @"NO");
                };
                done(YES);
                """,
                projectScenario: "网络完成回调、动画完成、按钮点击、cell 事件回传。"
            ),
            reviewItem(
                title: "Block 捕获变量规则",
                question: "Block 怎么捕获外部变量？",
                coreAnswer: "局部基本类型默认按值捕获。对象变量捕获的是指针，并会强持有对象。static/global 不需要捕获。",
                mnemonic: "基本类型拷值，对象强持有。",
                followUp: "追问：访问成员变量会怎样？等价于访问 self 的 ivar，Block 会捕获 self。",
                codeExample: """
                int count = 1;
                void (^block)(void) = ^{
                    NSLog(@"%d", count);
                };
                count = 2; // block 里仍是 1
                """,
                projectScenario: "排查为什么 block 内变量没变，或为什么 block 里用 ivar 导致控制器不释放。"
            ),
            reviewItem(
                title: "__block 作用",
                question: "__block 有什么作用？",
                coreAnswer: "__block 让局部变量可以在 Block 内修改。ARC 下 __block 修饰对象默认仍是强引用，不等于 weak。",
                mnemonic: "__block 管可变，不管防环。",
                followUp: "追问：要打破循环引用用什么？用 __weak 或 Swift 的 [weak self]，不是只写 __block。",
                codeExample: """
                __block NSInteger count = 0;
                void (^add)(void) = ^{
                    count += 1;
                };
                add();
                """,
                projectScenario: "异步回调里累加计数、修改局部状态时会用；防循环引用不要依赖它。"
            ),
            reviewItem(
                title: "Block 类型：全局 / 栈 / 堆",
                question: "Block 有哪些类型？",
                coreAnswer: "不捕获变量的是全局 Block。捕获局部变量时可能先在栈上。copy 后会到堆上，生命周期更安全。",
                mnemonic: "不捕获全局，捕获先栈，copy 上堆。",
                followUp: "追问：ARC 下还要手动 copy 吗？属性仍建议写 copy；ARC 会在很多赋值场景自动把 Block 拷到堆。",
                codeExample: """
                NSLog(@"%@", [^{
                    NSLog(@"global");
                } class]); // __NSGlobalBlock__
                """,
                projectScenario: "理解为什么 Block 属性用 copy，以及为什么老代码里栈 Block 逃逸会危险。"
            ),
            reviewItem(
                title: "copy 修饰 Block 的原因",
                question: "Block 属性为什么用 copy？",
                coreAnswer: "Block 可能在栈上，离开作用域会失效。copy 能把 Block 拷到堆上，让属性持有的回调安全存在。",
                mnemonic: "Block 做属性，用 copy 最稳。",
                followUp: "追问：strong 行不行？ARC 下很多时候也会拷贝，但 copy 语义最准确，也是 OC 标准写法。",
                codeExample: """
                @property (nonatomic, copy) void (^completion)(void);
                """,
                projectScenario: "网络层 completion、ViewModel 输出、cell 点击回调都应使用 copy 属性。"
            ),
            reviewItem(
                title: "Block 循环引用",
                question: "Block 为什么容易造成循环引用？",
                coreAnswer: "对象 strong 持有 Block，Block 又强捕获 self，就形成 self -> block -> self，dealloc 不会走。",
                mnemonic: "self 持 block，block 抓 self，就成环。",
                followUp: "追问：所有 block 里用 self 都会泄漏吗？不会。短生命周期且不被 self 持有的 Block 一般没问题。",
                codeExample: """
                self.completion = ^{
                    [self reloadData];
                };
                """,
                projectScenario: "控制器持有 ViewModel，ViewModel 有回调 Block，回调里强用 self 是高频泄漏点。"
            ),
            reviewItem(
                title: "weak-strong dance",
                question: "weak-strong dance 是什么？",
                coreAnswer: "外部 weakSelf 打破循环引用，Block 内部 strongSelf 保证执行期间 self 不被释放。strongSelf 只在 Block 内有效。",
                mnemonic: "外弱破环，内强保命。",
                followUp: "追问：为什么不一直用 weakSelf？多次访问 weakSelf 可能中途变 nil；strong 一下逻辑更稳定。",
                codeExample: """
                __weak typeof(self) weakSelf = self;
                self.completion = ^{
                    __strong typeof(weakSelf) self = weakSelf;
                    if (!self) { return; }
                    [self reloadData];
                };
                """,
                projectScenario: "网络回调、异步任务、ViewModel 输出闭包、Timer block 都常用这个写法。"
            ),
            reviewItem(
                title: "Block 和 delegate 的区别",
                question: "Block 和 delegate 有什么区别？",
                coreAnswer: "Block 适合一两个回调，代码集中。delegate 适合多方法协议、长期关系、复杂交互。delegate 通常 weak，Block 属性通常 copy。",
                mnemonic: "简单回调用 Block，复杂协议用 delegate。",
                followUp: "追问：为什么 delegate 要 weak？delegate 是反向通知，不该拥有调用方，避免循环引用。",
                codeExample: """
                cell.onTap = { [weak self] model in
                    self?.openDetail(model)
                }
                """,
                projectScenario: "cell 单个点击回调用 Block；UITableViewDataSource/Delegate 这种多方法场景用 delegate。"
            ),
            reviewItem(
                title: "Block 项目使用场景",
                question: "项目里 Block 常用在哪？",
                coreAnswer: "常用于网络结果、动画完成、事件回调、异步任务、链式配置、ViewModel 到 Controller 的输出。",
                mnemonic: "回调、异步、事件，都常见 Block。",
                followUp: "追问：使用 Block 最重要注意什么？看生命周期和捕获关系，必要时 weak self，回调结束后断开引用。",
                codeExample: """
                UIView.animate(withDuration: 0.25) {
                    view.alpha = 0
                } completion: { _ in
                    view.removeFromSuperview()
                }
                """,
                projectScenario: "登录完成回调、上传进度、弹窗按钮、页面跳转结果、列表 cell 事件。"
            )
        ]
    }
}
