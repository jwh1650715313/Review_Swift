//
//  MQTTInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/18.
//

import UIKit

private enum MQTTInterviewStyle {

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

fileprivate struct MQTTReviewModule {

    let id: String
    let title: String
    let subtitle: String
    let symbolName: String
    let tintColor: UIColor
    let items: [MQTTReviewItem]
}

fileprivate struct MQTTReviewItem {

    let title: String
    let question: String
    let coreAnswer: String
    let standardAnswer: String
    let plainExplanation: String
    let codeScene: String
    let memoryLine: String
}

final class MQTTInterviewReviewViewController: UITableViewController {

    fileprivate enum RowKind: CaseIterable {

        case question
        case coreAnswer
        case standardAnswer
        case plainExplanation
        case codeScene
        case memoryLine

        var title: String {
            switch self {
            case .question:
                return "面试官问"
            case .coreAnswer:
                return "你回答"
            case .standardAnswer:
                return "面试标准回答"
            case .plainExplanation:
                return "通俗理解"
            case .codeScene:
                return "iOS 代码场景"
            case .memoryLine:
                return "一句话速记"
            }
        }

        var symbolName: String {
            switch self {
            case .question:
                return "questionmark.circle.fill"
            case .coreAnswer:
                return "checkmark.seal.fill"
            case .standardAnswer:
                return "text.book.closed.fill"
            case .plainExplanation:
                return "person.wave.2.fill"
            case .codeScene:
                return "curlybraces.square.fill"
            case .memoryLine:
                return "bolt.fill"
            }
        }

        func text(for item: MQTTReviewItem) -> String {
            switch self {
            case .question:
                return item.question
            case .coreAnswer:
                return item.coreAnswer
            case .standardAnswer:
                return item.standardAnswer
            case .plainExplanation:
                return item.plainExplanation
            case .codeScene:
                return item.codeScene
            case .memoryLine:
                return item.memoryLine
            }
        }
    }

    private let cellReuseIdentifier = "MQTTInterviewCell"
    private let headerReuseIdentifier = "MQTTInterviewHeaderView"

    private lazy var modules: [MQTTReviewModule] = makeModules()
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
            title = "MQTT 面试八股"
        }

