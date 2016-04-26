// ----------------------------------------------------------------------------
//
//  RPC.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class RPC
{
// MARK: - Public Functions

    public static func invocation<Result, Parser: ResultParser where Parser.ResultType == Result>(method: String, params: Invocation<Result>.Params?, parser: Parser) -> Invocation<Result>
    {
        let params = params ?? [:]

        // Init invocation object
        let invocation = Invocation<Result>(method: method, params: params, parser: parser)

        return invocation
    }

}

// ----------------------------------------------------------------------------
