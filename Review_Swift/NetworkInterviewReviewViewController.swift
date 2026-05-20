//
//  NetworkInterviewReviewViewController.swift
//  Review_Swift
//
//  Created by Codex on 2026/5/20.
//

import UIKit

final class NetworkInterviewReviewViewController: InterviewReviewListViewController {

    init() {
        super.init(
            pageTitle: "网络相关",
            modules: Self.makeModules()
        )
    }

    required init?(coder: NSCoder) {
        super.init(
            pageTitle: "网络相关",
            modules: Self.makeModules()
        )
    }

    private static func makeModules() -> [InterviewReviewModule] {
        [
            InterviewReviewModule(
                id: "urlsession",
                title: "URLSession",
                subtitle: "会话、任务、代理、async/await、超时取消",
                symbolName: "network",
                tintColor: InterviewReviewStyle.accentColors[0],
                items: makeURLSessionItems()
            ),
            InterviewReviewModule(
                id: "http-https",
                title: "HTTP / HTTPS",
                subtitle: "协议、加密、TLS、证书、安全性",
                symbolName: "lock.shield.fill",
                tintColor: InterviewReviewStyle.accentColors[1],
                items: makeHTTPItems()
            ),
            InterviewReviewModule(
                id: "get-post",
                title: "GET / POST 区别",
                subtitle: "参数、安全、幂等、缓存、大小、场景",
                symbolName: "arrow.left.arrow.right.circle.fill",
                tintColor: InterviewReviewStyle.accentColors[2],
                items: makeGetPostItems()
            ),
            InterviewReviewModule(
                id: "json",
                title: "JSON 解析",
                subtitle: "JSONSerialization、Codable、Decoder、映射、容错",
                symbolName: "curlybraces.square.fill",
                tintColor: InterviewReviewStyle.accentColors[3],
                items: makeJSONItems()
            ),
            InterviewReviewModule(
                id: "auth-state",
                title: "token / cookie / session",
                subtitle: "登录态、服务端会话、过期刷新、refreshToken",
                symbolName: "person.badge.key.fill",
                tintColor: InterviewReviewStyle.accentColors[4],
                items: makeAuthItems()
            )
        ]
    }

