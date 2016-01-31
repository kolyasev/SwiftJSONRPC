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

    public func result(block: ResultBlock) -> Self
    {
        self.resultBlocks.append(block)

        return self
    }

    public func error(block: ErrorBlock) -> Self
    {
        self.errorBlocks.append(block)

        return self
    }

    public func start(block: StartBlock) -> Self
    {
        self.startBlocks.append(block)

        return self
    }

    public func finish(block: FinishBlock) -> Self
    {
        self.finishBlocks.append(block)

        return self
    }

    public func invoke() -> InvocationProtocol
    {
        weak var weakSelf = self

        // Notify parent rpc object
        self.rpc.invocationWillInvoke(self)

        // Build params (remove 'nil' values)
        let params = buildParamsForRequest()

        // Init request
        let request = Request(method: self.method, params: params, id: String(self.identifier))

        // Dispatch start blocks
        dispatchStart()

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
                instance.dispatchFinish()
            }
        }

        // Retain request object
        self.currentRequest = request

        return self
    }

    public func cancel() {
        // TODO: ...
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
                        dispatchResult(parsedResult)
                    }
                    else
                    {
                        // Init parsing error
                        let cause = ResultParserError.InvalidResponseFormat(object: result)
                        let error = InvocationError.ApplicationError(cause: cause)

                        // Dispatch error
                        dispatchError(error)
                    }
                }
                else
                if let error = response.error {
                    dispatchError(InvocationError.RpcError(error: error))
                }

            // Handle network/parsing errors
            case .Failure(let error):
                dispatchError(InvocationError.ApplicationError(cause: error))
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

// MARK: Private Functions: Callbacks Dispatching

    private func dispatchResult(result: Result)
    {
        dispatch.async.main
        {
            for resultBlock in self.resultBlocks {
                resultBlock(r: result)
            }
        }
    }

    private func dispatchError(error: InvocationError)
    {
        dispatch.async.main
        {
            for errorBlock in self.errorBlocks {
                errorBlock(e: error)
            }
        }
    }


    private func dispatchStart()
    {
        dispatch.async.main
        {
            for startBlock in self.startBlocks {
                startBlock()
            }
        }
    }

    private func dispatchFinish()
    {
        dispatch.async.main
        {
            for finishBlock in self.finishBlocks {
                finishBlock()
            }
        }
    }

// MARK: Inner Types

    public typealias ResultBlock = (r: Result) -> Void

    public typealias ErrorBlock = (e: InvocationError) -> Void

    public typealias StartBlock = () -> Void

    public typealias FinishBlock = () -> Void

// MARK: Variables

    private var resultBlocks: [ResultBlock] = []
    
    private var errorBlocks: [ErrorBlock] = []

    private var startBlocks: [StartBlock] = []

    private var finishBlocks: [FinishBlock] = []

    private unowned let rpc: RPC

    private var currentRequest: Request?
    
}

// ----------------------------------------------------------------------------

public protocol InvocationProtocol: class
{
// MARK: Properties

    var identifier: Int { get }

// MARK: Functions

    func invoke() -> InvocationProtocol

    func cancel()

}

// ----------------------------------------------------------------------------

public enum InvocationError: ErrorType
{
    case ApplicationError(cause: ErrorType)
    case RpcError(error: RPCError)
}

// ----------------------------------------------------------------------------

public typealias InvocationParams = [String: AnyObject?]

// ----------------------------------------------------------------------------
