// ----------------------------------------------------------------------------
//
//  RPC.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class RPC
{
// MARK: - Public Functions

    open static func invocation<Result, Parser: ResultParser>(_ method: String, params: Invocation<Result>.Params?, parser: Parser) -> Invocation<Result> where Parser.ResultType == Result
    {
        let params = params ?? [:]

        // Init invocation object
        let invocation = Invocation<Result>(method: method, params: params, parser: parser)

        return invocation
    }

}

// ----------------------------------------------------------------------------
