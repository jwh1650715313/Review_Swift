//
//  InterviewReviewListViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/19.
//

import UIKit

enum InterviewReviewStyle {

    static let backgroundColor = UIColor(red: 0.035, green: 0.045, blue: 0.060, alpha: 1.0)
    static let headerBackgroundColor = UIColor(red: 0.080, green: 0.092, blue: 0.125, alpha: 1.0)
    static let cardBackgroundColor = UIColor(red: 0.098, green: 0.112, blue: 0.150, alpha: 1.0)
    static let fieldBackgroundColor = UIColor(red: 0.060, green: 0.070, blue: 0.098, alpha: 1.0)
    static let titleTextColor = UIColor(white: 0.97, alpha: 1.0)
    static let bodyTextColor = UIColor(white: 0.84, alpha: 1.0)
    static let secondaryTextColor = UIColor(white: 0.68, alpha: 1.0)
    static let selectionColor = UIColor.white.withAlphaComponent(0.045)

    static let accentColors: [UIColor] = [
        UIColor(red: 0.27, green: 0.74, blue: 1.00, alpha: 1.0),
        UIColor(red: 0.36, green: 0.90, blue: 0.66, alpha: 1.0),
        UIColor(red: 1.00, green: 0.64, blue: 0.30, alpha: 1.0),
        UIColor(red: 0.73, green: 0.58, blue: 1.00, alpha: 1.0),
        UIColor(red: 0.20, green: 0.84, blue: 0.92, alpha: 1.0)
    ]
}

struct InterviewReviewModule {

    let id: String
    let title: String
    let subtitle: String
    let symbolName: String
    let tintColor: UIColor
    let items: [InterviewReviewItem]
}

struct InterviewReviewItem {

    let title: String
    let rows: [InterviewReviewRow]
}

struct InterviewReviewRow {

    let title: String
    let body: String
    let symbolName: String
    let isMemoryLine: Bool

    init(
        title: String,
        body: String,
        symbolName: String,
        isMemoryLine: Bool = false
    ) {
        self.title = title
        self.body = body
        self.symbolName = symbolName
        self.isMemoryLine = isMemoryLine
    }
}

class InterviewReviewListViewController: UITableViewController {

    private let cellReuseIdentifier = "InterviewReviewCell"
    private let headerReuseIdentifier = "InterviewReviewHeaderView"
    private let pageTitle: String
    private let modules: [InterviewReviewModule]
    private var expandedModuleIDs: Set<String> = []

    init(pageTitle: String, modules: [InterviewReviewModule]) {
        self.pageTitle = pageTitle
        self.modules = modules
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        self.pageTitle = ""
        self.modules = []
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if title == nil {
            title = pageTitle
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    private func setupAppearance() {
        view.backgroundColor = InterviewReviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = InterviewReviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        tableView.backgroundColor = InterviewReviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 320
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        tableView.register(
            InterviewReviewCell.self,
            forCellReuseIdentifier: cellReuseIdentifier
        )
        tableView.register(
            InterviewReviewHeaderView.self,
            forHeaderFooterViewReuseIdentifier: headerReuseIdentifier
        )
    }

    private func updateExpandButton() {
        let isAllExpanded = expandedModuleIDs.count == modules.count
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: isAllExpanded ? "收起" : "展开",
            style: .plain,
            target: self,
            action: #selector(didTapExpandButton)
        )
    }

    @objc private func didTapExpandButton() {
        if expandedModuleIDs.count == modules.count {
            expandedModuleIDs.removeAll()
        } else {
            expandedModuleIDs = Set(modules.map(\.id))
        }

        tableView.reloadData()
        updateExpandButton()
    }

    private func toggleSection(_ section: Int) {
        let moduleID = modules[section].id

        if expandedModuleIDs.contains(moduleID) {
            expandedModuleIDs.remove(moduleID)
        } else {
            expandedModuleIDs.insert(moduleID)
        }

        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        updateExpandButton()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        modules.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let module = modules[section]
        return expandedModuleIDs.contains(module.id) ? module.items.count : 0
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
        ) as? InterviewReviewCell ?? InterviewReviewCell(
            style: .default,
            reuseIdentifier: cellReuseIdentifier
        )

        let module = modules[indexPath.section]
        let item = module.items[indexPath.row]
        cell.configure(
            index: indexPath.row + 1,
            item: item,
            tintColor: module.tintColor
        )

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: headerReuseIdentifier
        ) as? InterviewReviewHeaderView ?? InterviewReviewHeaderView(
            reuseIdentifier: headerReuseIdentifier
        )

