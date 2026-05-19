//
//  KnowledgePointListViewController.swift
//  Review_Swift
//
//  Created by kwmin on 2026/5/13.
//

import UIKit

final class KnowledgePointListViewController: UITableViewController {

    private struct KnowledgePoint {

        let title: String
        let subtitle: String
        let makeViewController: () -> UIViewController
    }

    private let knowledgePoints: [KnowledgePoint] = [
        KnowledgePoint(
            title: "Swift 基础高频面试题",
            subtitle: "Optional、protocol、closure、COW、lazy、static、final",
            makeViewController: {
                SwiftFoundationInterviewViewController()
            }
        ),
        KnowledgePoint(
            title: "struct 与 class 的区别",
            subtitle: "值类型、引用类型、继承、mutating、deinit",
            makeViewController: {
                StructClassReviewViewController()
            }
        ),
        KnowledgePoint(
            title: "strong、weak、unowned 的区别",
            subtitle: "ARC 持有关系、自动置 nil、生命周期约束",
            makeViewController: {
                StrongWeakUnownedReviewViewController()
            }
        ),
        KnowledgePoint(
            title: "UIViewController ARC 内存管理",
            subtitle: "循环引用、weak、闭包、Timer、通知、cell 复用",
            makeViewController: {
                ARCInterviewReviewViewController()
            }
        ),
        KnowledgePoint(
            title: "MQTT 面试八股",
            subtitle: "Broker、Topic、QoS、retain、长连接、IoT 场景",
            makeViewController: {
                MQTTInterviewReviewViewController()
            }
        ),
        KnowledgePoint(
            title: "UITableView 面试宝典",
            subtitle: "复用、刷新、动态高度、卡顿、RunLoop、Instruments",
            makeViewController: {
                UITableViewInterviewReviewViewController()
            }
        ),
        KnowledgePoint(
            title: "UIKit 高频面试题",
            subtitle: "View/Controller 生命周期、AutoLayout、响应链、手势冲突",
            makeViewController: {
                UIKitInterviewReviewViewController()
            }
        ),
        KnowledgePoint(
            title: "iOS 数据持久化面试宝典",
            subtitle: "UserDefaults、FileManager、Keychain、SQLite/CoreData、Codable",
            makeViewController: {
                DataPersistenceInterviewReviewViewController()
            }
        ),
        KnowledgePoint(
            title: "iOS 多线程面试知识点",
            subtitle: "GCD、队列、死锁、锁、Group、RunLoop、OperationQueue",
            makeViewController: {
                MultithreadingInterviewReviewViewController()
            }
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Swift 知识点"
        view.backgroundColor = .systemBackground

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "KnowledgePointCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        knowledgePoints.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KnowledgePointCell", for: indexPath)
        let knowledgePoint = knowledgePoints[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = knowledgePoint.title
        content.secondaryText = knowledgePoint.subtitle
        content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let knowledgePoint = knowledgePoints[indexPath.row]
        let viewController = knowledgePoint.makeViewController()
        viewController.title = knowledgePoint.title
        navigationController?.pushViewController(viewController, animated: true)
    }
}
