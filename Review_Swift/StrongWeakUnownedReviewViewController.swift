//
//  StrongWeakUnownedReviewViewController.swift
//  Review_Swift
//
//  Created by kwmin on 2026/5/13.
//

import UIKit

final class StrongWeakUnownedReviewViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "strong、weak、unowned 的区别",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "strong、weak、unowned 的区别",
            modules: Self.makeModules()
        )
    }
}

private extension StrongWeakUnownedReviewViewController {

    static func makeModules() -> [InterviewReviewModule] {
        [
            InterviewReviewModule(
                id: "strong",
                title: "strong 强引用",
                subtitle: "默认持有对象、引用计数 +1、循环引用风险",
                symbolName: "link.circle.fill",
                tintColor: InterviewReviewStyle.accentColors[2],
                items: makeStrongItems()
            ),
            InterviewReviewModule(
                id: "weak",
                title: "weak 弱引用",
                subtitle: "不持有对象、自动置 nil、delegate / 闭包常用",
                symbolName: "link.badge.plus",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: makeWeakItems()
            ),
            InterviewReviewModule(
                id: "unowned",
                title: "unowned 无主引用",
                subtitle: "不持有对象、不自动置 nil、生命周期必须更严格",
                symbolName: "exclamationmark.lock.fill",
                tintColor: InterviewReviewStyle.accentColors[3],
                items: makeUnownedItems()
            ),
            InterviewReviewModule(
                id: "compare",
                title: "面试对比总结",
                subtitle: "strong / weak / unowned 选择规则",
                symbolName: "checkmark.seal.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: makeCompareItems()
            )
        ]
    }

    static func makeStrongItems() -> [InterviewReviewItem] {
        [
            InterviewReviewItem(
                title: "strong 默认持有对象",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "strong 是强引用，会拥有对象，让对象引用计数 +1。只要还有 strong 引用存在，对象就不会被释放。",
                        symbolName: "lightbulb.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码观察",
                        body: "class Person {}\nvar p1: Person? = Person()\nvar p2 = p1\n\np1 和 p2 都强持有同一个对象。",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "标准答案",
                        body: "Swift 中 class 类型属性默认就是 strong。普通对象所有权一般用 strong 表示，例如控制器持有 view、数组持有元素、ViewModel 持有 service。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "风险",
                        body: "两个对象互相 strong 持有时，会形成循环引用，引用计数无法归零，deinit 不会调用。",
                        symbolName: "exclamationmark.triangle.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "strong 是拥有关系，拥有就会延长对象生命。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            ),
            InterviewReviewItem(
                title: "循环引用怎么产生",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "循环引用通常来自 A strong 持有 B，同时 B 又 strong 持有 A。闭包强捕获 self 也是常见来源。",
                        symbolName: "arrow.triangle.2.circlepath"
                    ),
                    InterviewReviewRow(
                        title: "代码观察",
                        body: "class Person {\n    var friend: Person?\n}\n\nalice.friend = bob\nbob.friend = alice\n\n双方都是 strong，两个对象都不会释放。",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "解决方式",
                        body: "把其中一边改成 weak 或 unowned，或者在合适时机主动断开引用。闭包中根据生命周期选择 [weak self] 或 [unowned self]。",
                        symbolName: "wrench.and.screwdriver.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "循环引用不是 strong 本身错，而是所有权形成了闭环。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            )
        ]
    }

