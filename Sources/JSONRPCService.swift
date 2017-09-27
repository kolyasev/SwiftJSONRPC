// ----------------------------------------------------------------------------
//
//  JSONRPCService.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class JSONRPCService
{
// MARK: - Construction

    public init(client: RPCClient) {
        self.client = client
    }

// MARK: - Public Functions

    open func perform<Result, Parser: ResultParser>(_ method: String, params: Invocation<Result>.Params?, parser: Parser) -> Invocation<Result> where Parser.ResultType == Result
    {
        let params = params ?? [:]

        // Init invocation object
        let invocation = Invocation<Result>(method: method, params: params, parser: parser)

        // Perform invocation
        self.client.perform(invocation)

        return invocation
    }

// MARK: - Variables

    private let client: RPCClient

}

// ----------------------------------------------------------------------------
