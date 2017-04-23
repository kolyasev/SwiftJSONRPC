// ----------------------------------------------------------------------------
//
//  Invocation.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class Invocation<Result>: InvocationType
{
// MARK: - Construction

    init<Parser: ResultParser>(method: String, params: Params, parser: Parser) where Parser.ResultType == Result
    {
        // Init instance variables
        self.method = method
        self.params = params
        self.parser = AnyResultParser(parser)
    }

// MARK: - Properties

    open let method: String

    open let params: Params

// MARK: - Inner Functions

    func dispatchResult(_ result: AnyObject)
    {
        // Parse result object
        if let parsedResult = self.parser.parse(result)
        {
            self.callbackDispatcher.dispatchResult(parsedResult)
        }
        else
        {
            // Init parsing error
            let cause = ResultParserError.invalidResponseFormat(object: result)
            let error = InvocationError.applicationError(cause: cause)

            // Dispatch error
            self.callbackDispatcher.dispatchError(error)
        }
    }

    func dispatchError(_ error: InvocationError) {
        self.callbackDispatcher.dispatchError(error)
    }

    func dispatchCancel() {
        self.callbackDispatcher.dispatchCancel()
    }

    func dispatchStart() {
        self.callbackDispatcher.dispatchStart()
    }

    func dispatchFinish() {
        self.callbackDispatcher.dispatchFinish()
    }

// MARK: - Inner Types

    public typealias Params = [String: AnyObject?]

// MARK: - Variables

    fileprivate let parser: AnyResultParser<Result>

    fileprivate let callbackDispatcher = CallbackDispatcher<Result>()
    
}

// ----------------------------------------------------------------------------

extension Invocation: ResultProvider
{
// MARK: - Functions

    public func result(_ queue: ResultQueue, block: @escaping Invocation.ResultBlock) -> Self
    {
        self.callbackDispatcher.result(queue, block: block)
        return self
    }

    public func error(_ queue: ResultQueue, block: @escaping Invocation.ErrorBlock) -> Self
    {
        self.callbackDispatcher.error(queue, block: block)
        return self
    }

    public func cancel(_ queue: ResultQueue, block: @escaping Invocation.CancelBlock) -> Self
    {
        self.callbackDispatcher.cancel(queue, block: block)
        return self
    }

    public func start(_ queue: ResultQueue, block: @escaping Invocation.StartBlock) -> Self
    {
        self.callbackDispatcher.start(queue, block: block)
        return self
    }

    public func finish(_ queue: ResultQueue, block: @escaping Invocation.FinishBlock) -> Self
    {
        self.callbackDispatcher.finish(queue, block: block)
        return self
    }

// MARK: - Inner Types

    public typealias ResultType = Result

}

// ----------------------------------------------------------------------------

protocol InvocationType
{
// MARK: - Functions

    func dispatchResult(_ result: AnyObject)

    func dispatchError(_ error: InvocationError)

    func dispatchCancel()

    func dispatchStart()

    func dispatchFinish()

}

// ----------------------------------------------------------------------------
