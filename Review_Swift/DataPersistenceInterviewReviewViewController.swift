//
//  DataPersistenceInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/19.
//

import UIKit

private enum DataPersistenceInterviewStyle {

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

fileprivate struct DataPersistenceReviewModule {

    let id: String
    let title: String
    let subtitle: String
    let symbolName: String
    let tintColor: UIColor
    let items: [DataPersistenceReviewItem]
}

fileprivate struct DataPersistenceReviewItem {

    let title: String
    let coreConcept: String
    let interviewQuestion: String
    let standardAnswer: String
    let usageScenario: String
    let prosAndCons: String
    let memoryLine: String
}

final class DataPersistenceInterviewReviewViewController: UITableViewController {

    fileprivate enum RowKind: CaseIterable {

        case coreConcept
        case interviewQuestion
        case standardAnswer
        case usageScenario
        case prosAndCons
        case memoryLine

        var title: String {
            switch self {
            case .coreConcept:
                return "核心概念"
            case .interviewQuestion:
                return "常见面试题"
            case .standardAnswer:
                return "标准答案"
            case .usageScenario:
                return "使用场景"
            case .prosAndCons:
                return "优缺点"
            case .memoryLine:
                return "一句话速记"
            }
        }

        var symbolName: String {
            switch self {
            case .coreConcept:
                return "lightbulb.fill"
            case .interviewQuestion:
                return "questionmark.circle.fill"
            case .standardAnswer:
                return "checkmark.seal.fill"
            case .usageScenario:
                return "briefcase.fill"
            case .prosAndCons:
                return "scale.3d"
            case .memoryLine:
                return "bolt.fill"
            }
        }

        func text(for item: DataPersistenceReviewItem) -> String {
            switch self {
            case .coreConcept:
                return item.coreConcept
            case .interviewQuestion:
                return item.interviewQuestion
            case .standardAnswer:
                return item.standardAnswer
            case .usageScenario:
                return item.usageScenario
            case .prosAndCons:
                return item.prosAndCons
            case .memoryLine:
                return item.memoryLine
            }
        }
    }

    private let cellReuseIdentifier = "DataPersistenceInterviewCell"
    private let headerReuseIdentifier = "DataPersistenceInterviewHeaderView"