    private static func reviewItem(
        title: String,
        question: String,
        coreAnswer: String,
        summary: String,
        mnemonic: String,
        followUp: String,
        codeExample: String,
        projectScenario: String
    ) -> InterviewReviewItem {
        InterviewReviewItem(
            title: title,
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
                    title: "一句话总结",
                    body: summary,
                    symbolName: "bolt.fill",
                    isMemoryLine: true
                ),
                InterviewReviewRow(
                    title: "口诀",
                    body: mnemonic,
                    symbolName: "textformat.abc"
                ),
                InterviewReviewRow(
                    title: "常见追问",
                    body: followUp,
                    symbolName: "bubble.left.and.bubble.right.fill"
                ),
                InterviewReviewRow(
                    title: "代码示例",
                    body: codeExample,
                    symbolName: "curlybraces.square.fill"
                ),
                InterviewReviewRow(
                    title: "项目场景",
                    body: projectScenario,
                    symbolName: "briefcase.fill"
                )
            ]
        )
    }

    private static func makeURLSessionItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "URLSession 是什么",
                question: "URLSession 是什么？在 iOS 网络请求里负责什么？",
                coreAnswer: "URLSession 是 Apple 原生网络框架，负责发起 HTTP/HTTPS 请求。它用 URLSessionConfiguration 管配置，用 URLSessionTask 执行请求，回调数据、响应和错误。",
                summary: "URLSession 是 iOS 原生网络请求入口，Session 管环境，Task 管一次请求。",
                mnemonic: "口诀：Session 管配置，Task 跑请求。",
                followUp: "追问：URLSession、URLRequest、URLSessionTask 什么关系？URLRequest 描述请求，URLSession 创建任务，Task 真正执行。",
                codeExample: """
                let url = URL(string: "https://api.example.com/user")!
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard error == nil else { return }
                    print(data?.count ?? 0)
                }.resume()
                """,
                projectScenario: "App 登录、首页拉取、埋点上报都可以用 URLSession；复杂项目通常再封一层 NetworkClient 统一处理 token、错误码和日志。"
            ),
            reviewItem(
                title: "DataTask / DownloadTask / UploadTask",
                question: "DataTask、DownloadTask、UploadTask 有什么区别？",
                coreAnswer: "DataTask 适合普通接口，数据在内存里返回；DownloadTask 适合大文件下载，结果是临时文件地址；UploadTask 适合上传 Data 或文件，常用于图片、日志、视频。",
                summary: "小接口用 DataTask，下载文件用 DownloadTask，上传内容用 UploadTask。",
                mnemonic: "口诀：取数据 data，下文件 download，传文件 upload。",
                followUp: "追问：为什么大文件不建议 DataTask？DataTask 把数据放内存，文件太大会造成内存压力，DownloadTask 更稳。",
                codeExample: """
                let session = URLSession.shared
                session.dataTask(with: request).resume()
                session.downloadTask(with: fileURL).resume()
                session.uploadTask(with: request, from: bodyData).resume()
                """,
                projectScenario: "商品列表接口用 DataTask；安装包、PDF、音频缓存用 DownloadTask；头像、反馈图片、崩溃日志上传用 UploadTask。"
            ),
            reviewItem(
                title: "delegate 回调",
                question: "URLSession 的 delegate 回调能做什么？",
                coreAnswer: "delegate 可以监听认证挑战、重定向、上传下载进度、任务完成、后台下载等。需要更细粒度控制时用 delegate，比闭包回调能力更强。",
                summary: "delegate 适合处理进度、认证、重定向和后台任务这类细粒度网络事件。",
                mnemonic: "口诀：闭包拿结果，delegate 管过程。",
                followUp: "追问：delegate 回调在哪个线程？由 delegateQueue 决定，传 nil 时系统创建串行队列；更新 UI 要回主线程。",
                codeExample: """
                final class NetworkDelegate: NSObject, URLSessionTaskDelegate {
                    func urlSession(
                        _ session: URLSession,
                        task: URLSessionTask,
                        didCompleteWithError error: Error?
                    ) {
                        print(error == nil ? "success" : "failed")
                    }
                }

                let delegate = NetworkDelegate()
                let session = URLSession(
                    configuration: .default,
                    delegate: delegate,
                    delegateQueue: nil
                )
                """,
                projectScenario: "做文件下载进度条、证书校验、断点下载、后台下载时，一般会用 URLSessionDelegate / URLSessionTaskDelegate。"
            ),
            reviewItem(
                title: "async/await 请求",
                question: "URLSession 怎么用 async/await 发请求？",
                coreAnswer: "iOS 15 后可以用 data(from:) 或 data(for:)。它把异步回调变成 await，成功返回 Data 和 URLResponse，失败直接 throw，代码更像同步流程。",
                summary: "async/await 让网络请求从回调写法变成顺序写法，错误用 throw 处理。",
                mnemonic: "口诀：await 等结果，do-catch 接错误。",
                followUp: "追问：HTTP 404 会直接 throw 吗？通常不会，URLSession 只对网络层错误 throw，业务上要自己检查 statusCode。",
                codeExample: """
                func loadUser() async throws -> Data {
                    let url = URL(string: "https://api.example.com/user")!
                    let (data, response) = try await URLSession.shared.data(from: url)

                    guard let http = response as? HTTPURLResponse,
                          (200..<300).contains(http.statusCode) else {
                        throw URLError(.badServerResponse)
                    }

                    return data
                }
                """,
                projectScenario: "新项目里列表刷新、详情页加载、并发请求合并都适合 async/await，代码比多层闭包更清楚。"
            ),
            reviewItem(
                title: "超时、取消、错误处理",
                question: "URLSession 请求如何处理超时、取消和错误？",
                coreAnswer: "超时可设置 URLRequest.timeoutInterval 或 configuration 的 timeout；取消调用 task.cancel()；错误看 URLError、HTTP 状态码和业务 code，三层都要处理。",
                summary: "网络错误要分清：网络层、HTTP 层、业务层。",
                mnemonic: "口诀：超时设 timeout，取消调 cancel，错误分三层。",
                followUp: "追问：取消请求会回调错误吗？会，通常是 URLError.cancelled；不要当成真正失败弹错误提示。",
                codeExample: """
                var request = URLRequest(url: url)
                request.timeoutInterval = 10

                let task = URLSession.shared.dataTask(with: request)
                task.resume()

                // 页面离开或重复请求时取消
                task.cancel()
                """,
                projectScenario: "搜索联想要取消上一次请求；页面销毁要取消未完成任务；弱网下要给超时提示和重试入口。"
            )
        ]
    }

    private static func makeHTTPItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "HTTP 是什么",
                question: "HTTP 是什么？它有什么特点？",
                coreAnswer: "HTTP 是超文本传输协议，是客户端和服务端通信的应用层协议。它基于请求-响应模型，本身无状态，常配合 cookie、token、session 维护登录态。",
                summary: "HTTP 是客户端和服务端按请求-响应格式交换数据的应用层协议。",
                mnemonic: "口诀：HTTP 管格式，不记状态。",
                followUp: "追问：HTTP 为什么说无状态？每次请求天然独立，协议本身不记用户是谁，要靠额外机制带身份。",
                codeExample: """
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                """,
                projectScenario: "App 调接口，本质就是构造 HTTP 请求：method、url、header、body，然后解析服务端响应。"
            ),
            reviewItem(
                title: "HTTPS 是什么",
                question: "HTTPS 是什么？和 HTTP 有什么关系？",
                coreAnswer: "HTTPS = HTTP + SSL/TLS。HTTP 负责应用层数据格式，TLS 负责加密、身份认证和完整性保护，让传输过程不容易被窃听、篡改、冒充。",
                summary: "HTTPS 不是新协议，而是在 HTTP 外面加了一层 TLS 安全保护。",
                mnemonic: "口诀：HTTP 会说话，TLS 给它上锁。",
                followUp: "追问：HTTPS 能不能保证绝对安全？不能。它保护传输链路，但客户端泄漏、服务端漏洞、证书被错误信任仍可能出问题。",
                codeExample: """
                let url = URL(string: "https://api.example.com/profile")!
                URLSession.shared.dataTask(with: url).resume()
                """,
                projectScenario: "登录、支付、用户资料、订单、IM 消息等接口都应该走 HTTPS，避免敏感信息裸奔。"
            ),
            reviewItem(
                title: "SSL / TLS",
                question: "SSL / TLS 是什么？面试怎么讲？",
                coreAnswer: "SSL/TLS 是安全传输协议。现在主要说 TLS，SSL 已过时。TLS 通过握手协商密钥、校验证书，之后用对称密钥加密传输数据。",
                summary: "TLS 的核心是握手建信任，协商密钥后加密传数据。",
                mnemonic: "口诀：先握手，再加密。",
                followUp: "追问：为什么握手不用纯对称加密？因为双方一开始没有共享密钥，需要先用非对称能力安全协商出会话密钥。",
                codeExample: """
                let configuration = URLSessionConfiguration.default
                configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
                let session = URLSession(configuration: configuration)
                """,
                projectScenario: "金融、支付、企业内网 App 可能会要求最低 TLS 版本、证书绑定或禁用不安全的旧协议。"
            ),
            reviewItem(
                title: "对称加密 / 非对称加密",
                question: "对称加密和非对称加密有什么区别？HTTPS 为什么都用？",
                coreAnswer: "对称加密是同一把密钥加解密，速度快，适合传大量数据；非对称加密公钥加密私钥解密，安全分发方便但慢。HTTPS 用非对称解决密钥协商，用对称加密传数据。",
                summary: "非对称用来安全交换密钥，对称用来高效传输数据。",
                mnemonic: "口诀：非对称谈钥匙，对称搬数据。",
                followUp: "追问：为什么 HTTPS 不全程用非对称加密？性能差，传输大量数据成本高，所以只在握手阶段使用关键能力。",
                codeExample: """
                // 面试记法：
                // 1. TLS 握手校验证书
                // 2. 协商会话密钥
                // 3. 后续数据用会话密钥对称加密
                """,
                projectScenario: "理解这个流程后，就能解释 HTTPS 为什么既安全又能保持较好性能。"
            ),
            reviewItem(
                title: "证书校验",
                question: "HTTPS 证书校验在校验什么？",
                coreAnswer: "主要校验证书是否由可信 CA 签发、域名是否匹配、证书是否过期、证书链是否完整、是否被吊销。校验通过才认为服务端身份可信。",
                summary: "证书校验的目的，是确认你连到的真是目标服务器。",
                mnemonic: "口诀：看 CA、看域名、看日期、看链路。",
                followUp: "追问：抓包为什么要装证书？因为代理要伪造服务端证书，系统只有信任它，HTTPS 连接才会通过校验。",
                codeExample: """
                final class PinningDelegate: NSObject, URLSessionDelegate {
                    func urlSession(
                        _ session: URLSession,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (
                            URLSession.AuthChallengeDisposition,
                            URLCredential?
                        ) -> Void
                    ) {
                        completionHandler(.performDefaultHandling, nil)
                    }
                }
                """,
                projectScenario: "安全要求高的 App 会做证书绑定，防止用户安装恶意根证书后被中间人代理抓取敏感接口。"
            ),
            reviewItem(
                title: "为什么 HTTPS 更安全",
                question: "为什么 HTTPS 比 HTTP 更安全？",
                coreAnswer: "HTTPS 提供三点：加密防窃听，证书认证防冒充，摘要/校验防篡改。HTTP 明文传输，请求和响应都可能被看到或改掉。",
                summary: "HTTPS 强在防窃听、防篡改、防冒充。",
                mnemonic: "口诀：加密、认证、完整性。",
                followUp: "追问：HTTPS 会隐藏域名和 IP 吗？IP 不会隐藏；域名在部分场景仍可能暴露，HTTPS 主要保护请求路径、Header、Body 等内容。",
                codeExample: """
                // HTTP:  明文传输，容易被窃听和篡改
                // HTTPS: TLS 加密，校验证书，保护传输内容
                """,
                projectScenario: "登录密码、token、手机号、订单信息必须走 HTTPS；上线前也要确认接口没有混用 http。"
            )
        ]
    }

    private static func makeGetPostItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "参数位置",
                question: "GET 和 POST 的参数一般放在哪里？",
                coreAnswer: "GET 参数通常拼在 URL query 里；POST 参数通常放在 HTTP Body 里，也可以配合 Header 描述类型，比如 application/json。",
                summary: "GET 参数多在 URL，POST 参数多在 Body。",
                mnemonic: "口诀：GET 问号后，POST 身体里。",
                followUp: "追问：POST 能不能把参数放 URL？能，协议不禁止，但不推荐把大量或敏感参数放 URL。",
                codeExample: """
                var get = URLComponents(string: "https://api.example.com/search")!
                get.queryItems = [URLQueryItem(name: "keyword", value: "swift")]

                var post = URLRequest(url: url)
                post.httpMethod = "POST"
                post.httpBody = jsonData
                """,
                projectScenario: "搜索、分页、筛选常用 GET query；创建订单、提交表单、上传业务数据常用 POST body。"
            ),
            reviewItem(
                title: "安全性",
                question: "GET 比 POST 更不安全吗？",
                coreAnswer: "不是绝对。安全主要看是否 HTTPS。GET 参数在 URL 中，更容易出现在日志、浏览器历史、代理记录里；POST Body 相对不暴露在 URL，但 HTTP 下仍是明文。",
                summary: "GET/POST 本身不决定安全，HTTPS 才是传输安全关键。",
                mnemonic: "口诀：安全看 HTTPS，GET 更易留痕。",
                followUp: "追问：密码能用 GET 传吗？不应该。即使 HTTPS，也容易在 URL 日志里留下敏感信息。",
                codeExample: """
                var request = URLRequest(url: loginURL)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = loginBody
                """,
                projectScenario: "登录、支付、修改资料不要把密码、token、身份证号拼到 URL，统一放 Body 并走 HTTPS。"
            ),
            reviewItem(
                title: "幂等性",
                question: "GET 和 POST 的幂等性怎么理解？",
                coreAnswer: "GET 语义上用于读取资源，应该幂等，多次请求结果影响一样；POST 语义上用于创建或提交，通常不幂等，多次提交可能产生多条数据。",
                summary: "GET 读数据通常幂等，POST 提交数据通常不幂等。",
                mnemonic: "口诀：GET 读不改，POST 交会变。",
                followUp: "追问：POST 一定不幂等吗？不一定，幂等是接口设计语义，不是方法强制；服务端可以通过业务幂等键保证 POST 幂等。",
                codeExample: """
                var request = URLRequest(url: createOrderURL)
                request.httpMethod = "POST"
                request.setValue(idempotencyKey, forHTTPHeaderField: "Idempotency-Key")
                """,
                projectScenario: "支付、下单、提现要做防重复提交，常用幂等 key、按钮置灰、服务端去重。"
            ),
            reviewItem(
                title: "缓存",
                question: "GET 和 POST 在缓存上有什么区别？",
                coreAnswer: "GET 更容易被浏览器、代理和 URLCache 缓存，适合读取型接口；POST 默认通常不缓存，除非服务端明确返回可缓存头。",
                summary: "GET 天然更适合缓存，POST 默认不靠缓存。",
                mnemonic: "口诀：查数据 GET 好缓存。",
                followUp: "追问：iOS URLSession 会自动缓存吗？会受 URLRequest.cachePolicy、URLCache 和服务端 Cache-Control 等头影响。",
                codeExample: """
                var request = URLRequest(url: listURL)
                request.httpMethod = "GET"
                request.cachePolicy = .returnCacheDataElseLoad
                """,
                projectScenario: "配置项、城市列表、静态字典接口适合 GET 缓存；提交评论、点赞、下单不应该依赖缓存。"
            ),
            reviewItem(
                title: "数据大小",
                question: "GET 和 POST 在数据大小上有什么区别？",
                coreAnswer: "HTTP 协议本身没有严格限制 GET 长度，但浏览器、服务器、网关通常限制 URL 长度。POST Body 更适合传较大数据。",
                summary: "小参数 GET 足够，大数据用 POST Body 更稳。",
                mnemonic: "口诀：URL 别太长，大包放 Body。",
                followUp: "追问：上传文件能用 GET 吗？不适合。文件上传应使用 POST/PUT + Body，通常配 multipart 或二进制流。",
                codeExample: """
                var request = URLRequest(url: uploadURL)
                request.httpMethod = "POST"
                request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
                request.httpBody = fileData
                """,
                projectScenario: "复杂筛选条件、长文本、图片、日志等不要拼 URL，放到 Body 能减少长度兼容问题。"
            ),
            reviewItem(
                title: "使用场景",
                question: "实际开发中 GET 和 POST 怎么选？",
                coreAnswer: "读取、查询、分页、详情一般用 GET；创建、修改、删除、登录、上传、提交表单一般用 POST/PUT/PATCH/DELETE，具体以后端接口规范为准。",
                summary: "读资源优先 GET，写资源优先 POST 或其他写操作方法。",
                mnemonic: "口诀：读 GET，写 POST。",
                followUp: "追问：删除为什么有时也用 POST？可能是后端网关、历史规范或兼容问题；面试按 REST 语义回答，项目按接口约定落地。",
                codeExample: """
                enum API {
                    case list
                    case create

                    var method: String {
                        switch self {
                        case .list: return "GET"
                        case .create: return "POST"
                        }
                    }
                }
                """,
                projectScenario: "团队一般会把 method、path、参数编码封装到 API 枚举里，避免业务页面到处手写 GET/POST。"
            )
        ]
    }

    private static func makeJSONItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "JSONSerialization",
                question: "JSONSerialization 是什么？适合什么场景？",
                coreAnswer: "JSONSerialization 是 Foundation 提供的 JSON 与 Dictionary/Array 互转工具。它灵活但类型不安全，需要手动 as? 转型，适合简单调试或动态结构。",
                summary: "JSONSerialization 灵活但不类型安全，复杂业务不如 Codable 稳。",
                mnemonic: "口诀：Serialization 快速拆，类型自己猜。",
                followUp: "追问：为什么项目里更推荐 Codable？Codable 有模型约束，编译期更清晰，减少手动取字段出错。",
                codeExample: """
                let object = try JSONSerialization.jsonObject(with: data)
                if let dict = object as? [String: Any],
                   let name = dict["name"] as? String {
                    print(name)
                }
                """,
                projectScenario: "接口字段不固定、埋点参数、调试返回结构时可以用 JSONSerialization；正式业务模型更常用 Codable。"
            ),
            reviewItem(
                title: "Codable",
                question: "Codable 是什么？",
                coreAnswer: "Codable 是 Encodable + Decodable，用来让 Swift 模型和 JSON 等数据格式互相转换。模型字段和 JSON 匹配时，系统可以自动合成解析代码。",
                summary: "Codable 是 Swift 模型和 JSON 互转的标准协议。",
                mnemonic: "口诀：Decodable 解析，Encodable 编码，Codable 都会。",
                followUp: "追问：Codable 只能解析 JSON 吗？不是，它是协议；JSONDecoder/JSONEncoder 只是其中一种编解码器。",
                codeExample: """
                struct User: Codable {
                    let id: Int
                    let name: String
                }

                let user = try JSONDecoder().decode(User.self, from: data)
                """,
                projectScenario: "用户信息、商品详情、订单模型等固定结构接口，使用 Codable 最清晰，也方便单元测试。"
            ),
            reviewItem(
                title: "JSONDecoder",
                question: "JSONDecoder 常用配置有哪些？",
                coreAnswer: "JSONDecoder 负责把 Data 解成 Decodable 模型。常用配置有 keyDecodingStrategy、dateDecodingStrategy、dataDecodingStrategy，可处理下划线字段、日期格式等问题。",
                summary: "JSONDecoder 是 Codable 解析 JSON 的执行者，策略配置决定字段和日期怎么转。",
                mnemonic: "口诀：模型遵协议，Decoder 真解析。",
                followUp: "追问：snake_case 字段怎么处理？可以用 keyDecodingStrategy = .convertFromSnakeCase，或自定义 CodingKeys。",
                codeExample: """
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                struct Profile: Decodable {
                    let userName: String
                }

                let profile = try decoder.decode(Profile.self, from: data)
                """,
                projectScenario: "后端字段常用 user_name，Swift 属性常用 userName；统一配置 decoder 可以减少样板代码。"
            ),
            reviewItem(
                title: "model 映射",
                question: "JSON 到 model 映射时要注意什么？",
                coreAnswer: "模型字段类型要和 JSON 对齐；层级结构要匹配；数组、嵌套对象要建对应模型；需要展示的数据再从 DTO 转成业务 ViewModel。",
                summary: "model 映射的关键是类型、字段名、层级三件事对齐。",
                mnemonic: "口诀：名对、型对、层级对。",
                followUp: "追问：接口模型能不能直接给 UI 用？简单页面可以，复杂项目常转 ViewModel，避免 UI 依赖接口细节。",
                codeExample: """
                struct Response: Decodable {
                    let code: Int
                    let data: User
                }

                struct User: Decodable {
                    let id: Int
                    let nickname: String
                }
                """,
                projectScenario: "首页接口可能返回复杂嵌套结构，网络层解析 DTO，页面层再整理成 section、cell 的展示模型。"
            ),
            reviewItem(
                title: "可选值处理",
                question: "JSON 解析时可选值怎么处理？",
                coreAnswer: "接口可能缺字段或返回 null 的字段，模型里要用可选类型。非可选字段缺失会解析失败；必要时用默认值或自定义 init(from:) 做兜底。",
                summary: "可能缺失或为 null 的字段，用 Optional 承接。",
                mnemonic: "口诀：后端不保证，前端加问号。",
                followUp: "追问：字段为空字符串和 null 一样吗？不一样。空字符串是 String 值，null 表示没有值，解析行为不同。",
                codeExample: """
                struct User: Decodable {
                    let id: Int
                    let avatarURL: String?
                    let nickname: String?
                }
                """,
                projectScenario: "头像、简介、标签、优惠信息都可能为空；用可选值避免一个非核心字段导致整个模型解析失败。"
            ),
            reviewItem(
                title: "字段名不一致处理",
                question: "JSON 字段名和 Swift 属性名不一致怎么办？",
                coreAnswer: "用 CodingKeys 映射字段名，或者用 keyDecodingStrategy 统一转换。CodingKeys 更精确，适合少数字段特殊命名。",
                summary: "字段名不一致，用 CodingKeys 或 decoder 策略做映射。",
                mnemonic: "口诀：名字不一样，CodingKeys 搭桥。",
                followUp: "追问：CodingKeys 里可以只写部分字段吗？可以，但如果自定义了 CodingKeys，参与解析的字段要在里面声明。",
                codeExample: """
                struct User: Decodable {
                    let id: Int
                    let avatarURL: String

                    enum CodingKeys: String, CodingKey {
                        case id
                        case avatarURL = "avatar_url"
                    }
                }
                """,
                projectScenario: "后端字段如 avatar_url、is_vip、user-id，Swift 侧想保持驼峰命名时，就用 CodingKeys 映射。"
            ),
            reviewItem(
                title: "解析失败原因",
                question: "JSON 解析失败常见原因有哪些？",
                coreAnswer: "常见原因：字段缺失、类型不匹配、字段名不一致、JSON 格式非法、数组对象层级写错、日期格式不匹配、接口返回错误页或空数据。",
                summary: "解析失败多数是字段名、类型、层级或数据格式不匹配。",
                mnemonic: "口诀：名、型、层、格式。",
                followUp: "追问：怎么快速定位 Codable 失败？打印 DecodingError，重点看 keyNotFound、typeMismatch、valueNotFound、dataCorrupted。",
                codeExample: """
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    print(user)
                } catch let error as DecodingError {
                    print(error)
                } catch {
                    print("unknown parse error")
                }
                """,
                projectScenario: "线上偶发解析失败时，要记录接口路径、原始响应摘要、DecodingError，方便和后端对字段变更。"
            )
        ]
    }

    private static func makeAuthItems() -> [InterviewReviewItem] {
        [
            reviewItem(
                title: "token 是什么",
                question: "token 是什么？它一般放在哪里？",
                coreAnswer: "token 是服务端签发给客户端的身份凭证，客户端每次请求带上它，服务端据此识别用户。移动端常放在 Keychain，请求时放 Authorization Header。",
                summary: "token 是客户端请求接口时携带的登录凭证。",
                mnemonic: "口诀：登录拿 token，请求带 token。",
                followUp: "追问：token 能放 UserDefaults 吗？不推荐，敏感凭证更适合 Keychain；UserDefaults 安全性不足。",
                codeExample: """
                var request = URLRequest(url: url)
                request.setValue(
                    "Bearer access-token",
                    forHTTPHeaderField: "Authorization"
                )
                """,
                projectScenario: "App 登录成功后保存 accessToken，之后用户资料、订单、消息接口都自动在 Header 里带上。"
            ),
            reviewItem(
                title: "cookie 是什么",
                question: "cookie 是什么？移动端会用到吗？",
                coreAnswer: "cookie 是服务端通过 Set-Cookie 写给客户端的小段数据，后续请求同域名会自动带上。移动端 WebView 常见，原生接口也可通过 HTTPCookieStorage 管理。",
                summary: "cookie 是服务端写到客户端、后续请求自动带回去的数据。",
                mnemonic: "口诀：服务端种 cookie，客户端再带回。",
                followUp: "追问：cookie 和 local storage 一样吗？不一样。cookie 会随请求发送，local storage 主要在 Web 端本地存储。",
                codeExample: """
                let storage = HTTPCookieStorage.shared
                let cookies = storage.cookies(for: url) ?? []
                cookies.forEach { cookie in
                    print(cookie.name)
                }
                """,
                projectScenario: "App 内 H5 登录态、WebView 和原生接口共用登录态时，经常需要同步或清理 cookie。"
            ),
            reviewItem(
                title: "session 是什么",
                question: "session 是什么？它和 cookie 有什么关系？",
                coreAnswer: "session 是服务端保存的用户会话数据。客户端通常只保存 sessionId，常见方式是放在 cookie 里，请求时带回 sessionId，服务端查到对应会话。",
                summary: "session 数据在服务端，客户端通常只拿一个 sessionId。",
                mnemonic: "口诀：session 在服务端，cookie 带编号。",
                followUp: "追问：session 为什么会过期？为了安全和资源控制，服务端会设置有效期，长时间不用或主动退出会失效。",
                codeExample: """
                // 服务端常见逻辑：
                // 1. 登录成功创建 session
                // 2. 返回 Set-Cookie: sid=xxx
                // 3. 后续请求用 sid 找用户会话
                """,
                projectScenario: "传统 Web 登录常用 cookie + session；App 内嵌 H5 页面也经常依赖 sessionId 保持登录态。"
            ),
            reviewItem(
                title: "token 和 session 区别",
                question: "token 和 session 有什么区别？",
                coreAnswer: "session 通常状态存在服务端，客户端带 sessionId；token 常把凭证交给客户端，服务端验证签名或查缓存。session 易集中管理，token 更适合移动端和分布式。",
                summary: "session 偏服务端有状态，token 偏客户端携带凭证。",
                mnemonic: "口诀：session 服务端记，token 客户端带。",
                followUp: "追问：token 一定无状态吗？不一定。JWT 可自包含，普通 token 也可能服务端查 Redis，关键看后端设计。",
                codeExample: """
                // session: Cookie: sid=server-session-id
                // token:   Authorization: Bearer access-token
                """,
                projectScenario: "移动 App 更常见 token；管理后台 Web 常见 cookie + session；混合项目可能两套机制都要兼容。"
            ),
            reviewItem(
                title: "登录态如何保持",
                question: "App 登录态如何保持？",
                coreAnswer: "登录成功保存凭证；每次请求自动带凭证；启动时读取本地凭证判断是否已登录；服务端返回未授权时清理状态或刷新 token。",
                summary: "登录态保持就是本地存凭证，请求带凭证，失效再处理。",
                mnemonic: "口诀：存、带、验、失效处理。",
                followUp: "追问：退出登录要做什么？清 token、清用户缓存、清 cookie、取消未完成请求，并回到登录页。",
                codeExample: """
                final class AuthStore {
                    var accessToken: String?

                    func applyAuth(to request: inout URLRequest) {
                        guard let accessToken else { return }
                        request.setValue(
                            "Bearer " + accessToken,
                            forHTTPHeaderField: "Authorization"
                        )
                    }
                }
                """,
                projectScenario: "NetworkClient 统一加 Authorization，避免每个页面手动拼 Header；登录失效时统一弹登录页。"
            ),
            reviewItem(
                title: "token 过期怎么处理",
                question: "token 过期后客户端怎么处理？",
                coreAnswer: "接口返回 401 或业务过期码时，先尝试用 refreshToken 刷新 accessToken；刷新成功后重试原请求；刷新失败就清登录态并跳登录。",
                summary: "accessToken 过期先刷新，刷新失败再重新登录。",
                mnemonic: "口诀：401 先刷新，刷新失败去登录。",
                followUp: "追问：多个请求同时 401 怎么办？要做刷新队列或加锁，只发一次刷新请求，其余请求等待结果后重试。",
                codeExample: """
                if response.statusCode == 401 {
                    try await authService.refreshAccessToken()
                    return try await send(originalRequest)
                }
                """,
                projectScenario: "首页多个接口并发时，如果 token 同时过期，网络层要合并刷新，避免并发刷新导致 token 被互相覆盖。"
            ),
            reviewItem(
                title: "refreshToken 机制",
                question: "refreshToken 机制是什么？为什么要有它？",
                coreAnswer: "accessToken 有效期短，用于日常请求；refreshToken 有效期长，用于换新的 accessToken。这样即使 accessToken 泄漏，风险窗口也更短。",
                summary: "refreshToken 用来续期 accessToken，兼顾安全和免登录体验。",
                mnemonic: "口诀：短 token 访问，长 token 续命。",
                followUp: "追问：refreshToken 也过期怎么办？必须重新登录；如果服务端支持轮换，刷新成功后还要保存新的 refreshToken。",
                codeExample: """
                struct RefreshRequest: Encodable {
                    let refreshToken: String
                }

                struct RefreshResponse: Decodable {
                    let accessToken: String
                    let refreshToken: String
                }
                """,
                projectScenario: "用户长时间不打开 App，再次启动时 accessToken 可能过期，先静默刷新，成功后直接进入首页。"
            )
        ]
    }
}