        let module = modules[section]
        headerView.configure(
            index: section + 1,
            module: module,
            isExpanded: expandedModuleIDs.contains(module.id)
        )
        headerView.onTap = { [weak self] in
            self?.toggleSection(section)
        }

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForHeaderInSection section: Int
    ) -> CGFloat {
        82
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private final class InterviewReviewHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = InterviewReviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        return label
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = InterviewReviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: InterviewReviewPaddingLabel = {
        let label = InterviewReviewPaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = InterviewReviewStyle.secondaryTextColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTap = nil
    }

    private func setupViews() {
        contentView.backgroundColor = InterviewReviewStyle.backgroundColor
        contentView.addSubview(containerView)
        containerView.addSubview(indexLabel)
        containerView.addSubview(iconView)
        containerView.addSubview(textStackView)
        containerView.addSubview(countLabel)
        containerView.addSubview(chevronView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        containerView.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            indexLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            indexLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            indexLabel.widthAnchor.constraint(equalToConstant: 30),
            indexLabel.heightAnchor.constraint(equalToConstant: 30),

            iconView.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            textStackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -10),
            textStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            textStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),

            countLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -10),
            countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            chevronView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            chevronView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 18),
            chevronView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    func configure(
        index: Int,
        module: InterviewReviewModule,
        isExpanded: Bool
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = module.tintColor.withAlphaComponent(0.28)
        iconView.image = UIImage(systemName: module.symbolName)
        iconView.tintColor = module.tintColor
        titleLabel.text = module.title
        subtitleLabel.text = module.subtitle
        countLabel.text = "\(module.items.count) 题"
        chevronView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        containerView.layer.borderColor = module.tintColor.withAlphaComponent(isExpanded ? 0.55 : 0.18).cgColor
        containerView.layer.borderWidth = 1
    }

    @objc private func didTapHeader() {
        onTap?()
    }
}

private final class InterviewReviewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = InterviewReviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: InterviewReviewPaddingLabel = {
        let label = InterviewReviewPaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentStackView.arrangedSubviews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func setupViews() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = InterviewReviewStyle.selectionColor
        contentView.addSubview(containerView)
        containerView.addSubview(indexLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),

            indexLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            indexLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            titleLabel.centerYAnchor.constraint(equalTo: indexLabel.centerYAnchor),

            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            contentStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }

    func configure(
        index: Int,
        item: InterviewReviewItem,
        tintColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = tintColor.withAlphaComponent(0.26)
        titleLabel.text = item.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = tintColor.withAlphaComponent(0.20).cgColor

        item.rows.forEach { row in
            let fieldView = InterviewReviewFieldView()
            fieldView.configure(
                title: row.title,
                body: row.body,
                symbolName: row.symbolName,
                tintColor: tintColor,
                isMemoryLine: row.isMemoryLine
            )
            contentStackView.addArrangedSubview(fieldView)
        }
    }
}

private final class InterviewReviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = InterviewReviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = InterviewReviewStyle.bodyTextColor
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = InterviewReviewStyle.fieldBackgroundColor
        layer.cornerRadius = 8
        layer.masksToBounds = true

        addSubview(iconView)
        addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(bodyLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            textStackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            textStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    func configure(
        title: String,
        body: String,
        symbolName: String,
        tintColor: UIColor,
        isMemoryLine: Bool
    ) {
        iconView.image = UIImage(systemName: symbolName)
        iconView.tintColor = tintColor
        titleLabel.text = title
        titleLabel.textColor = isMemoryLine ? tintColor : InterviewReviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = isMemoryLine
            ? .systemFont(ofSize: 15, weight: .semibold)
            : .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = isMemoryLine ? InterviewReviewStyle.titleTextColor : InterviewReviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : InterviewReviewStyle.fieldBackgroundColor
    }
}

private final class InterviewReviewPaddingLabel: UILabel {

    var textInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
