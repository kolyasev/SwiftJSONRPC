// ----------------------------------------------------------------------------
//
//  Invocation.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Alamofire

// ----------------------------------------------------------------------------

public class Invocation<Result>: InvocationProtocol
{
// MARK: Construction

    init<Parser: ResultParser where Parser.ResultType == Result>(identifier: Int, method: String, params: InvocationParams, parser: Parser, rpc: RPC)
    {
        // Init instance variables
        self.identifier = identifier
        self.method = method
        self.params = params
        self.parseBlock = { parser.parse($0) }
        self.rpc = rpc
    }

// MARK: Properties

    public let identifier: Int

    public let method: String

    public let params: InvocationParams

    public let parseBlock: (AnyObject) -> Result?

// MARK: Functions

    public func invoke() -> Cancelable
    {
        weak var weakSelf = self

        // Notify parent rpc object
        self.rpc.invocationWillInvoke(self)

        // Build params (remove 'nil' values)
        let params = buildParamsForRequest()

        // Init request
        let request = Request(method: self.method, params: params, id: String(self.identifier))

        // Dispatch start blocks
        self.callbackDispatcher.dispatchStart()

        // Perform request
        request.perform(self.rpc.baseURL, headers: self.rpc.headers) { result in
            if let instance = weakSelf
            {
                // Dispatch response
                instance.dispatchResponse(result)

                // Notify parent rpc object
                instance.rpc.invocationDidInvoke(weakSelf!)

                // Release request object
                instance.currentRequest = nil

                // Dispatch finish blocks
                instance.callbackDispatcher.dispatchFinish()
            }
        }

        // Retain request object
        self.currentRequest = request

        return self
    }

// MARK: Private Functions

    private func dispatchResponse(result: Alamofire.Result<Response, NSError>)
    {
        switch result
        {
            // Handler JSON-RPC response
            case .Success(let response):
                if let result = response.result
                {
                    // Parse result object
                    if let parsedResult = self.parseBlock(result) {
                        self.callbackDispatcher.dispatchResult(parsedResult)
                    }
                    else
                    {
                        // Init parsing error
                        let cause = ResultParserError.InvalidResponseFormat(object: result)
                        let error = InvocationError.ApplicationError(cause: cause)

                        // Dispatch error
                        self.callbackDispatcher.dispatchError(error)
                    }
                }
                else
                if let error = response.error {
                    self.callbackDispatcher.dispatchError(InvocationError.RpcError(error: error))
                }

            // Handle network/parsing errors
            case .Failure(let error):
                self.callbackDispatcher.dispatchError(InvocationError.ApplicationError(cause: error))
        }
    }

    private func buildParamsForRequest() -> [String: AnyObject]
    {
        var params: [String: AnyObject] = [:]

        // Remove 'nil' values
        for (key, value) in self.params
        {
            if let value = value {
                params[key] = value
            }
        }

        return params
    }

// MARK: Variables

    private unowned let rpc: RPC

    private var currentRequest: Request?

    private let callbackDispatcher = CallbackDispatcher<Result>()
    
}

// ----------------------------------------------------------------------------

extension Invocation: ResultProvider
{
// MARK: - Functions

    public func result(queue: ResultQueue, block: Invocation.ResultBlock) -> Self
    {
        self.callbackDispatcher.result(queue, block: block)
        return self
    }

    public func error(queue: ResultQueue, block: Invocation.ErrorBlock) -> Self
    {
        self.callbackDispatcher.error(queue, block: block)
        return self
    }

    public func start(queue: ResultQueue, block: Invocation.StartBlock) -> Self
    {
        self.callbackDispatcher.start(queue, block: block)
        return self
    }

    public func finish(queue: ResultQueue, block: Invocation.FinishBlock) -> Self
    {
        self.callbackDispatcher.finish(queue, block: block)
        return self
    }

// MARK: - Inner Types

    public typealias ResultType = Result

}

// ----------------------------------------------------------------------------

extension Invocation: Cancelable
{
// MARK: Functions

    public func cancel() {
        // TODO: ...
    }

}

// ----------------------------------------------------------------------------

public protocol InvocationProtocol: class
{
// MARK: Properties

    var identifier: Int { get }

// MARK: Functions

    func invoke() -> Cancelable

}

// ----------------------------------------------------------------------------

public typealias InvocationParams = [String: AnyObject?]

// ----------------------------------------------------------------------------
