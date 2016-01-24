// ----------------------------------------------------------------------------
//
//  RPC.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class RPC
{
// MARK: Construction

    public init(baseURL: String)
    {
        // Init instance variables
        self.baseURL = baseURL
    }

// MARK: Properties

    public let baseURL: String

    public static var logEnabled: Bool =  false

// MARK: Public Functions

    public func invocation<Result, Parser: ResultParser where Parser.ResultType == Result>(method: String, params: Params?, parser: Parser) -> Invocation<Result>
    {
        let identifier = (++self.invocationSeqId)
        let params = params ?? [:]

        // Init invocation object
        let invocation = Invocation<Result>(identifier: identifier, method: method, params: params, parser: parser, rpc: self)

        return invocation
    }

// MARK: Internal Functions

    // TODO: Synchronize
    func invocationWillInvoke(invocation: InvocationProtocol) {
        self.invocations[invocation.identifier] = invocation
    }

    // TODO: Synchronize
    func invocationDidInvoke(invocation: InvocationProtocol) {
        self.invocations[invocation.identifier] = nil
    }

// MARK: Inner Types

    public typealias Params = [String: AnyObject?]

// MARK: Variables

    private var invocationSeqId: Int = 0

    private var invocations: [Int: InvocationProtocol] = [:]

}

// ----------------------------------------------------------------------------