    static func makeWeakItems() -> [InterviewReviewItem] {
        let weakResult = makeWeakReleaseResult()

        return [
            InterviewReviewItem(
                title: "weak 不持有对象",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "weak 是弱引用，不会让对象引用计数增加。对象释放后，weak 引用会被系统自动置为 nil。",
                        symbolName: "lightbulb.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码验证",
                        body: weakResult,
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "标准答案",
                        body: "weak 必须是 optional，因为它可能在对象释放后变成 nil。访问 weak 属性时要处理 nil 分支。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "使用场景",
                        body: "delegate、IBOutlet、cell 回调、异步回调、闭包 [weak self]，都经常使用 weak 来避免循环引用。",
                        symbolName: "briefcase.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "weak 不拥有对象，对象没了它自动 nil。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            ),
            InterviewReviewItem(
                title: "为什么 delegate 常用 weak",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "delegate 通常是反向通知。子对象不应该拥有它的代理，否则容易变成子对象 strong 持有控制器，控制器又 strong 持有子对象。",
                        symbolName: "person.wave.2.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码模板",
                        body: "protocol DetailViewDelegate: AnyObject {}\n\nfinal class DetailView: UIView {\n    weak var delegate: DetailViewDelegate?\n}",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "面试追问",
                        body: "protocol 要被 weak 修饰，通常需要继承 AnyObject，限制只有 class 类型可以遵守。",
                        symbolName: "questionmark.circle.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "delegate 是通知关系，不是拥有关系。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            )
        ]
    }

    static func makeUnownedItems() -> [InterviewReviewItem] {
        [
            InterviewReviewItem(
                title: "unowned 不持有也不置 nil",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "unowned 不增加引用计数，通常是非 optional。它不会在对象释放后自动变成 nil。",
                        symbolName: "lightbulb.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码模板",
                        body: "final class CreditCard {\n    unowned let customer: Customer\n\n    init(customer: Customer) {\n        self.customer = customer\n    }\n}",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "使用前提",
                        body: "只有当被引用对象一定比当前对象活得更久时，才适合使用 unowned。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "危险点",
                        body: "如果被引用对象已经释放，再访问 unowned 引用会直接崩溃。weak 更安全，unowned 更严格。",
                        symbolName: "exclamationmark.triangle.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "unowned 不拥有、不变 nil，用错会崩。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            )
        ]
    }

    static func makeCompareItems() -> [InterviewReviewItem] {
        [
            InterviewReviewItem(
                title: "strong / weak / unowned 怎么选",
                rows: [
                    InterviewReviewRow(
                        title: "strong",
                        body: "表达拥有关系。当前对象负责持有并延长对方生命周期，默认选择 strong。",
                        symbolName: "link.circle.fill"
                    ),
                    InterviewReviewRow(
                        title: "weak",
                        body: "表达非拥有关系。对方可能先释放，需要自动 nil，常见于 delegate、IBOutlet、[weak self]。",
                        symbolName: "link.badge.plus"
                    ),
                    InterviewReviewRow(
                        title: "unowned",
                        body: "表达非拥有关系，但确定对方生命周期更长。不需要 optional，但错误使用会崩溃。",
                        symbolName: "exclamationmark.lock.fill"
                    ),
                    InterviewReviewRow(
                        title: "面试标准话术",
                        body: "strong 会持有对象；weak 不持有且释放后自动 nil；unowned 不持有也不 nil，要求被引用对象生命周期更长。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "能 weak 就别急着 unowned，除非生命周期关系非常确定。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            )
        ]
    }

    static func makeWeakReleaseResult() -> String {
        var teacher: WeakExampleTeacher? = WeakExampleTeacher(name: "王老师")
        let student = WeakExampleStudent(name: "小明", teacher: teacher)
        let beforeRelease = student.teacher?.name ?? "nil"
        teacher = nil
        let afterRelease = student.teacher == nil

        return """
        weak var teacher: Teacher?
        student.teacher?.name = \(beforeRelease)
        teacher = nil
        student.teacher == nil -> \(afterRelease)
        """
    }
}

private final class WeakExampleTeacher {

    let name: String

    init(name: String) {
        self.name = name
    }
}

private final class WeakExampleStudent {

    let name: String
    weak var teacher: WeakExampleTeacher?

    init(name: String, teacher: WeakExampleTeacher?) {
        self.name = name
        self.teacher = teacher
    }
}
