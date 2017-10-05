// ----------------------------------------------------------------------------
//
//  Invocation.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public struct Invocation<Result>
{
// MARK: - Construction

    init<Parser: ResultParser>(method: String, params: Params, parser: Parser)
        where Parser.Result == Result
    {
        // Init instance variables
        self.method = method
        self.params = params
        self.parser = AnyResultParser<Result>(parser)
    }

// MARK: - Properties

    public let method: String

    public let params: Params

    public let parser: AnyResultParser<Result>

// MARK: - Inner Types

    public typealias Params = [String: AnyObject?]

}

// ----------------------------------------------------------------------------
