// ----------------------------------------------------------------------------
//
//  HTTPRequestExecutor.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class HTTPRequestExecutor: RequestExecutor
{
// MARK: - Construction

    public convenience init(url: URL)
    {
        let config = HTTPRequestExecutorConfig(baseURL: url)
        self.init(config: config)
    }

    public convenience init(config: HTTPRequestExecutorConfig)
    {
        let httpClient = AlamofireHTTPClient()
        self.init(config: config, httpClient: httpClient)
    }

    init(config: HTTPRequestExecutorConfig, httpClient: HTTPClient)
    {
        self.config = config
        self.httpClient = httpClient
    }

// MARK: - Properties

    public let config: HTTPRequestExecutorConfig

    public var requestAdapter: HTTPRequestAdapter = DefaultHTTPRequestAdapter()

    public var responseAdapter: HTTPResponseAdapter = DefaultHTTPResponseAdapter()

    public var requestRetrier: HTTPRequestRetrier? = nil

// MARK: - Functions

    public func execute(request: Request, completionHandler: @escaping (RequestExecutorResult) -> Void)
    {
        let task = RPCTask(request: request, handler: completionHandler)
        enqueue(task: task)

        weak var weakSelf = self
        DispatchQueue.global().asyncAfter(deadline: .now() + self.config.throttleInterval) {
            if let tasks = weakSelf?.dequeueTasks(), !(tasks.isEmpty) {
                weakSelf?.perform(tasks: tasks)
            }
        }
    }

    public func activeHTTPRequest(forRequest request: Request) -> HTTPRequest?
    {
        return self.httpTasks.withValue { httpTasks in
            return httpTasks.first(where: { $0.requests.contains(where: { $0 === request }) })?.httpRequest
        }
    }

// MARK: - Private Functions

    private func perform(tasks: [RPCTask])
    {
        let httpRequest = buildHTTPRequest(forRequests: tasks.map{ $0.request })
        perform(httpRequest: httpRequest, forTasks: tasks)
    }

    private func perform(httpRequest: HTTPRequest, forTasks tasks: [RPCTask])
    {
        do {
            let httpRequest = try self.requestAdapter.adapt(request: httpRequest)

            let httpTask = HTTPTask(httpRequest: httpRequest, requests: tasks.map{ $0.request })
            enqueue(httpTask: httpTask)

            weak var weakSelf = self
            self.httpClient.perform(request: httpRequest) { result in
                guard let instance = weakSelf else { return }

                switch result
                {
                    case .success(let response):
                        do {
                            let response = try instance.responseAdapter.adapt(response: response, forRequest: httpRequest)
                            instance.dispatch(httpResponse: response, forRequest: httpRequest, tasks: tasks)
                        }
                        catch (let error as HTTPResponseError)
                        {
                            let cause = HTTPRequestExecutorError(error: error, request: httpRequest, response: response)
                            instance.dispatch(error: cause, forRequest: httpRequest, tasks: tasks)
                        }
                        catch {
                            fatalError("HTTPResponseAdapter can only throw instance of HTTPResponseError.")
                        }

                    case .error(let error):
                        let cause = HTTPRequestExecutorError(error: error, request: httpRequest, response: nil)
                        instance.dispatch(error: cause, forRequest: httpRequest, tasks: tasks)
                }

                instance.dequeue(httpTask: httpTask)
            }
        }
        catch (let error as HTTPRequestError)
        {
            let cause = HTTPRequestExecutorError(error: error, request: httpRequest, response: nil)
            dispatch(error: cause, forRequest: httpRequest, tasks: tasks)
        }
        catch {
            fatalError("HTTPRequestAdapter can only throw instance of HTTPResponseError.")
        }
    }

    private func buildHTTPRequest(forRequests requests: [Request]) -> HTTPRequest
    {
        let payload = requests.map{ $0.buildBody() }
        let body: Data

        do {
            body = try JSONSerialization.data(withJSONObject: payload, options: [])
        }
        catch {
            fatalError("Build data from request failed.")
        }

        return HTTPRequest(method: .post, url: self.config.baseURL, headers: [:], body: body)
    }

    private func dispatch(httpResponse: HTTPResponse, forRequest request: HTTPRequest, tasks: [RPCTask])
    {
        do {
            let payload = try JSONSerialization.jsonObject(with: httpResponse.body, options: [])
            guard let items = (payload as? [[String: Any]]) else {
                throw HTTPResponseSerializationError(cause: HTTPResponseSerializationError.UnexpectedPayloadTypeError(payload: payload))
            }

            let responses = try items.map{ try Response(response: $0) }
            dispatch(responses: responses, forTasks: tasks)
        }
        catch (let error as HTTPResponseSerializationError)
        {
            let cause = HTTPRequestExecutorError(error: error, request: request, response: httpResponse)
            dispatch(error: cause, forRequest: request, tasks: tasks)
        }
        catch (let error)
        {
            let error = HTTPResponseSerializationError(cause: error)
            let cause = HTTPRequestExecutorError(error: error, request: request, response: httpResponse)
            dispatch(error: cause, forRequest: request, tasks: tasks)
        }
    }

    private func dispatch(error: HTTPRequestExecutorError, forRequest request: HTTPRequest, tasks: [RPCTask])
    {
        if let retrier = self.requestRetrier,
           retrier.should(executor: self, retryRequest: request, afterError: error)
        {
            perform(httpRequest: request, forTasks: tasks)
        }
        else {
            for task in tasks {
                task.handler(.error(error))
            }
        }
    }

    private func dispatch(responses: [Response], forTasks tasks: [RPCTask])
    {
        for task in tasks
        {
            if let response = responses.first(where: { $0.id == task.request.id })
            {
                task.handler(.response(response))
            }
            else {
                fatalError("Void requests is not supported yet!")
            }
        }
    }

    private func enqueue(task: RPCTask)
    {
        _ = self.tasks.modify { tasks in
            var tasks = tasks
            tasks.append(task)
            return tasks
        }
    }

    private func dequeueTasks() -> [RPCTask] {
        return self.tasks.swap([])
    }

    private func enqueue(httpTask: HTTPTask)
    {
        _ = self.httpTasks.modify { httpTasks in
            var httpTasks = httpTasks
            httpTasks.append(httpTask)
            return httpTasks
        }
    }

    private func dequeue(httpTask: HTTPTask)
    {
        _ = self.httpTasks.modify { httpTasks in
            var httpTasks = httpTasks
            if let idx = httpTasks.index(where: { $0.httpRequest == httpTask.httpRequest }) {
                httpTasks.remove(at: idx)
            }
            return httpTasks
        }
    }

// MARK: - Inner Types

    private struct RPCTask
    {
        let request: Request
        let handler: (RequestExecutorResult) -> Void
    }

    private struct HTTPTask
    {
        let httpRequest: HTTPRequest
        let requests: [Request]
    }

// MARK: - Variables

    private let httpClient: HTTPClient

    private let tasks = Atomic<[RPCTask]>([])

    private let httpTasks = Atomic<[HTTPTask]>([])

}

// ----------------------------------------------------------------------------

extension HTTPResponseSerializationError
{
// MARK: - Inner Types

    struct UnexpectedPayloadTypeError: Error {
        let payload: Any
    }

}

// ----------------------------------------------------------------------------

