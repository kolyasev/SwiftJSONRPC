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

extension JSONRPCService
{
// MARK: Functions

    public func perform<Result: JsonPrimitive>(_ method: String, params: Invocation<Result>.Params? = nil) -> Invocation<Result>
    {
        return perform(method, params: params, parser: JsonPrimitiveResultParser())
    }

}

// ----------------------------------------------------------------------------

public protocol JsonPrimitive {}

extension Int: JsonPrimitive {}

extension String: JsonPrimitive {}

extension Bool: JsonPrimitive {}

// ----------------------------------------------------------------------------
