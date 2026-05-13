//
//  StructClassReviewViewController.swift
//  Review_Swift
//
//  Created by kwmin on 2026/5/13.
//

import UIKit

final class StructClassReviewViewController: UIViewController {

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
            title = "struct 与 class 的区别"
        }
        view.backgroundColor = .systemBackground

        setupViews()

        let output = runStructAndClassDemo()
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

    private func runStructAndClassDemo() -> NSAttributedString {
        let result = NSMutableAttributedString()

        appendSectionTitle("1. struct：值类型", color: .systemBlue, to: result)
        appendKeyValue("重点", "复制时会产生一份新值，修改副本不影响原值。", color: .systemBlue, to: result)
        let structA = StructPerson(name: "小明", age: 18)
        var structB = structA
        structB.age = 20
        appendCode("var structB = structA", to: result)
        appendCode("structB.age = 20", to: result)
        appendCode("structA.age = \(structA.age)", to: result)
        appendCode("structB.age = \(structB.age)", to: result)
        appendKeyValue("结论", "structA 仍然是 18。", color: .systemGreen, to: result)
        appendBlankLine(to: result)

        appendSectionTitle("2. class：引用类型", color: .systemOrange, to: result)
        appendKeyValue("重点", "复制的是引用，两个变量指向同一个对象。", color: .systemOrange, to: result)
        let classA = ClassPerson(name: "小红", age: 18)
        let classB = classA
        classB.age = 20
        appendCode("let classB = classA", to: result)
        appendCode("classB.age = 20", to: result)
        appendCode("classA.age = \(classA.age)", to: result)
        appendCode("classB.age = \(classB.age)", to: result)
        appendKeyValue("结论", "classA 也变成 20。", color: .systemRed, to: result)
        appendBlankLine(to: result)

        appendSectionTitle("3. class：有对象身份", color: .systemPurple, to: result)
        appendKeyValue("重点", "class 可以用 === 判断两个引用是否指向同一个对象。", color: .systemPurple, to: result)
        appendCode("classA === classB -> \(classA === classB)", to: result)
        appendKeyValue("对比", "struct 没有对象身份，所以不能用 ===。", color: .systemPurple, to: result)
        appendBlankLine(to: result)

        appendSectionTitle("4. struct：修改自身需要 mutating", color: .systemIndigo, to: result)
        appendKeyValue("重点", "struct 的方法默认不能修改自身属性，想改必须加 mutating。", color: .systemIndigo, to: result)
        var structC = StructPerson(name: "小刚", age: 21)
        structC.birthday()
        classA.birthday()
        appendCode("structC.birthday() 后 age = \(structC.age)", to: result)
        appendCode("classA.birthday() 后 age = \(classA.age)", to: result)
        appendKeyValue("对比", "class 方法修改属性不需要 mutating。", color: .systemIndigo, to: result)
        appendBlankLine(to: result)

        appendSectionTitle("5. class：支持继承", color: .systemGreen, to: result)
        appendKeyValue("重点", "class 可以继承；struct 不支持继承。", color: .systemGreen, to: result)
        let student = Student(name: "小美", age: 19, school: "Swift 大学")
        appendCode("\(student.name) 是 ClassPerson 的子类 Student", to: result)
        appendCode("school = \(student.school)", to: result)
        appendBlankLine(to: result)

        appendSectionTitle("6. class：有 deinit", color: .systemRed, to: result)
        appendKeyValue("重点", "class 对象释放时会调用 deinit；struct 没有 deinit。", color: .systemRed, to: result)
        createTemporaryClassPerson()
        appendCode("临时 class 对象离开作用域后会触发 deinit", to: result)
        appendBlankLine(to: result)

        appendSummary(to: result)

        return result
    }

    private func createTemporaryClassPerson() {
        let temporaryPerson = ClassPerson(name: "临时对象", age: 1)
        print("创建临时 class 对象：\(temporaryPerson.name)")
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
        appendKeyValue("struct", "值类型，复制后互不影响，适合数据模型。", color: .systemBlue, to: result)
        appendKeyValue("class", "引用类型，多个变量可共享同一个对象，适合需要身份和生命周期的对象。", color: .systemOrange, to: result)
        appendKeyValue("面试重点", "值类型/引用类型是核心区别，继承、deinit、=== 都是 class 特有能力。", color: .systemRed, to: result)
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

struct StructPerson {

    var name: String
    var age: Int

    mutating func birthday() {
        age += 1
    }
}

class ClassPerson {

    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    func birthday() {
        age += 1
    }

    deinit {
        print("deinit: \(name) 被销毁")
    }
}

class Student: ClassPerson {

    let school: String

    init(name: String, age: Int, school: String) {
        self.school = school
        super.init(name: name, age: age)
    }
}
