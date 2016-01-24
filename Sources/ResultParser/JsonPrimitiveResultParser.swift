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

    func parse(object: AnyObject) -> ResultType? {
        return object as? ResultType
    }

}

// ----------------------------------------------------------------------------

extension RPC
{
// MARK: Functions

    public func invocation<Result: JsonPrimitive>(method: String, params: Params? = nil) -> Invocation<Result>
    {
        return invocation(method, params: params, parser: JsonPrimitiveResultParser())
    }

}

// ----------------------------------------------------------------------------

public protocol JsonPrimitive {}

extension Int: JsonPrimitive {}

extension String: JsonPrimitive {}

// ----------------------------------------------------------------------------
