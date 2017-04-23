// ----------------------------------------------------------------------------
//
//  JsonPrimitiveResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class JsonPrimitiveResultParser<ResultType: JsonPrimitive>: ResultParser
{
// MARK: Functions

    func parse(_ object: AnyObject) -> ResultType? {
        return object as? ResultType
    }

}

// ----------------------------------------------------------------------------

extension RPC
{
// MARK: Functions

    public static func invocation<Result: JsonPrimitive>(_ method: String, params: Invocation<Result>.Params? = nil) -> Invocation<Result>
    {
        return invocation(method, params: params, parser: JsonPrimitiveResultParser())
    }

}

// ----------------------------------------------------------------------------

public protocol JsonPrimitive {}

extension Int: JsonPrimitive {}

extension String: JsonPrimitive {}

extension Bool: JsonPrimitive {}

// ----------------------------------------------------------------------------