        setupAppearance()
        setupTableView()
        updateExpandButton()
    }

    private func setupAppearance() {
        view.backgroundColor = MQTTInterviewStyle.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = MQTTInterviewStyle.accentColors[0]
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupTableView() {
        tableView.backgroundColor = MQTTInterviewStyle.backgroundColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.sectionHeaderTopPadding = 10
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 28, right: 0)
        tableView.register(MQTTReviewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(MQTTReviewHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
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
        ) as? MQTTReviewCell ?? MQTTReviewCell(style: .default, reuseIdentifier: cellReuseIdentifier)

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
        ) as? MQTTReviewHeaderView ?? MQTTReviewHeaderView(reuseIdentifier: headerReuseIdentifier)

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

private extension MQTTInterviewReviewViewController {

    func makeModules() -> [MQTTReviewModule] {
        [
            MQTTReviewModule(
                id: "basic-model",
                title: "基础模型",
                subtitle: "MQTT、Broker、Topic、发布订阅",
                symbolName: "dot.radiowaves.left.and.right",
                tintColor: MQTTInterviewStyle.accentColors[0],
                items: makeBasicItems()
            ),
            MQTTReviewModule(
                id: "protocol-compare",
                title: "协议对比",
                subtitle: "MQTT vs HTTP、WebSocket、TCP / UDP",
                symbolName: "arrow.left.arrow.right.circle.fill",
                tintColor: MQTTInterviewStyle.accentColors[1],
                items: makeCompareItems()
            ),
            MQTTReviewModule(
                id: "reliability",
                title: "可靠性机制",
                subtitle: "QoS、retain、clean session",
                symbolName: "shield.checkered",
                tintColor: MQTTInterviewStyle.accentColors[2],
                items: makeReliabilityItems()
            ),
            MQTTReviewModule(
                id: "connection-iot",
                title: "连接与 IoT 场景",
                subtitle: "keep alive、长连接、弱网、低功耗",
                symbolName: "antenna.radiowaves.left.and.right",
                tintColor: MQTTInterviewStyle.accentColors[3],
                items: makeConnectionItems()
            ),
            MQTTReviewModule(
                id: "summary",
                title: "三版总结",
                subtitle: "超短速记、面试背诵、真正理解",
                symbolName: "menucard.fill",
                tintColor: MQTTInterviewStyle.accentColors[4],
                items: makeSummaryItems()
            )
        ]
    }

    func makeBasicItems() -> [MQTTReviewItem] {
        [
            MQTTReviewItem(
                title: "MQTT 是什么",
                question: "面试官问：MQTT 是什么？",
                coreAnswer: "你回答：MQTT 是轻量级发布订阅消息协议，特别适合弱网、低功耗、IoT 场景。",
                standardAnswer: "MQTT 基于 TCP 长连接，客户端不直接互相通信，而是通过 Broker 中转。客户端可以向 Topic 发布消息，也可以订阅 Topic 接收消息。它协议头小、通信开销低，还支持 QoS、retain、session、keep alive 等机制。",
                plainExplanation: "HTTP 像“你问我答”，MQTT 像“订阅频道”。设备往频道里发消息，关心的人自动收到。",
                codeScene: """
                mqtt.connect()
                mqtt.subscribe("device/123/status")
                """,
                memoryLine: "MQTT = TCP 长连接 + 发布订阅 + Broker 中转。"
            ),
            MQTTReviewItem(
                title: "Broker",
                question: "面试官问：Broker 是什么？",
                coreAnswer: "你回答：Broker 是 MQTT 消息服务器，负责接收、路由、转发消息。",
                standardAnswer: "MQTT 客户端之间不直接通信，所有消息先发给 Broker。Broker 根据 Topic 和订阅关系把消息转发给对应客户端，同时处理认证、鉴权、QoS、retain、session 等能力。",
                plainExplanation: "Broker 就是消息中转站，像微信群服务器，也像快递分拣中心。",
                codeScene: """
                mqtt.host = "mqtt.example.com"
                mqtt.port = 1883
                mqtt.connect()
                """,
                memoryLine: "客户端不互找，所有消息先找 Broker。"
            ),
            MQTTReviewItem(
                title: "Topic",
                question: "面试官问：Topic 是什么？",
                coreAnswer: "你回答：Topic 是消息路径，用来做消息分类和路由。",
                standardAnswer: "发布者把消息发到某个 Topic，订阅者订阅对应 Topic 后就能收到消息。Topic 常用层级结构，比如 device/123/status，也支持 + 和 # 通配符。",
                plainExplanation: "Topic 就是频道名。你订阅了设备状态频道，设备状态变化就会推给你。",
                codeScene: """
                mqtt.subscribe("user/1001/device/+/status")
                // + 表示单层通配，订阅这个用户下所有设备状态
                """,
                memoryLine: "Topic = 消息频道，+ 单层通配，# 多层通配。"
            ),
            MQTTReviewItem(
                title: "Publish / Subscribe",
                question: "面试官问：MQTT 的发布订阅模型怎么理解？",
                coreAnswer: "你回答：发布者和订阅者通过 Topic 解耦，彼此不需要知道对方存在。",
                standardAnswer: "发布者只负责把消息发到 Topic，订阅者只负责订阅 Topic。Broker 负责匹配订阅关系并转发消息。这种模型适合多端、多设备、实时消息分发。",
                plainExplanation: "发消息的人只管发到频道，看频道的人自动收到。",
                codeScene: """
                mqtt.publish("device/123/cmd", withString: "open")
                mqtt.subscribe("device/123/status")
                """,
                memoryLine: "Pub/Sub 的核心价值是解耦。"
            )
        ]
    }

    func makeCompareItems() -> [MQTTReviewItem] {
        [
            MQTTReviewItem(
                title: "MQTT 和 HTTP 区别",
                question: "面试官问：MQTT 和 HTTP 有什么区别？",
                coreAnswer: "你回答：HTTP 是请求响应，MQTT 是长连接发布订阅。",
                standardAnswer: "HTTP 通常由客户端主动请求服务端，适合接口调用、资源获取。MQTT 是长连接，Broker 可以主动把订阅消息推给客户端，适合实时状态同步和设备通信。MQTT 报文更小，弱网和低功耗场景更友好。",
                plainExplanation: "HTTP 是“我问你答”，MQTT 是“有消息你叫我”。",
                codeScene: """
                // HTTP：App 定时查状态
                GET /device/123/status

                // MQTT：App 订阅状态变化
                mqtt.subscribe("device/123/status")
                """,
                memoryLine: "HTTP 拉，MQTT 推；状态频繁变化时 MQTT 更舒服。"
            ),
            MQTTReviewItem(
                title: "MQTT 和 WebSocket 区别",
                question: "面试官问：MQTT 和 WebSocket 有什么区别？",
                coreAnswer: "你回答：MQTT 是消息协议，WebSocket 是双向通信通道。",
                standardAnswer: "WebSocket 解决的是客户端和服务端之间建立全双工连接，本身不规定消息语义。MQTT 定义了 Topic、QoS、retain、session 等消息机制。MQTT 可以直接跑在 TCP 上，也可以跑在 WebSocket 上。",
                plainExplanation: "WebSocket 是电话线，MQTT 是电话里怎么说话的规则。",
                codeScene: """
                // iOS App 常见：MQTT over TCP
                mqtt.port = 1883

                // Web 端常见：MQTT over WebSocket
                wss://mqtt.example.com/mqtt
                """,
                memoryLine: "WebSocket 管通道，MQTT 管消息语义。"
            ),
            MQTTReviewItem(
                title: "TCP 还是 UDP",
                question: "面试官问：MQTT 是基于 TCP 还是 UDP？",
                coreAnswer: "你回答：标准 MQTT 基于 TCP，不是 UDP。",
                standardAnswer: "MQTT 运行在 TCP 之上，默认端口 1883，TLS 加密通常是 8883。它依赖 TCP 提供有序、可靠的字节流。需要注意，MQTT-SN 是面向传感器网络的变体，可以跑在 UDP 上，但平时说的 MQTT 默认是 TCP。",
                plainExplanation: "普通 MQTT 走 TCP，别答 UDP；UDP 那套通常是 MQTT-SN 的事。",
                codeScene: """
                mqtt.port = 1883       // MQTT over TCP
                mqtt.enableSSL = true  // 常见 TLS 端口 8883
                """,
                memoryLine: "标准 MQTT = TCP，1883；TLS = 8883。"
            )
        ]
    }

    func makeReliabilityItems() -> [MQTTReviewItem] {
        [
            MQTTReviewItem(
                title: "QoS 0 / 1 / 2",
                question: "面试官问：MQTT 的 QoS 有哪些？",
                coreAnswer: "你回答：QoS 控制消息可靠性，级别越高越可靠，但开销越大。",
                standardAnswer: "QoS 0 是最多一次，发了就不管，可能丢。QoS 1 是至少一次，保证到达，但可能重复。QoS 2 是只有一次，通过更复杂的握手保证不丢不重，但性能开销最大。实际业务里 QoS 1 最常用，配合业务幂等处理重复消息。",
                plainExplanation: "QoS0：喊一声，听没听见随缘。QoS1：必须回我，但可能重复喊。QoS2：双方反复确认，只收一次。",
                codeScene: """
                mqtt.publish("device/123/log", withString: "37.2", qos: .qos0)
                mqtt.publish("device/123/cmd", withString: "open", qos: .qos1)
                // 开锁指令用 QoS1，再用 messageId 做幂等
                """,
                memoryLine: "QoS0 可能丢，QoS1 可能重，QoS2 不丢不重但贵。"
            ),
            MQTTReviewItem(
                title: "retain",
                question: "面试官问：retain 是什么？",
                coreAnswer: "你回答：retain 让 Broker 保存某个 Topic 的最后一条消息，新订阅者一订阅就能拿到。",
                standardAnswer: "发布 retained 消息后，Broker 会把它作为该 Topic 的最新值保存下来。后续新客户端订阅这个 Topic 时，会立即收到这条 retained 消息。它不是历史消息队列，只保存最后一条。",
                plainExplanation: "retain 像公告栏，后来的人也能看到最后一次公告。",
                codeScene: """
                mqtt.publish(
                    "device/123/online",
                    withString: "1",
                    qos: .qos1,
                    retained: true
                )
                """,
                memoryLine: "retain 不是历史队列，只存最后一条。"
            ),
            MQTTReviewItem(
                title: "clean session",
                question: "面试官问：clean session 是什么？",
                coreAnswer: "你回答：clean session 决定断线后 Broker 要不要保留订阅关系和离线消息。",
                standardAnswer: "clean session 为 true 时，客户端断开后会话清掉，下次连接是全新会话。为 false 时，Broker 可以保留订阅关系，并在客户端重连后补发离线期间的 QoS 1/2 消息。MQTT 5 里拆成 Clean Start 和 Session Expiry。",
                plainExplanation: "true：下线就退群。false：下线还保留座位，回来能补消息。",
                codeScene: """
                mqtt.clientID = "ios-user-1001"
                mqtt.cleanSession = false
                // App 断网重连后补收重要设备告警
                """,
                memoryLine: "clean session false = 保留会话，重连可补重要消息。"
            )
        ]
    }

    func makeConnectionItems() -> [MQTTReviewItem] {
        [
            MQTTReviewItem(
                title: "keep alive",
                question: "面试官问：keep alive 是干什么的？",
                coreAnswer: "你回答：keep alive 用心跳检测长连接是否还活着。",
                standardAnswer: "客户端会在空闲时按 keep alive 间隔发送 PINGREQ，Broker 回复 PINGRESP。如果 Broker 长时间收不到客户端任何包，会认为连接失效并断开。它主要用来发现半开连接。",
                plainExplanation: "客户端定期说一句“我还在”，服务端回一句“收到”。",
                codeScene: """
                mqtt.keepAlive = 60
                // 弱网切换后更快发现连接失效，然后重连
                """,
                memoryLine: "keep alive = 心跳保活 + 发现假连接。"
            ),
            MQTTReviewItem(
                title: "长连接",
                question: "面试官问：MQTT 为什么说是长连接？",
                coreAnswer: "你回答：MQTT 建立 TCP 连接后会长期保持，消息可以随时双向发送。",
                standardAnswer: "MQTT 客户端连接 Broker 后，不会像普通 HTTP 请求那样马上断开，而是保持 TCP 连接。这样 Broker 可以实时把订阅消息推给客户端，减少频繁建连成本，提高实时性。",
                plainExplanation: "HTTP 像每次办事都重新排队，MQTT 像一直开着对讲机。",
                codeScene: """
                mqtt.connect()
                mqtt.didReceiveMessage = { message in
                    updateDeviceUI(message)
                }
                """,
                memoryLine: "长连接让 Broker 能主动推，不用 App 一直轮询。"
            ),
            MQTTReviewItem(
                title: "为什么适合 IoT",
                question: "面试官问：为什么 MQTT 适合 IoT？",
                coreAnswer: "你回答：因为它轻量、省流量、实时，适合弱网、低功耗和海量设备接入。",
                standardAnswer: "IoT 设备通常网络不稳定、带宽有限、功耗敏感。MQTT 报文头小，基于长连接，支持 QoS、遗嘱消息、retain、session，非常适合设备状态上报、远程控制和告警推送。",
                plainExplanation: "设备电少、网差、话还多，MQTT 正好省着说，还能保证重要消息送到。",
                codeScene: """
                device/lock/123/status
                device/lock/123/cmd
                device/sensor/456/report
                """,
                memoryLine: "IoT 的关键词：弱网、省电、小包、实时、海量连接。"
            )
        ]
    }

    func makeSummaryItems() -> [MQTTReviewItem] {
        [
            MQTTReviewItem(
                title: "超短速记版",
                question: "面试官问：你用一句口诀记 MQTT？",
                coreAnswer: "你回答：TCP 长连接 + Broker 中转 + Topic 路由 + Pub/Sub 解耦 + QoS 保可靠 + Retain 存最后 + Session 管离线 + KeepAlive 保活。",
                standardAnswer: """
                MQTT = 轻量级 IoT 消息协议
                Broker = 消息中转站
                Topic = 消息频道
                Pub/Sub = 发布订阅解耦
                HTTP = 请求响应，MQTT = 长连接推送
                WebSocket = 通道，MQTT = 协议
                QoS0 = 可能丢
                QoS1 = 可能重
                QoS2 = 不丢不重但贵
                retain = 保存最后一条
                clean session = 是否保留离线会话
                keep alive = 心跳保活
                MQTT 默认基于 TCP，1883/8883
                """,
                plainExplanation: "先背这版，面试被追问时再展开到 QoS、retain、session 和协议对比。",
                codeScene: """
                mqtt.connect()
                mqtt.subscribe("device/+/status")
                mqtt.publish("device/123/cmd", withString: "open", qos: .qos1)
                """,
                memoryLine: "MQTT 总口诀：长连中转，频道订阅，可靠靠 QoS，状态靠 retain。"
            ),
            MQTTReviewItem(
                title: "面试背诵版",
                question: "面试官问：你完整讲一下 MQTT？",
                coreAnswer: "你回答：MQTT 是轻量级发布订阅协议，基于 TCP 长连接，通过 Broker 和 Topic 解耦消息生产者与消费者。",
                standardAnswer: "发布者把消息发到 Topic，订阅者订阅 Topic 后由 Broker 转发。相比 HTTP 请求响应，MQTT 更适合服务端主动推送和实时状态同步。QoS 0 可能丢，QoS 1 可能重复，QoS 2 不丢不重但开销最大；实际项目常用 QoS 1 加业务幂等。retain 保存最后状态，clean session 管离线会话，keep alive 负责心跳保活。",
                plainExplanation: "这版适合面试主答：先说模型，再说对比，再说可靠性，最后落到 iOS 设备控制场景。",
                codeScene: """
                // 智能家居 App
                mqtt.subscribe("device/123/status")
                mqtt.publish("device/123/cmd", withString: "open", qos: .qos1)
                """,
                memoryLine: "背诵顺序：是什么 -> 怎么通信 -> 和 HTTP 区别 -> QoS -> retain/session/keepAlive -> iOS 场景。"
            ),
            MQTTReviewItem(
                title: "真正理解版",
                question: "面试官问：你项目里会怎么用 MQTT？",
                coreAnswer: "你回答：我会把 MQTT 当成设备消息总线，用 Topic 做路由，用 QoS 和幂等保证重要指令可靠，用 retain 和 session 处理最新状态与离线恢复。",
                standardAnswer: "iOS App、智能门锁、传感器都不互相直连，而是都连到 Broker。设备把状态发到状态 Topic，App 订阅；App 把控制命令发到命令 Topic，设备订阅。状态频繁变化用订阅比 HTTP 轮询省；重要命令用 QoS 1 并做幂等；最新状态用 retain；断线补消息用 clean session false；弱网重连靠 keep alive 和 reconnect。",
                plainExplanation: "它解决的不是“怎么请求一次接口”，而是“很多设备和很多客户端之间怎么低成本、实时、可靠地分发消息”。",
                codeScene: """
                device/lock/123/status  // 设备上报，App 订阅
                device/lock/123/cmd     // App 下发，设备订阅
                device/lock/123/event   // 告警事件，QoS1 + messageId 幂等
                """,
                memoryLine: "工程取舍一句话：状态走订阅，命令要幂等，最新值用 retain，离线靠 session。"
            )
        ]
    }
}

private final class MQTTReviewHeaderView: UITableViewHeaderFooterView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = MQTTInterviewStyle.headerBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: MQTTPaddingLabel = {
        let label = MQTTPaddingLabel()
        label.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textColor = MQTTInterviewStyle.titleTextColor
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
        label.textColor = MQTTInterviewStyle.titleTextColor
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = MQTTInterviewStyle.secondaryTextColor
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let countLabel: MQTTPaddingLabel = {
        let label = MQTTPaddingLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = MQTTInterviewStyle.titleTextColor
        label.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = MQTTInterviewStyle.secondaryTextColor
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
        contentView.backgroundColor = MQTTInterviewStyle.backgroundColor
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

    func configure(index: Int, module: MQTTReviewModule, isExpanded: Bool) {
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

private final class MQTTReviewCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = MQTTInterviewStyle.cardBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private let indexLabel: MQTTPaddingLabel = {
        let label = MQTTPaddingLabel()
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .bold)
        label.textColor = MQTTInterviewStyle.titleTextColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = MQTTInterviewStyle.titleTextColor
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
        selectedBackgroundView?.backgroundColor = MQTTInterviewStyle.selectionColor
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
        item: MQTTReviewItem,
        rows: [MQTTInterviewReviewViewController.RowKind],
        tintColor: UIColor
    ) {
        indexLabel.text = String(format: "%02d", index)
        indexLabel.backgroundColor = tintColor.withAlphaComponent(0.26)
        titleLabel.text = item.title
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = tintColor.withAlphaComponent(0.20).cgColor

        rows.forEach { row in
            let fieldView = MQTTReviewFieldView()
            fieldView.configure(
                title: row.title,
                body: row.text(for: item),
                symbolName: row.symbolName,
                tintColor: tintColor,
                isMemoryLine: row == .memoryLine,
                isCodeScene: row == .codeScene
            )
            contentStackView.addArrangedSubview(fieldView)
        }
    }
}

private final class MQTTReviewFieldView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = MQTTInterviewStyle.titleTextColor
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = MQTTInterviewStyle.bodyTextColor
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
        backgroundColor = MQTTInterviewStyle.fieldBackgroundColor
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
        isMemoryLine: Bool,
        isCodeScene: Bool
    ) {
        iconView.image = UIImage(systemName: symbolName)
        iconView.tintColor = tintColor
        titleLabel.text = title
        titleLabel.textColor = isMemoryLine ? tintColor : MQTTInterviewStyle.titleTextColor
        bodyLabel.text = body
        bodyLabel.font = {
            if isCodeScene {
                return .monospacedSystemFont(ofSize: 13, weight: .medium)
            }

            if isMemoryLine {
                return .systemFont(ofSize: 15, weight: .semibold)
            }

            return .systemFont(ofSize: 14, weight: .regular)
        }()
        bodyLabel.textColor = isMemoryLine ? MQTTInterviewStyle.titleTextColor : MQTTInterviewStyle.bodyTextColor
        backgroundColor = isMemoryLine
            ? tintColor.withAlphaComponent(0.16)
            : MQTTInterviewStyle.fieldBackgroundColor
    }
}

private final class MQTTPaddingLabel: UILabel {

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
