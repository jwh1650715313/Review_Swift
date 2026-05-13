//
//  StrongWeakUnownedReviewViewController.swift
//  Review_Swift
//
//  Created by kwmin on 2026/5/13.
//

import UIKit

final class StrongWeakUnownedReviewViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if title == nil {
            title = "strong、weak、unowned 的区别"
        }
        view.backgroundColor = .systemBackground

        setupViews()

        let output = runReferenceDemo()
        contentLabel.attributedText = output
        print(output.string)
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentLabel)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func runReferenceDemo() -> NSAttributedString {
        let result = NSMutableAttributedString()

        appendSectionTitle("1. strong：强引用", color: .systemOrange, to: result)
        appendKeyValue("重点", "默认持有对象，引用计数 +1。", color: .systemOrange, to: result)
        appendKeyValue("默认", "Swift 里 class 类型属性默认就是 strong。", color: .systemOrange, to: result)
        appendKeyValue("效果", "只要 strong 引用存在，对象就不会被释放。", color: .systemOrange, to: result)
        appendBlankLine(to: result)

        var alice: StrongReferencePerson? = StrongReferencePerson(name: "Alice")
        var bob: StrongReferencePerson? = StrongReferencePerson(name: "Bob")
        alice?.friend = bob
        bob?.friend = alice
        appendCode("alice.friend 和 bob.friend 都是 strong", to: result)
        appendKeyValue("风险", "双方互相强持有，会形成循环引用。", color: .systemRed, to: result)
        alice?.friend = nil
        bob?.friend = nil
        appendKeyValue("解决", "断开其中一边，或把一边改成 weak / unowned。", color: .systemGreen, to: result)
        alice = nil
        bob = nil
        appendBlankLine(to: result)

        appendSectionTitle("2. weak：弱引用", color: .systemBlue, to: result)
        appendKeyValue("重点", "不持有对象，引用计数不增加。", color: .systemBlue, to: result)
        appendKeyValue("特点", "必须写成 optional，因为对象释放后会自动变成 nil。", color: .systemBlue, to: result)
        var teacher: WeakReferenceTeacher? = WeakReferenceTeacher(name: "王老师")
        let student = WeakReferenceStudent(name: "小明", teacher: teacher)
        appendCode("student.teacher?.name = \(student.teacher?.name ?? "nil")", to: result)
        teacher = nil
        appendKeyValue("释放后", "student.teacher 自动变成 nil。", color: .systemBlue, to: result)
        appendCode("student.teacher == nil -> \(student.teacher == nil)", to: result)
        appendKeyValue("常见", "delegate、IBOutlet、[weak self]。", color: .systemGreen, to: result)
        appendBlankLine(to: result)

        appendSectionTitle("3. unowned：无主引用", color: .systemPurple, to: result)
        appendKeyValue("重点", "不持有对象，引用计数不增加。", color: .systemPurple, to: result)
        appendKeyValue("特点", "通常是非 optional，不会自动变成 nil。", color: .systemPurple, to: result)
        appendKeyValue("前提", "被引用对象一定比当前对象活得更久。", color: .systemPurple, to: result)

        do {
            let customer = UnownedReferenceCustomer(name: "李雷")
            customer.card = UnownedReferenceCreditCard(number: "8888", customer: customer)
            appendCode("customer 强持有 card", to: result)
            appendCode("card 用 unowned 反向引用 customer", to: result)
            appendCode("card.customer.name = \(customer.card?.customerName ?? "nil")", to: result)
        }

        appendKeyValue("释放", "customer 离开作用域后，card 也跟着释放。", color: .systemPurple, to: result)
        appendKeyValue("危险", "customer 已释放后再访问 unowned customer，程序会崩溃。", color: .systemRed, to: result)
        appendBlankLine(to: result)

        appendSummary(to: result)

        return result
    }

    private func appendSectionTitle(_ text: String, color: UIColor, to result: NSMutableAttributedString) {
        append(text + "\n", font: .systemFont(ofSize: 20, weight: .bold), color: color, to: result)
    }

    private func appendKeyValue(_ key: String, _ value: String, color: UIColor, to result: NSMutableAttributedString) {
        append(key + "：", font: .systemFont(ofSize: 16, weight: .bold), color: color, to: result)
        append(value + "\n", font: .systemFont(ofSize: 16, weight: .regular), color: .label, to: result)
    }

    private func appendCode(_ text: String, to result: NSMutableAttributedString) {
        append(text + "\n", font: .monospacedSystemFont(ofSize: 15, weight: .medium), color: .secondaryLabel, to: result)
    }

    private func appendBlankLine(to result: NSMutableAttributedString) {
        append("\n", font: .systemFont(ofSize: 8), color: .label, to: result)
    }

    private func appendSummary(to result: NSMutableAttributedString) {
        append("总结\n", font: .systemFont(ofSize: 20, weight: .bold), color: .label, to: result)
        appendKeyValue("strong", "拥有对象，引用计数 +1，默认选择。", color: .systemOrange, to: result)
        appendKeyValue("weak", "不拥有对象，释放后自动 nil，适合可能先释放的引用。", color: .systemBlue, to: result)
        appendKeyValue("unowned", "不拥有对象，不会 nil，适合确定对方生命周期更长的引用。", color: .systemPurple, to: result)
        appendKeyValue("考试/面试", "weak 更安全；unowned 更严格，用错会崩溃。", color: .systemRed, to: result)
    }

    private func append(
        _ text: String,
        font: UIFont,
        color: UIColor,
        to result: NSMutableAttributedString
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 2

        result.append(
            NSAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
            )
        )
    }
}

private final class StrongReferencePerson {

    let name: String
    var friend: StrongReferencePerson?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("deinit strong person: \(name)")
    }
}

private final class WeakReferenceTeacher {

    let name: String

    init(name: String) {
        self.name = name
    }

    deinit {
        print("deinit weak teacher: \(name)")
    }
}

private final class WeakReferenceStudent {

    let name: String
    weak var teacher: WeakReferenceTeacher?

    init(name: String, teacher: WeakReferenceTeacher?) {
        self.name = name
        self.teacher = teacher
    }
}

private final class UnownedReferenceCustomer {

    let name: String
    var card: UnownedReferenceCreditCard?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("deinit unowned customer: \(name)")
    }
}

private final class UnownedReferenceCreditCard {

    let number: String
    unowned let customer: UnownedReferenceCustomer

    var customerName: String {
        customer.name
    }

    init(number: String, customer: UnownedReferenceCustomer) {
        self.number = number
        self.customer = customer
    }

    deinit {
        print("deinit unowned credit card: \(number)")
    }
}
