// ----------------------------------------------------------------------------
//
//  Invocation.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class Invocation<Result>: InvocationType
{
// MARK: - Construction

    init<Parser: ResultParser where Parser.ResultType == Result>(method: String, params: Params, parser: Parser)
    {
        // Init instance variables
        self.method = method
        self.params = params
        self.parser = AnyResultParser(parser)
    }

// MARK: - Properties

    public let method: String

    public let params: Params

// MARK: - Inner Functions

    func dispatchResult(result: AnyObject)
    {
        // Parse result object
        if let parsedResult = self.parser.parse(result)
        {
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

    func dispatchError(error: InvocationError) {
        self.callbackDispatcher.dispatchError(error)
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

    private let parser: AnyResultParser<Result>

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

protocol InvocationType
{
// MARK: - Functions

    func dispatchResult(result: AnyObject)

    func dispatchError(error: InvocationError)

    func dispatchStart()

    func dispatchFinish()

}

// ----------------------------------------------------------------------------
