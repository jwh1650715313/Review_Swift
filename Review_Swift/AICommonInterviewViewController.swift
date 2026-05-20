//
//  AICommonInterviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/20.
//

import UIKit

final class AICommonInterviewViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "AI 常规高频面试题",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "AI 常规高频面试题",
            modules: Self.makeModules()
        )
    }
}

private extension AICommonInterviewViewController {

    static func makeModules() -> [InterviewReviewModule] {
        [
            module(
                id: "ai-api",
                title: "AI 接口怎么接",
                subtitle: "URLSession、HTTPS、POST、Bearer Token、JSON、Codable",
                symbolName: "network",
                colorIndex: 0,
                question: "iOS 里怎么调用 AI 大模型接口？",
                coreAnswer: "本质就是一次 HTTPS POST 请求。用 URLRequest 拼 URL、Header、Body，Authorization 放 Bearer Token，Body 用 JSONEncoder 编码，返回用 Codable 解析。",
                mnemonic: "接口六件套：HTTPS、POST、Bearer、JSON、Codable、URLSession。",
                followUp: "追问：Token 放哪？答：不要硬编码，线上放 Keychain 或安全配置；请求时只放 Header。",
                projectScenario: "聊天页发送用户问题时，组装 model 和 messages，请求成功后解析 assistant 内容，再回主线程刷新列表。",
                codeExample: """
                struct Message: Codable {
                    let role: String
                    let content: String
                }

                struct ChatBody: Encodable {
                    let model: String
                    let messages: [Message]
                }

                var request = URLRequest(url: URL(string: "https://api.example.com/v1/chat")!)
                request.httpMethod = "POST"
                request.setValue("Bearer \\(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONEncoder().encode(body)

                let (data, _) = try await URLSession.shared.data(for: request)
                let result = try JSONDecoder().decode(ChatResult.self, from: data)
                """
            ),
            module(
                id: "stream-output",
                title: "流式输出怎么实现",
                subtitle: "SSE、URLSessionDataDelegate、边接收边刷新 UI、打字机效果",
                symbolName: "dot.radiowaves.left.and.right",
                colorIndex: 1,
                question: "AI 聊天的流式输出在 iOS 怎么做？",
                coreAnswer: "常用 SSE。用 URLSessionDataDelegate 接收一段段 data，解析增量文本，主线程追加到最后一条消息，做局部刷新或直接更新 cell。",
                mnemonic: "SSE：边返回边刷新；UI：小步追加，少 reload。",
                followUp: "追问：为什么不用等全部返回？答：流式能降低首字延迟，用户感觉更快。",
                projectScenario: "AI 回复时创建一条空的 assistant 消息，收到 chunk 就拼接 content，同时做打字机效果和自动滚动。",
                codeExample: """
                final class StreamClient: NSObject, URLSessionDataDelegate {
                    var onText: ((String) -> Void)?

                    func urlSession(
                        _ session: URLSession,
                        dataTask: URLSessionDataTask,
                        didReceive data: Data
                    ) {
                        let chunk = String(decoding: data, as: UTF8.self)
                        DispatchQueue.main.async {
                            self.onText?(chunk)
                        }
                    }
                }

                let client = StreamClient()
                let session = URLSession(configuration: .default, delegate: client, delegateQueue: nil)
                session.dataTask(with: request).resume()
                """
            ),
            module(
                id: "websocket-sse",
                title: "WebSocket 和 SSE 区别",
                subtitle: "WebSocket 双向通信、SSE 服务端单向推送、AI 聊天更常用 SSE",
                symbolName: "arrow.left.arrow.right.circle.fill",
                colorIndex: 2,
                question: "WebSocket 和 SSE 有什么区别？AI 聊天常用哪个？",
                coreAnswer: "WebSocket 是全双工长连接，客户端和服务端都能主动发消息。SSE 是服务端单向推送，客户端发起 HTTP 请求后，服务端持续返回文本流；AI 聊天更常用 SSE。",
                mnemonic: "WebSocket 双向聊，SSE 服务端往回推。",
                followUp: "追问：什么时候用 WebSocket？答：实时游戏、IM、协同编辑这类双向高频通信更适合。",
                projectScenario: "AI 问答通常是用户先发请求，模型持续返回答案，通信方向天然适合 SSE；如果要多人协同聊天，可考虑 WebSocket。",
                codeExample: """
                // WebSocket：双向收发
                let socket = URLSession.shared.webSocketTask(with: socketURL)
                socket.resume()
                socket.send(.string("ping")) { error in
                    print(error as Any)
                }

                // SSE：普通 POST 请求 + 流式响应
                request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                URLSession(configuration: .default, delegate: sseClient, delegateQueue: nil)
                    .dataTask(with: request)
                    .resume()
                """
            ),
            module(
                id: "token",
                title: "Token 是什么",
                subtitle: "计费单位、上下文长度、中文消耗、历史消息裁剪",
                symbolName: "number.circle.fill",
                colorIndex: 3,
                question: "大模型里的 Token 是什么？为什么面试常问？",
                coreAnswer: "Token 是模型处理和计费的基本单位，不等于字符。上下文越长 token 越多，费用和耗时越高；中文通常比英文更容易消耗 token。",
                mnemonic: "Token：上下文越长越贵，历史越多越慢。",
                followUp: "追问：怎么控制 token？答：限制输入长度、裁剪历史、摘要旧消息、只带必要上下文。",
                projectScenario: "聊天历史很多时，只保留 system prompt、最近几轮消息和必要摘要，避免 token 暴涨导致超限或费用过高。",
                codeExample: """
                func trimMessages(_ messages: [Message]) -> [Message] {
                    guard let system = messages.first else { return messages }
                    let recent = messages.dropFirst().suffix(12)
                    return [system] + recent
                }

                let roughTokenCount = text.count / 2
                if roughTokenCount > 4000 {
                    print("需要裁剪或摘要")
                }
                """
            ),
            module(
                id: "context",
                title: "上下文怎么实现",
                subtitle: "message 数组、role、content、system / user / assistant、history 裁剪",
                symbolName: "text.bubble.fill",
                colorIndex: 4,
                question: "AI 聊天上下文在客户端怎么维护？",
                coreAnswer: "用 messages 数组维护对话，每条消息包含 role 和 content。system 定规则，user 是用户输入，assistant 是 AI 回复；请求时把必要历史一起带上。",
                mnemonic: "上下文三角色：system 定规矩，user 提问题，assistant 回答案。",
                followUp: "追问：历史都要传吗？答：不要全传，要按 token 预算裁剪或摘要。",
                projectScenario: "连续追问时，客户端把最近几轮聊天带给模型，让它知道上文；列表展示和接口入参可以共用 MessageModel。",
                codeExample: """
                enum Role: String, Codable {
                    case system
                    case user
                    case assistant
                }

                struct Message: Codable {
                    let role: Role
                    var content: String
                }

                var messages = [
                    Message(role: .system, content: "你是 iOS 面试助手")
                ]
                messages.append(Message(role: .user, content: input))
                messages = [messages[0]] + messages.dropFirst().suffix(12)
                """
            ),
            module(
                id: "hallucination",
                title: "AI 为什么会胡说八道",
                subtitle: "概率预测、不是真正理解、缺少上下文会产生幻觉",
                symbolName: "exclamationmark.triangle.fill",
                colorIndex: 0,
                question: "为什么 AI 有时会一本正经地说错？",
                coreAnswer: "大模型本质是根据上下文预测下一个 token，不是真正查数据库。上下文缺失、问题含糊或资料不可靠时，就可能产生幻觉。",
                mnemonic: "AI 是概率预测，不是事实数据库。",
                followUp: "追问：怎么减少幻觉？答：给可靠上下文、约束回答范围、要求不知道就说不知道、关键结果做校验。",
                projectScenario: "医疗、金融、合同等高风险场景不能直接展示裸答案，需要引用来源、人工确认或规则校验兜底。",
                codeExample: """
                let prompt = \"\"\"
                只根据下面资料回答。
                如果资料没有答案，请直接说“不确定”。

                资料：
                \\(context)

                问题：
                \\(question)
                \"\"\"
                """
            ),
            module(
                id: "markdown-render",
                title: "Markdown 怎么渲染",
                subtitle: "attributedString、Markdown 库、code block、富文本展示",
                symbolName: "doc.richtext.fill",
                colorIndex: 1,
                question: "AI 返回 Markdown，iOS 怎么渲染？",
                coreAnswer: "简单 Markdown 可转成 AttributedString / NSAttributedString 展示；复杂场景用成熟 Markdown 库处理标题、列表、链接和 code block。",
                mnemonic: "Markdown：先解析成富文本，再交给 UILabel / UITextView 展示。",
                followUp: "追问：代码块怎么做？答：单独识别 code block，使用等宽字体、背景色和复制按钮。",
                projectScenario: "AI 答案里常有列表、加粗和代码块，聊天 cell 里需要富文本展示，否则可读性很差。",
                codeExample: """
                let markdown = "**核心答案**\\n```swift\\nprint(123)\\n```"

                if let attributed = try? AttributedString(markdown: markdown) {
                    label.attributedText = NSAttributedString(attributed)
                } else {
                    label.text = markdown
                }
                """
            ),
            module(
                id: "ai-page-lag",
                title: "AI 页面为什么会卡",
                subtitle: "Markdown 解析、主线程刷新、频繁 reload、动态高度计算",
                symbolName: "speedometer",
                colorIndex: 2,
                question: "AI 聊天页为什么容易卡顿？",
                coreAnswer: "流式输出会频繁变更文本，Markdown 解析、动态高度计算、自动滚动和 reload 都可能挤在主线程，导致掉帧。",
                mnemonic: "聊天页：动态高度 + Markdown + 自动滚动，最怕频繁 reload。",
                followUp: "追问：怎么定位？答：看主线程耗时、Time Profiler、Core Animation FPS 和 reload 次数。",
                projectScenario: "模型每返回一个字就 reloadData，会让列表不断重算高度和布局，长答案时尤其明显。",
                codeExample: """
                // 容易卡：每个 chunk 都全表刷新
                func onChunk(_ text: String) {
                    messages[lastIndex].content += text
                    tableView.reloadData()
                    scrollToBottom()
                }

                // 更好：节流 + 局部刷新
                """
            ),
            module(
                id: "ai-page-optimization",
                title: "AI 页面怎么优化",
                subtitle: "增量刷新、高度缓存、后台解析 Markdown、减少 reloadData",
                symbolName: "wand.and.stars",
                colorIndex: 3,
                question: "AI 聊天页卡顿怎么优化？",
                coreAnswer: "核心是减少主线程压力。Markdown 后台解析，UI 增量刷新，最后一条消息局部更新，高度做缓存，避免频繁 reloadData。",
                mnemonic: "优化：增量刷新 + 高度缓存 + 后台解析。",
                followUp: "追问：流式刷新频率怎么控？答：做节流，比如 50 到 100ms 合并一次 UI 更新。",
                projectScenario: "长答案流式输出时，先拼接原文，后台生成富文本，主线程只更新可见的最后一个 cell。",
                codeExample: """
                func updateLastMessage() {
                    let indexPath = IndexPath(row: messages.count - 1, section: 0)
                    guard tableView.indexPathsForVisibleRows?.contains(indexPath) == true else {
                        return
                    }

                    tableView.reloadRows(at: [indexPath], with: .none)
                    heightCache[messages[indexPath.row].id] = nil
                }
                """
            ),
            module(
                id: "no-webview",
                title: "为什么不用 WebView",
                subtitle: "原生性能、交互灵活、流式刷新更方便",
                symbolName: "iphone.gen3",
                colorIndex: 4,
                question: "AI 聊天页为什么很多项目不用 WebView 做？",
                coreAnswer: "原生列表性能和交互更可控，流式增量刷新、复制、点赞、重试、停止、长按菜单都更容易和业务状态结合。",
                mnemonic: "能原生就原生：性能好、交互细、状态稳。",
                followUp: "追问：WebView 什么时候可以用？答：复杂 HTML、跨端统一渲染、已有 Web Markdown 能力时可以考虑。",
                projectScenario: "原生 UITableView / UICollectionView 能复用现有列表优化经验，聊天输入框、键盘、滚动和埋点也更好控制。",
                codeExample: """
                final class ChatCell: UITableViewCell {
                    private let bodyLabel = UILabel()

                    func update(_ text: NSAttributedString) {
                        bodyLabel.attributedText = text
                    }
                }
                """
            ),
            module(
                id: "stop-output",
                title: "怎么停止 AI 输出",
                subtitle: "URLSessionTask.cancel()、cancel stream、停止按钮、状态管理",
                symbolName: "stop.circle.fill",
                colorIndex: 0,
                question: "AI 正在流式输出时，用户点停止怎么做？",
                coreAnswer: "保存当前 URLSessionTask，点击停止时调用 cancel()，同时更新 isStreaming 状态，隐藏停止按钮，保留已输出内容。",
                mnemonic: "停止三步：cancel 任务、改状态、保留半截答案。",
                followUp: "追问：cancel 回调算失败吗？答：URLError.cancelled 是主动取消，不应该弹失败提示。",
                projectScenario: "用户发现回答方向错了，可以点停止，当前 assistant 消息保留已生成文本，并允许重新发送。",
                codeExample: """
                final class StreamManager {
                    private var task: URLSessionTask?
                    private(set) var isStreaming = false

                    func stop() {
                        task?.cancel()
                        task = nil
                        isStreaming = false
                    }
                }
                """
            ),
            module(
                id: "architecture",
                title: "AI 项目怎么架构",
                subtitle: "MVVM、ChatManager、StreamManager、Network Layer、MessageModel",
                symbolName: "square.stack.3d.up.fill",
                colorIndex: 1,
                question: "一个 AI 聊天项目，你会怎么拆架构？",
                coreAnswer: "可以用轻量 MVVM。VC 管 UI 和事件，ViewModel 管状态，ChatManager 管对话，StreamManager 管流式，Network Layer 管请求，MessageModel 统一数据。",
                mnemonic: "架构五层：页面、VM、聊天、流式、网络。",
                followUp: "追问：为什么不都写在 VC？答：流式状态、历史裁剪、重试和网络错误都塞 VC 会很难维护。",
                projectScenario: "发送、停止、重试、复制、历史记录、Markdown 渲染都围绕 MessageModel 流转，模块边界清楚。",
                codeExample: """
                final class ChatViewModel {
                    private let chatManager: ChatManager
                    private(set) var messages: [MessageModel] = []

                    func send(_ text: String) {
                        messages.append(.user(text))
                        chatManager.stream(messages: messages) { chunk in
                            self.appendAssistantChunk(chunk)
                        }
                    }
                }
                """
            ),
            module(
                id: "rag",
                title: "RAG 是什么",
                subtitle: "Retrieval Augmented Generation、检索增强生成、先查资料再回答",
                symbolName: "magnifyingglass.circle.fill",
                colorIndex: 2,
                question: "RAG 是什么？为什么 AI 项目会用？",
                coreAnswer: "RAG 是检索增强生成。先从知识库查相关资料，再把资料和问题一起给模型，让回答更贴业务、更可追溯。",
                mnemonic: "RAG：先检索，再回答。",
                followUp: "追问：RAG 解决什么问题？答：减少幻觉、接入私有知识、避免重新训练模型。",
                projectScenario: "客服机器人先查公司 FAQ、商品说明、售后政策，再让 AI 基于查到的资料组织回答。",
                codeExample: """
                let docs = retriever.search(query: userQuestion)
                let prompt = \"\"\"
                请只根据资料回答。
                资料：\\(docs.joined(separator: "\\n"))
                问题：\\(userQuestion)
                \"\"\"
                chat.send(prompt)
                """
            ),
            module(
                id: "embedding",
                title: "Embedding 是什么",
                subtitle: "文本转向量、语义搜索、常配合 RAG 使用",
                symbolName: "point.3.connected.trianglepath.dotted",
                colorIndex: 3,
                question: "Embedding 是什么？和 RAG 有什么关系？",
                coreAnswer: "Embedding 是把文本转成向量，语义相近的文本向量距离更近。RAG 常用 Embedding 做语义检索，先找相似资料再回答。",
                mnemonic: "Embedding：文字变向量，向量找相似。",
                followUp: "追问：为什么不用关键字搜索？答：关键字看字面，Embedding 看语义，能找同义表达。",
                projectScenario: "用户问“怎么退货”，系统能搜到“售后退款流程”，因为语义相近，即使关键词不完全一样。",
                codeExample: """
                struct EmbeddingItem {
                    let text: String
                    let vector: [Float]
                }

                func dot(_ a: [Float], _ b: [Float]) -> Float {
                    zip(a, b).map { $0.0 * $0.1 }.reduce(0, +)
                }
                """
            ),
            module(
                id: "agent",
                title: "Agent 是什么",
                subtitle: "AI + 工具 + 记忆 + 规划能力，不只是聊天",
                symbolName: "brain.head.profile",
                colorIndex: 4,
                question: "Agent 和普通聊天机器人有什么区别？",
                coreAnswer: "Agent 不只是回答文本，而是能理解目标、规划步骤、调用工具、记住状态并执行任务。可以理解为 AI 加工具、记忆和规划能力。",
                mnemonic: "Agent：AI + 工具 + 记忆 + 规划。",
                followUp: "追问：Agent 有什么风险？答：工具权限、错误执行、循环调用和结果校验都要管控。",
                projectScenario: "让 AI 帮用户查订单、生成工单、发通知，这类会调用业务 API 的流程更接近 Agent。",
                codeExample: """
                struct AgentStep {
                    let goal: String
                    let toolName: String
                    let arguments: [String: String]
                }

                let plan = AgentStep(
                    goal: "查询订单物流",
                    toolName: "queryOrder",
                    arguments: ["orderId": orderId]
                )
                """
            ),
            module(
                id: "mcp",
                title: "MCP 是什么",
                subtitle: "Model Context Protocol、AI 调用外部工具的一种协议",
                symbolName: "link.circle.fill",
                colorIndex: 0,
                question: "MCP 是什么？它解决什么问题？",
                coreAnswer: "MCP 是 Model Context Protocol，可以理解为 AI 连接外部工具和数据源的协议。它让模型更规范地访问文件、数据库、GitHub、本地工具等能力。",
                mnemonic: "MCP：AI 调工具协议。",
                followUp: "追问：和 Function Calling 区别？答：Function Calling 偏单次函数调用机制，MCP 更像标准化工具连接协议。",
                projectScenario: "开发助手通过 MCP 读取项目文件、查 GitHub issue、连数据库，再基于真实上下文回答或执行任务。",
                codeExample: """
                let toolRequest: [String: Any] = [
                    "server": "github",
                    "tool": "searchIssues",
                    "arguments": ["keyword": "crash"]
                ]

                print(toolRequest)
                """
            ),
            module(
                id: "function-calling",
                title: "Function Calling 是什么",
                subtitle: "让 AI 调用函数 / API，比如查天气、查数据库、发消息",
                symbolName: "function",
                colorIndex: 1,
                question: "Function Calling 是什么？客户端怎么理解？",
                coreAnswer: "Function Calling 是让模型按约定输出要调用的函数名和参数。业务侧执行真实 API，再把结果回传给模型，让它组织最终回答。",
                mnemonic: "函数调用：AI 选函数，业务真执行。",
                followUp: "追问：AI 能直接查数据库吗？答：不能直接查，必须通过你暴露的安全函数或服务。",
                projectScenario: "用户问天气，模型选择 getWeather(city)，App 或服务端执行天气接口，再把结果交给模型总结。",
                codeExample: """
                struct ToolCall: Codable {
                    let name: String
                    let arguments: [String: String]
                }

                func handle(_ call: ToolCall) {
                    if call.name == "getWeather" {
                        weatherAPI.load(city: call.arguments["city"])
                    }
                }
                """
            ),
            module(
                id: "prompt-engineering",
                title: "Prompt Engineering 是什么",
                subtitle: "system prompt、role、few-shot、约束输出格式",
                symbolName: "text.quote",
                colorIndex: 2,
                question: "Prompt Engineering 在项目里有什么用？",
                coreAnswer: "Prompt Engineering 是通过 system prompt、角色设定、示例和格式约束，让模型更稳定地输出符合业务预期的内容。",
                mnemonic: "Prompt 四件套：角色、任务、示例、格式。",
                followUp: "追问：怎么让输出稳定？答：明确角色、边界、禁止项、输出 JSON schema 或固定模板。",
                projectScenario: "AI 面试助手要求输出“核心答案、口诀、追问、项目场景”，就需要在 prompt 里固定格式。",
                codeExample: """
                let systemPrompt = \"\"\"
                你是 iOS 面试辅导老师。
                回答必须简短、中文、八股文风格。
                输出格式：核心答案 / 口诀 / 项目场景。
                \"\"\"

                messages.insert(.init(role: .system, content: systemPrompt), at: 0)
                """
            ),
            module(
                id: "speech",
                title: "Whisper 和 Apple Speech.framework 区别",
                subtitle: "Whisper 模型大，移动端实时性压力大；Speech 系统优化，延迟低",
                symbolName: "mic.circle.fill",
                colorIndex: 3,
                question: "语音识别为什么常用 Apple Speech.framework，而不是直接上 Whisper？",
                coreAnswer: "Whisper 识别能力强但模型较大，移动端实时运行有性能、功耗和包体压力。Apple Speech.framework 是系统级能力，接入简单、延迟低、体验稳定。",
                mnemonic: "Whisper 强但重，Speech 轻且快。",
                followUp: "追问：Whisper 适合什么场景？答：服务端转写、离线高质量转写、多语言识别要求高的场景。",
                projectScenario: "语音输入聊天时，App 端优先用 Speech.framework 做实时转文字；长音频转写可交给服务端 Whisper。",
                codeExample: """
                import Speech

                let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
                let request = SFSpeechAudioBufferRecognitionRequest()

                recognizer?.recognitionTask(with: request) { result, error in
                    let text = result?.bestTranscription.formattedString
                    print(text as Any, error as Any)
                }
                """
            ),
            module(
                id: "pitfalls",
                title: "AI 项目踩过什么坑",
                subtitle: "流式刷新、Markdown、自动滚动、token 暴涨、SSE 断流重连",
                symbolName: "wrench.and.screwdriver.fill",
                colorIndex: 4,
                question: "你做 AI 项目踩过哪些坑？怎么解决？",
                coreAnswer: "常见坑是流式输出频繁刷新导致卡顿、Markdown 渲染耗时、UITableView 自动滚动抖动、上下文太长 token 暴涨、SSE 断流需要重连。",
                mnemonic: "五大坑：刷新、渲染、滚动、token、断流。",
                followUp: "追问：怎么体现你真做过？答：讲清现象、定位、方案和效果，比如 reloadData 改成局部刷新。",
                projectScenario: "上线后长回答页面掉帧，最后用节流刷新、后台 Markdown、底部滚动判断和历史裁剪解决。",
                codeExample: """
                func handleStreamChunk(_ chunk: String) {
                    buffer += chunk
                    throttleUIUpdate()
                }

                func retryIfNeeded(_ error: Error) {
                    guard !isUserCancelled else { return }
                    reconnectSSE()
                }
                """
            ),
            module(
                id: "quick-memory",
                title: "必背口诀总表",
                subtitle: "请求、流式、上下文、渲染、优化，10 分钟快速复习",
                symbolName: "bolt.circle.fill",
                colorIndex: 0,
                question: "AI 常规面试最后怎么快速收口？",
                coreAnswer: "按链路回答：先讲请求接入，再讲流式输出，然后讲上下文和 token，最后讲 Markdown 渲染、页面优化和项目踩坑。",
                mnemonic: "AI 面试：请求、流式、上下文、渲染、优化。RAG 先检索再回答，Agent 是 AI + 工具 + 记忆，MCP 是 AI 调工具协议。",
                followUp: "追问：一句话总结 AI 聊天页难点？答：动态高度 + Markdown + 自动滚动 + 流式状态管理。",
                projectScenario: "面试时先用这套口诀搭骨架，再把 URLSession、SSE、Token、Markdown、性能优化逐个展开。",
                codeExample: """
                let reviewOrder = [
                    "请求",
                    "流式",
                    "上下文",
                    "渲染",
                    "优化"
                ]

                print(reviewOrder.joined(separator: " -> "))
                """
            )
        ]
    }

    static func module(
        id: String,
        title: String,
        subtitle: String,
        symbolName: String,
        colorIndex: Int,
        question: String,
        coreAnswer: String,
        mnemonic: String,
        followUp: String,
        projectScenario: String,
        codeExample: String
    ) -> InterviewReviewModule {
        InterviewReviewModule(
            id: id,
            title: title,
            subtitle: subtitle,
            symbolName: symbolName,
            tintColor: InterviewReviewStyle.accentColors[
                colorIndex % InterviewReviewStyle.accentColors.count
            ],
            items: [
                InterviewReviewItem(
                    title: "10 分钟速记卡",
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
                            title: "项目场景",
                            body: projectScenario,
                            symbolName: "briefcase.fill"
                        ),
                        InterviewReviewRow(
                            title: "代码示例",
                            body: codeExample,
                            symbolName: "curlybraces.square.fill"
                        )
                    ]
                )
            ]
        )
    }
}
