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
