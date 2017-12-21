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

    func parse(_ object: AnyObject) throws -> ResultType
    {
        guard let value = object as? ResultType else {
            throw ResultParserError.invalidFormat(object: object)
        }

        return value
    }

}

// ----------------------------------------------------------------------------

extension JSONRPCService
{
// MARK: Functions

    open func invoke<Result: JsonPrimitive>(_ method: String, params: Invocation<Result>.Params? = nil) -> ResultProvider<Result>
    {
        return invoke(method, params: params, parser: JsonPrimitiveResultParser())
    }

}

// ----------------------------------------------------------------------------

public protocol JsonPrimitive {}

extension Int: JsonPrimitive {}

extension String: JsonPrimitive {}

extension Bool: JsonPrimitive {}

// ----------------------------------------------------------------------------