    private lazy var modules: [DataPersistenceReviewModule] = makeModules()
    private var expandedModuleIDs: Set<String> = []

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if title == nil {
            title = "数据持久化面试宝典"
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    private func setupAppearance() {
        view.backgroundColor = DataPersistenceInterviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = DataPersistenceInterviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        tableView.backgroundColor = DataPersistenceInterviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 360
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        tableView.register(
            DataPersistenceReviewCell.self,
            forCellReuseIdentifier: cellReuseIdentifier
        )
        tableView.register(
            DataPersistenceReviewHeaderView.self,
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
        ) as? DataPersistenceReviewCell ?? DataPersistenceReviewCell(
            style: .default,
            reuseIdentifier: cellReuseIdentifier
        )

        let module = modules[indexPath.section]
        let item = module.items[indexPath.row]
        cell.configure(
            index: indexPath.row + 1,
            item: item,
            rows: RowKind.allCases,
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
        ) as? DataPersistenceReviewHeaderView ?? DataPersistenceReviewHeaderView(
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

private extension DataPersistenceInterviewReviewViewController {

    func makeModules() -> [DataPersistenceReviewModule] {
        [
            DataPersistenceReviewModule(
                id: "userdefaults",
                title: "UserDefaults",
                subtitle: "小型配置、偏好设置、Codable、小数据键值存储",
                symbolName: "switch.2",
                tintColor: DataPersistenceInterviewStyle.accentColors[0],
                items: makeUserDefaultsItems()
            ),
            DataPersistenceReviewModule(
                id: "filemanager",
                title: "FileManager",
                subtitle: "沙盒目录、文件读写、图片缓存、删除清理",
                symbolName: "folder.fill",
                tintColor: DataPersistenceInterviewStyle.accentColors[1],
                items: makeFileManagerItems()
            ),
            DataPersistenceReviewModule(
                id: "keychain",
                title: "Keychain",
                subtitle: "token、账号凭证、加密存储、卸载保留",
                symbolName: "key.fill",
                tintColor: DataPersistenceInterviewStyle.accentColors[2],
                items: makeKeychainItems()
            ),
            DataPersistenceReviewModule(
                id: "sqlite-coredata",
                title: "SQLite / CoreData",
                subtitle: "关系型数据库、对象图、线程、迁移、取舍",
                symbolName: "cylinder.split.1x2.fill",
                tintColor: DataPersistenceInterviewStyle.accentColors[3],
                items: makeSQLiteCoreDataItems()
            ),
            DataPersistenceReviewModule(
                id: "codable",
                title: "Codable",
                subtitle: "序列化、反序列化、CodingKeys、JSON 编解码",
                symbolName: "curlybraces.square.fill",
                tintColor: DataPersistenceInterviewStyle.accentColors[4],
                items: makeCodableItems()
            )
        ]
    }

    func makeUserDefaultsItems() -> [DataPersistenceReviewItem] {
        [
            DataPersistenceReviewItem(
                title: "适合存什么",
                coreConcept: "UserDefaults 是轻量级 key-value 偏好存储，适合 Bool、Int、Double、String、Data、Array、Dictionary 这类 plist 兼容的小数据。",
                interviewQuestion: "UserDefaults 适合存什么？token、图片、列表数据能不能放？",
                standardAnswer: "适合存开关、主题、首次启动标记、上次选择的 tab、少量业务配置。不要存敏感信息、图片、大 JSON、大数组和数据库级数据；token 这种凭证应该放 Keychain。",
                usageScenario: "暗黑模式开关、是否看过引导页、搜索历史开关、接口环境标记、用户偏好排序方式。",
                prosAndCons: "优点是 API 简单、读取方便、系统自动持久化；缺点是不加密、不适合大数据、不适合复杂查询和事务。",
                memoryLine: "面试速记：UserDefaults 只放小而不敏感的用户偏好。"
            ),
            DataPersistenceReviewItem(
                title: "底层原理",
                coreConcept: "UserDefaults 基于偏好系统，按 domain 管理 key-value，数据会缓存到内存，并以 plist 形式异步落到 App 沙盒的 Library/Preferences。",
                interviewQuestion: "UserDefaults 底层是怎么保存的？为什么读起来很快？",
                standardAnswer: "它不是数据库，本质是偏好配置存储。系统会把当前 domain 的偏好加载并缓存，读写先作用于内存缓存，再由系统在合适时机同步到磁盘 plist 文件。",
                usageScenario: "需要跨启动保存少量配置，又不需要 SQL 查询、对象关系和复杂一致性控制时使用。",
                prosAndCons: "优点是读取成本低、系统托管写盘；缺点是 plist 序列化对大对象不友好，频繁写大数据会拖慢启动和主线程体验。",
                memoryLine: "面试速记：UserDefaults = 内存缓存 + Preferences plist。"
            ),
            DataPersistenceReviewItem(
                title: "为什么不能存大量数据",
                coreConcept: "UserDefaults 面向配置，不面向数据集；大数据会增加序列化、反序列化、内存缓存和磁盘同步成本。",
                interviewQuestion: "为什么不能把接口返回的大列表直接塞进 UserDefaults？",
                standardAnswer: "大列表会让 plist 文件膨胀，加载偏好时占更多内存，写入时还要序列化并同步磁盘，容易影响启动和页面响应。大量结构化数据应该用文件、SQLite 或 CoreData。",
                usageScenario: "如果只是缓存一个小配置可以用；如果是商品列表、聊天记录、图片、离线数据包，就应该换文件或数据库。",
                prosAndCons: "优点是小数据省事；缺点是一旦当缓存仓库用，就会出现性能差、清理难、结构不可控的问题。",
                memoryLine: "面试速记：UserDefaults 不是缓存库，更不是数据库。"
            ),
            DataPersistenceReviewItem(
                title: "如何存 Codable 模型",
                coreConcept: "Codable 模型不能直接作为对象存进 UserDefaults，常见做法是 JSONEncoder 编码成 Data，再保存 Data；读取时用 JSONDecoder 还原。",
                interviewQuestion: "UserDefaults 怎么保存一个 Codable 的用户模型？",
                standardAnswer: "让模型遵守 Codable，保存时 JSONEncoder().encode(model) 得到 Data，再 defaults.set(data, forKey:)；读取时取 Data，再 JSONDecoder().decode(Model.self, from: data)。失败要处理 nil 和版本兼容。",
                usageScenario: "少量用户偏好模型、简单筛选条件、非敏感的本地展示配置。登录凭证仍然放 Keychain，UserDefaults 只保存非敏感展示状态。",
                prosAndCons: "优点是类型清晰、代码少；缺点是模型变更要考虑字段默认值和解码失败，大对象仍不适合放这里。",
                memoryLine: "面试速记：Codable 进 UserDefaults，要先变 Data。"
            ),
            DataPersistenceReviewItem(
                title: "synchronize 为什么废弃",
                coreConcept: "synchronize 用来强制把内存里的偏好同步到磁盘，但现代 iOS 会自动在合适时机同步。",
                interviewQuestion: "UserDefaults.synchronize 为什么不建议用了？",
                standardAnswer: "因为系统已经自动管理同步时机，手动调用通常没必要，还可能造成阻塞式磁盘 IO。现在写完 set 后让系统自动落盘即可，只有极少数历史兼容场景才会看到它。",
                usageScenario: "普通业务保存开关、配置后不用调用 synchronize；需要立刻跨进程读取时也应重新评估设计，而不是习惯性强刷磁盘。",
                prosAndCons: "优点是历史上能强制同步；缺点是破坏系统调度、可能卡顿，所以面试里要明确说不再主动调用。",
                memoryLine: "面试速记：synchronize 过时点在于系统会自动同步，手动强刷反而可能卡。"
            )
        ]
    }

    func makeFileManagerItems() -> [DataPersistenceReviewItem] {
        [
            DataPersistenceReviewItem(
                title: "Documents / Cache / tmp 区别",
                coreConcept: "Documents 放用户生成或需要长期保留的数据；Library/Caches 放可重新生成的缓存；tmp 放临时文件，系统可能随时清理。",
                interviewQuestion: "Documents、Caches、tmp 分别存什么？会不会被 iCloud 备份？",
                standardAnswer: "Documents 会持久保存，默认可能参与备份，适合用户文档。Caches 不备份，空间紧张可能被系统清理，适合图片和接口缓存。tmp 不备份，生命周期最短，适合下载中间文件和临时解压。",
                usageScenario: "用户导出的 PDF 放 Documents；网络图片缩略图放 Caches；上传前压缩文件、临时下载包放 tmp。",
                prosAndCons: "Documents 稳但要控制备份；Caches 适合缓存但不能依赖永久存在；tmp 最轻但随时可能消失。",
                memoryLine: "面试速记：Documents 保用户数据，Caches 保可再生缓存，tmp 保临时过程。"
            ),
            DataPersistenceReviewItem(
                title: "沙盒机制",
                coreConcept: "iOS App 默认运行在独立沙盒中，只能访问自己的 Bundle、Documents、Library、tmp 等目录，不能随意读写其他 App 的数据。",
                interviewQuestion: "iOS 沙盒是什么？为什么 App 不能直接访问别的 App 文件？",
                standardAnswer: "沙盒是系统级隔离机制，每个 App 有独立容器目录和权限边界。访问文件要通过自己容器路径、系统授权能力或安全的共享机制，目的是保护隐私和系统安全。",
                usageScenario: "保存本地数据库、导入导出文件、下载离线资源时，都应该用 FileManager 获取沙盒目录 URL，而不是硬编码路径。",
                prosAndCons: "优点是安全、隔离、减少互相破坏；缺点是跨 App 共享受限，需要 App Groups、Document Picker、Share Extension 等机制。",
                memoryLine: "面试速记：沙盒就是每个 App 的独立文件小院子。"
            ),
            DataPersistenceReviewItem(
                title: "文件读写",
                coreConcept: "小文件可以用 Data、String 的 write/read API；大文件、追加写入、流式处理更适合 FileHandle 或 InputStream/OutputStream。",
                interviewQuestion: "iOS 文件读写一般怎么做？如何避免写坏文件？",
                standardAnswer: "先用 FileManager 拿目录 URL，必要时 createDirectory，再用 data.write(to:options:.atomic) 原子写入。耗时读写放后台队列，UI 更新回主线程。大文件避免一次性读入内存。",
                usageScenario: "缓存接口 JSON、保存日志、下载文件、导出图片和 PDF、读取本地配置模板。",
                prosAndCons: "优点是灵活、适合二进制和大文件；缺点是要自己处理目录、错误、并发、清理和文件命名。",
                memoryLine: "面试速记：小文件 Data 原子写，大文件流式读写，耗时别堵主线程。"
            ),
            DataPersistenceReviewItem(
                title: "图片缓存方案",
                coreConcept: "常见方案是内存缓存 + 磁盘缓存：内存用 NSCache，磁盘放 Caches 目录，key 通常由图片 URL 哈希得到。",
                interviewQuestion: "让你设计一个图片缓存，你怎么做？",
                standardAnswer: "先查内存，命中直接显示；未命中查磁盘，读到后回填内存；都没有再下载。下载后按展示尺寸下采样，后台解码，写入磁盘和内存。配合过期时间、容量上限和 LRU 清理。",
                usageScenario: "头像、商品图、文章封面、聊天图片缩略图，尤其是 UITableView/UICollectionView 快速滚动场景。",
                prosAndCons: "优点是减少网络和解码成本、提升滑动流畅度；缺点是要处理并发、复用错图、磁盘膨胀和清理策略。",
                memoryLine: "面试速记：图片缓存先内存、再磁盘、再网络，落盘放 Caches。"
            ),
            DataPersistenceReviewItem(
                title: "文件删除与清理",
                coreConcept: "FileManager 可以 removeItem、枚举目录、读取文件属性，根据大小、时间、业务 key 做清理。",
                interviewQuestion: "缓存文件怎么删除和清理？清理时要注意什么？",
                standardAnswer: "按目录集中管理缓存文件，清理时枚举 Caches 子目录，根据 fileSize、modificationDate、过期时间或总容量删除。删除要处理错误，避免误删 Documents 用户数据，必要时后台执行。",
                usageScenario: "退出登录清理用户缓存、设置页一键清缓存、磁盘容量超过阈值自动淘汰老文件。",
                prosAndCons: "优点是可控、能释放空间；缺点是策略写不好容易误删、卡顿或把仍在使用的文件删掉。",
                memoryLine: "面试速记：清缓存删 Caches，别误伤 Documents。"
            )
        ]
    }

    func makeKeychainItems() -> [DataPersistenceReviewItem] {
        [
            DataPersistenceReviewItem(
                title: "为什么比 UserDefaults 安全",
                coreConcept: "Keychain 是系统提供的安全凭证存储，数据受系统安全服务、访问控制和数据保护机制管理，不是普通 plist 明文文件。",
                interviewQuestion: "Keychain 为什么比 UserDefaults 安全？",
                standardAnswer: "UserDefaults 主要是偏好 plist，不加密，适合非敏感小数据。Keychain 通过 Security.framework 存储密码、token、证书等敏感数据，可设置访问组、可访问时机和生物识别等访问控制。",
                usageScenario: "保存 access token、refresh token、登录账号标识、设备私钥、证书、第三方 SDK 凭证。",
                prosAndCons: "优点是安全级别高、适合敏感信息；缺点是 API 偏底层、调试不方便、读写比 UserDefaults 更重。",
                memoryLine: "面试速记：偏好放 UserDefaults，凭证放 Keychain。"
            ),
            DataPersistenceReviewItem(
                title: "token 为什么放 Keychain",
                coreConcept: "token 是登录态凭证，泄露后可能直接代表用户身份，必须按敏感信息处理。",
                interviewQuestion: "登录 token 为什么不能直接放 UserDefaults？",
                standardAnswer: "UserDefaults 容易被备份、调试或越狱环境读取，不适合保存凭证。Keychain 可以设置 kSecClassGenericPassword、account、service 和 accessibility，降低 token 泄露风险。",
                usageScenario: "App 冷启动恢复登录态、刷新 access token、多个 target 通过 Keychain Access Group 共享登录凭证。",
                prosAndCons: "优点是安全持久、适合跨启动登录态；缺点是退出登录必须主动删除，accessibility 选错会影响后台刷新能力。",
                memoryLine: "面试速记：token 等于钥匙，钥匙进 Keychain。"
            ),
            DataPersistenceReviewItem(
                title: "Keychain 的加密机制",
                coreConcept: "Keychain 条目由系统安全服务托管，结合设备硬件安全能力和 Data Protection class 控制加密与解锁时机。",
                interviewQuestion: "Keychain 是怎么加密和控制访问的？",
                standardAnswer: "开发者不直接管理密钥，系统负责加密和存储。可以通过 kSecAttrAccessibleWhenUnlocked、AfterFirstUnlock、ThisDeviceOnly 等属性控制什么时候能访问、是否迁移备份；也可用 SecAccessControl 加 Face ID/Touch ID。",
                usageScenario: "只在用户解锁后读取 token、设备私钥不允许迁移到新设备、敏感操作前要求生物识别验证。",
                prosAndCons: "优点是系统级保护、可配置访问条件；缺点是属性选择需要结合业务，比如后台刷新不能随便用 WhenUnlocked。",
                memoryLine: "面试速记：Keychain 加密不用自己造轮子，关键是选对 accessible。"
            ),
            DataPersistenceReviewItem(
                title: "卸载 App 后是否还存在",
                coreConcept: "Keychain 数据通常不会像沙盒文件那样在 App 卸载时自动清空，同 bundle/access group 的 App 重装后可能还能读到。",
                interviewQuestion: "App 卸载重装后，Keychain 里的 token 还在吗？",
                standardAnswer: "面试里一般回答：Keychain 可能仍然存在，不应依赖卸载来清登录态。真实业务最好在首次安装时结合 UserDefaults 标记判断是否需要清理旧 Keychain，退出登录时必须主动删除。",
                usageScenario: "重装后保留设备标识、避免重复登录；或者出于安全要求，首次启动检测到新安装就清掉旧 token。",
                prosAndCons: "优点是重装后可保留凭证或设备标识；缺点是可能带来隐私和账号串用风险，要有明确清理策略。",
                memoryLine: "面试速记：Keychain 卸载后可能还在，退出登录要主动删。"
            ),
            DataPersistenceReviewItem(
                title: "登录信息持久化",
                coreConcept: "登录持久化通常把敏感凭证放 Keychain，把非敏感展示状态放 UserDefaults 或本地数据库。",
                interviewQuestion: "你会怎么设计登录信息持久化？",
                standardAnswer: "access token、refresh token、账号唯一标识放 Keychain；昵称、头像 URL、上次登录时间等非敏感信息可放 UserDefaults 或数据库。启动时读 Keychain 判断是否有登录态，再校验 token 过期并刷新。",
                usageScenario: "自动登录、token 续期、退出登录清理用户态、切换账号保存最近登录账号。",
                prosAndCons: "优点是安全边界清楚、恢复登录体验好；缺点是要处理 token 过期、刷新失败、账号切换和清理完整性。",
                memoryLine: "面试速记：登录态分层存，敏感凭证 Keychain，展示数据另存。"
            )
        ]
    }

    func makeSQLiteCoreDataItems() -> [DataPersistenceReviewItem] {
        [
            DataPersistenceReviewItem(
                title: "SQLite 和 CoreData 区别",
                coreConcept: "SQLite 是轻量关系型数据库引擎；CoreData 是对象图管理和持久化框架，底层常用 SQLite 作为 persistent store。",
                interviewQuestion: "SQLite 和 CoreData 有什么区别？CoreData 是数据库吗？",
                standardAnswer: "SQLite 直接写 SQL、表、索引和事务，控制细；CoreData 管的是对象、关系、上下文、变更跟踪、faulting 和持久化。CoreData 不是数据库本身，它可以用 SQLite 存储。",
                usageScenario: "复杂 SQL、跨平台库、手写性能优化用 SQLite；对象关系复杂、需要状态管理和迁移支持时可以用 CoreData。",
                prosAndCons: "SQLite 优点是透明可控，缺点是手写 SQL 和模型映射成本高；CoreData 优点是对象化和系统能力多，缺点是学习成本和调试成本高。",
                memoryLine: "面试速记：SQLite 是库，CoreData 是对象图框架。"
            ),
            DataPersistenceReviewItem(
                title: "CoreData 本质",
                coreConcept: "CoreData 的核心是 Managed Object Model、Managed Object Context、Persistent Store Coordinator 和 Persistent Store 协同工作。",
                interviewQuestion: "CoreData 本质是什么？它帮我们做了什么？",
                standardAnswer: "它管理对象图、对象生命周期、关系、查询、懒加载 fault、脏数据跟踪、保存和迁移。开发者操作对象和 context，保存时由持久化栈写入底层 store。",
                usageScenario: "离线数据、收藏列表、复杂实体关系、草稿箱、需要增删改查和本地状态跟踪的业务。",
                prosAndCons: "优点是对象关系和变更管理强；缺点是栈复杂，简单缓存用它会显得重。",
                memoryLine: "面试速记：CoreData 管对象图，不只是帮你写 SQLite。"
            ),
            DataPersistenceReviewItem(
                title: "NSManagedObject",
                coreConcept: "NSManagedObject 是被 CoreData context 管理的模型对象，属性通常由模型文件动态生成或声明，生命周期和 context 绑定。",
                interviewQuestion: "NSManagedObject 和普通 Swift model 有什么区别？",
                standardAnswer: "NSManagedObject 不是纯值模型，它有 managedObjectContext、objectID、fault 状态和 KVC/KVO 能力。它不能脱离 context 随便跨线程传递，保存也依赖 context。",
                usageScenario: "表示数据库实体，比如 UserEntity、MessageEntity、OrderEntity，并通过 FetchRequest 查询和 context 保存。",
                prosAndCons: "优点是和 CoreData 能力深度结合；缺点是侵入性强，不适合作为网络 DTO 或 UI 展示模型到处传。",
                memoryLine: "面试速记：NSManagedObject 是 context 管的对象，不是普通 struct。"
            ),
            DataPersistenceReviewItem(
                title: "多线程问题",
                coreConcept: "CoreData 遵守队列限制：ManagedObjectContext 只能在自己的队列使用，NSManagedObject 不要跨线程直接传。",
                interviewQuestion: "CoreData 多线程要注意什么？",
                standardAnswer: "主线程 UI 用 viewContext，后台导入用 privateQueueContext。所有 context 操作用 perform/performAndWait，跨线程传 objectID，再在目标 context 里 existingObject(with:) 重新取对象。",
                usageScenario: "后台批量导入聊天记录、同步离线订单、主线程刷新列表、多个 context 合并保存通知。",
                prosAndCons: "优点是按 context 隔离能保证一致性；缺点是对象跨线程误用很容易崩溃或数据错乱。",
                memoryLine: "面试速记：CoreData 跨线程传 objectID，不传 NSManagedObject。"
            ),
            DataPersistenceReviewItem(
                title: "数据迁移",
                coreConcept: "CoreData 模型变更后，需要从旧 model version 迁移到新 version，常见有轻量迁移和重量级迁移。",
                interviewQuestion: "CoreData 数据迁移怎么做？加字段会不会丢数据？",
                standardAnswer: "简单新增可选字段、设置默认值、重命名并配置 Renaming ID，通常可用 lightweight migration。复杂结构拆分、合并、数据转换要写 mapping model 或自定义迁移逻辑。",
                usageScenario: "版本升级新增用户字段、消息表字段改名、实体拆分、历史数据补默认值。",
                prosAndCons: "轻量迁移简单省事但能力有限；重量级迁移可控但成本高，发布前必须用旧版本数据充分测试。",
                memoryLine: "面试速记：小改轻量迁移，大改自定义迁移。"
            ),
            DataPersistenceReviewItem(
                title: "什么时候不用 CoreData",
                coreConcept: "CoreData 适合对象关系和本地状态管理，不适合所有持久化场景。",
                interviewQuestion: "哪些场景你不会用 CoreData？",
                standardAnswer: "少量配置用 UserDefaults，敏感凭证用 Keychain，图片和大文件用 FileManager，简单 JSON 缓存可直接文件存储，强 SQL 分析或跨平台共享可用 SQLite。",
                usageScenario: "启动开关、token、图片缓存、一次性离线包、简单接口缓存、小工具类 App。",
                prosAndCons: "不用 CoreData 的好处是实现轻、调试简单；缺点是当数据关系变复杂时，自己维护查询、迁移和一致性会越来越难。",
                memoryLine: "面试速记：CoreData 不是银弹，小数据、小文件、小凭证各回各家。"
            )
        ]
    }

    func makeCodableItems() -> [DataPersistenceReviewItem] {
        [
            DataPersistenceReviewItem(
                title: "Codable 原理",
                coreConcept: "Codable 是 Encodable & Decodable 的组合协议，编译器可以根据属性和 CodingKeys 自动合成编码、解码实现。",
                interviewQuestion: "Codable 的原理是什么？为什么很多模型不用手写解析？",
                standardAnswer: "当模型属性都遵守 Codable 时，编译器会生成 encode(to:) 和 init(from:)。Encoder/Decoder 提供容器，模型把属性按 key 写入或读出，JSON 只是其中一种编码格式。",
                usageScenario: "网络 JSON 解析、本地 JSON 缓存、UserDefaults 存小模型、文件持久化配置。",
                prosAndCons: "优点是类型安全、样板代码少；缺点是复杂映射、动态 key、脏数据兼容时仍要自定义解码。",
                memoryLine: "面试速记：Codable 靠协议 + 编译器合成 + Encoder/Decoder 容器。"
            ),
            DataPersistenceReviewItem(
                title: "Encodable / Decodable",
                coreConcept: "Encodable 表示能编码出去，Decodable 表示能从外部数据解码回来，Codable 同时具备两者能力。",
                interviewQuestion: "Encodable、Decodable、Codable 有什么区别？",
                standardAnswer: "只需要上传或保存时遵守 Encodable；只需要解析接口返回时遵守 Decodable；既要读又要写时遵守 Codable。Codable 本质是 typealias Codable = Encodable & Decodable。",
                usageScenario: "请求参数模型只编码，响应模型只解码，本地缓存模型通常既编码又解码。",
                prosAndCons: "优点是职责精确、编译期约束明确；缺点是初学者容易所有模型都无脑 Codable，暴露不必要能力。",
                memoryLine: "面试速记：能写是 Encodable，能读是 Decodable，读写都有是 Codable。"
            ),
            DataPersistenceReviewItem(
                title: "JSONEncoder / JSONDecoder",
                coreConcept: "JSONEncoder 把 Encodable 转成 JSON Data，JSONDecoder 把 JSON Data 解成 Decodable；两者都支持 key、date、data 等策略配置。",
                interviewQuestion: "JSONEncoder 和 JSONDecoder 常见怎么用？有哪些策略？",
                standardAnswer: "encode 可能 throw，要用 try；decode 需要目标类型和 Data。常见策略有 keyEncodingStrategy、keyDecodingStrategy、dateEncodingStrategy、dateDecodingStrategy，能处理 snake_case、时间戳和 ISO8601。",
                usageScenario: "网络层解析响应、把模型写入本地 JSON 文件、把小模型编码成 Data 放 UserDefaults。",
                prosAndCons: "优点是系统原生、和 Codable 配合自然；缺点是错误信息需要包装，服务端字段不稳定时要做兼容。",
                memoryLine: "面试速记：Encoder 管模型变 Data，Decoder 管 Data 变模型。"
            ),
            DataPersistenceReviewItem(
                title: "自定义 CodingKeys",
                coreConcept: "CodingKeys 用来声明属性和外部字段名的映射，也可以排除不参与编码解码的属性。",
                interviewQuestion: "字段名不一致时 Codable 怎么处理？比如 user_id 对应 userID？",
                standardAnswer: "在模型里定义 enum CodingKeys: String, CodingKey，把 case userID = \"user_id\"。如果需要默认值、嵌套结构或特殊转换，就自定义 init(from:) 和 encode(to:)。",
                usageScenario: "接口字段 snake_case、本地属性驼峰、忽略 UI 状态字段、兼容旧接口字段名。",
                prosAndCons: "优点是映射清晰、类型安全；缺点是字段很多时需要维护，复杂嵌套仍要手写逻辑。",
                memoryLine: "面试速记：名字对不上找 CodingKeys，结构对不上自定义 init。"
            ),
            DataPersistenceReviewItem(
                title: "为什么比 NSCoding 简单",
                coreConcept: "Codable 面向 Swift 类型系统，支持 struct、enum、class，并能自动合成；NSCoding 偏 Objective-C 风格，需要手写 key 和 encode/decode。",
                interviewQuestion: "为什么说 Codable 比 NSCoding 简单？",
                standardAnswer: "Codable 不需要继承 NSObject，也不强依赖 NSCoder；大多数模型声明遵守协议就能自动生成实现。NSCoding 要手写 encode(with:) 和 init(coder:)，字段多时样板代码多且容易漏。",
                usageScenario: "Swift 网络模型、本地 JSON 缓存、配置文件读写优先 Codable；老项目归档、和 Objective-C 框架交互时可能还会遇到 NSCoding/NSSecureCoding。",
                prosAndCons: "Codable 优点是简单、类型安全、适合值类型；缺点是复杂兼容要手写。NSCoding 优点是老体系兼容好；缺点是繁琐且不够 Swift 化。",
                memoryLine: "面试速记：Codable 是 Swift 自动挡，NSCoding 是手动挡。"
            )
        ]
    }
}

private final class DataPersistenceReviewHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DataPersistenceInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = DataPersistenceInterviewStyle.titleTextColor
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
        label.textColor = DataPersistenceInterviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = DataPersistenceInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = DataPersistenceInterviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = DataPersistenceInterviewStyle.secondaryTextColor
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
        contentView.backgroundColor = DataPersistenceInterviewStyle.backgroundColor
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
        module: DataPersistenceReviewModule,
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

private final class DataPersistenceReviewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DataPersistenceInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = DataPersistenceInterviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = DataPersistenceInterviewStyle.titleTextColor
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
        selectedBackgroundView?.backgroundColor = DataPersistenceInterviewStyle.selectionColor
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
        item: DataPersistenceReviewItem,
        rows: [DataPersistenceInterviewReviewViewController.RowKind],
        tintColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = tintColor.withAlphaComponent(0.26)
        titleLabel.text = item.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = tintColor.withAlphaComponent(0.20).cgColor

        rows.forEach { row in
            let fieldView = DataPersistenceReviewFieldView()
            fieldView.configure(
                title: row.title,
                body: row.text(for: item),
                symbolName: row.symbolName,
                tintColor: tintColor,
                isMemoryLine: row == .memoryLine
            )
            contentStackView.addArrangedSubview(fieldView)
        }
    }
}

private final class DataPersistenceReviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = DataPersistenceInterviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = DataPersistenceInterviewStyle.bodyTextColor
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
        backgroundColor = DataPersistenceInterviewStyle.fieldBackgroundColor
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
        titleLabel.textColor = isMemoryLine ? tintColor : DataPersistenceInterviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = isMemoryLine
            ? .systemFont(ofSize: 15, weight: .semibold)
            : .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = isMemoryLine ? DataPersistenceInterviewStyle.titleTextColor : DataPersistenceInterviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : DataPersistenceInterviewStyle.fieldBackgroundColor
    }
}

private final class PaddingLabel: UILabel {

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
