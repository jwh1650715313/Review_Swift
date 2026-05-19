//
//  StructClassReviewViewController.swift
//  Review_Swift
//
//  Created by kwmin on 2026/5/13.
//

import UIKit

final class StructClassReviewViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "struct 与 class 的区别",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "struct 与 class 的区别",
            modules: Self.makeModules()
        )
    }
}

private extension StructClassReviewViewController {

    static func makeModules() -> [InterviewReviewModule] {
        [
            InterviewReviewModule(
                id: "value-reference",
                title: "值类型 vs 引用类型",
                subtitle: "复制行为、共享对象、对象身份判断",
                symbolName: "arrow.left.arrow.right.circle.fill",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: makeValueReferenceItems()
            ),
            InterviewReviewModule(
                id: "language-features",
                title: "语法能力差异",
                subtitle: "mutating、继承、deinit、生命周期",
                symbolName: "curlybraces.square.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: makeLanguageFeatureItems()
            ),
            InterviewReviewModule(
                id: "interview-summary",
                title: "面试总结",
                subtitle: "一句话说清核心取舍和使用建议",
                symbolName: "checkmark.seal.fill",
                tintColor: InterviewReviewStyle.accentColors[2],
                items: makeSummaryItems()
            )
        ]
    }

    static func makeValueReferenceItems() -> [InterviewReviewItem] {
        let structResult = makeStructCopyResult()
        let classResult = makeClassReferenceResult()

        return [
            InterviewReviewItem(
                title: "struct 是值类型",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "struct 赋值或传参时会复制一份新值。后续修改副本，不会影响原来的变量。",
                        symbolName: "lightbulb.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码验证",
                        body: structResult,
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "标准答案",
                        body: "值类型强调数据本身，每个变量拥有自己的值。常见值类型包括 struct、enum、Int、String、Array、Dictionary。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "使用场景",
                        body: "适合用户信息、订单模型、配置项、坐标、尺寸等主要表达数据的模型。",
                        symbolName: "briefcase.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "struct 复制的是值，副本改了，原值不动。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            ),
            InterviewReviewItem(
                title: "class 是引用类型",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "class 赋值或传参时复制的是引用。多个变量可能指向同一个对象，任何一个引用修改对象，其他引用看到的也是修改后的状态。",
                        symbolName: "lightbulb.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码验证",
                        body: classResult,
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "标准答案",
                        body: "引用类型强调对象身份和共享状态。class 实例通常放在堆上，通过引用访问，由 ARC 管理生命周期。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "使用场景",
                        body: "适合控制器、ViewModel、网络管理器、缓存对象、播放器、数据库连接等需要共享状态或生命周期管理的对象。",
                        symbolName: "briefcase.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "class 复制的是引用，一个对象，多处入口。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            ),
            InterviewReviewItem(
                title: "class 有对象身份",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "对象身份表示“是不是同一个对象”。class 可以用 === 判断两个引用是否指向同一个实例。",
                        symbolName: "person.2.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码验证",
                        body: "let b = a\nprint(a === b) // true\n\nstruct 没有对象身份，不能使用 ===。",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "标准答案",
                        body: "struct 比较的是值是否相等，需要自己遵守 Equatable；class 除了内容相等，还可以判断两个引用是否是同一个对象。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "=== 是 class 的身份比较，不是 struct 的值比较。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            )
        ]
    }

    static func makeLanguageFeatureItems() -> [InterviewReviewItem] {
        [
            InterviewReviewItem(
                title: "struct 修改自身需要 mutating",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "struct 的实例方法默认不能修改自身属性。如果方法会改变 self 或属性，必须标记 mutating。",
                        symbolName: "pencil.circle.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码验证",
                        body: "struct User {\n    var age: Int\n\n    mutating func birthday() {\n        age += 1\n    }\n}",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "对比 class",
                        body: "class 方法修改属性不需要 mutating，因为 class 实例通过引用访问，方法默认可以修改对象内部状态。",
                        symbolName: "arrow.triangle.2.circlepath"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "struct 想在方法里改自己，就要 mutating。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            ),
            InterviewReviewItem(
                title: "class 支持继承",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "class 可以继承父类，复用和重写父类能力；struct 不支持继承，只能通过 protocol 和组合扩展能力。",
                        symbolName: "point.3.connected.trianglepath.dotted"
                    ),
                    InterviewReviewRow(
                        title: "代码验证",
                        body: "class Person {}\nclass Student: Person {}\n\nstruct User {}\n// struct Student: User 不能这样写",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "标准答案",
                        body: "Swift 更鼓励值类型、协议和组合。只有需要共享身份、继承体系或 Objective-C 互操作时，class 才更合适。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "class 能继承，struct 靠协议和组合。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            ),
            InterviewReviewItem(
                title: "class 有 deinit",
                rows: [
                    InterviewReviewRow(
                        title: "核心概念",
                        body: "class 实例释放前会调用 deinit，可以用来清理定时器、通知、任务、文件句柄等资源。struct 没有 deinit。",
                        symbolName: "trash.circle.fill"
                    ),
                    InterviewReviewRow(
                        title: "代码验证",
                        body: "class Person {\n    deinit {\n        print(\"对象被销毁\")\n    }\n}",
                        symbolName: "terminal.fill"
                    ),
                    InterviewReviewRow(
                        title: "面试追问",
                        body: "页面 pop 后 deinit 不走，通常要查闭包强持有 self、Timer、Notification block、delegate strong、单例缓存和异步任务。",
                        symbolName: "questionmark.circle.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "deinit 是 class 生命周期结束的证明。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            )
        ]
    }

    static func makeSummaryItems() -> [InterviewReviewItem] {
        [
            InterviewReviewItem(
                title: "怎么选择 struct 和 class",
                rows: [
                    InterviewReviewRow(
                        title: "优先选择",
                        body: "默认优先 struct，尤其是纯数据模型。值类型更容易推理，不容易被别处意外修改。",
                        symbolName: "star.fill"
                    ),
                    InterviewReviewRow(
                        title: "选择 class",
                        body: "需要继承、对象身份、共享可变状态、生命周期管理、引用语义或 Objective-C 互操作时，选择 class。",
                        symbolName: "person.crop.circle.fill"
                    ),
                    InterviewReviewRow(
                        title: "面试标准话术",
                        body: "核心区别是 struct 是值类型，class 是引用类型；class 还有继承、deinit、=== 身份比较，struct 修改自身方法需要 mutating。",
                        symbolName: "checkmark.seal.fill"
                    ),
                    InterviewReviewRow(
                        title: "一句话速记",
                        body: "struct 管数据，class 管身份和生命周期。",
                        symbolName: "bolt.fill",
                        isMemoryLine: true
                    )
                ]
            )
        ]
    }

    static func makeStructCopyResult() -> String {
        let structA = StructExamplePerson(name: "小明", age: 18)
        var structB = structA
        structB.age = 20

        return """
        var structB = structA
        structB.age = 20
        structA.age = \(structA.age)
        structB.age = \(structB.age)
        """
    }

    static func makeClassReferenceResult() -> String {
        let classA = ClassExamplePerson(name: "小红", age: 18)
        let classB = classA
        classB.age = 20

        return """
        let classB = classA
        classB.age = 20
        classA.age = \(classA.age)
        classB.age = \(classB.age)
        classA === classB -> \(classA === classB)
        """
    }
}

private struct StructExamplePerson {

    let name: String
    var age: Int
}

private final class ClassExamplePerson {

    let name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
