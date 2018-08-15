// ----------------------------------------------------------------------------
//
//  JsonPrimitiveResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import PromiseKit

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

extension RPCService
{
// MARK: Functions

    open func invoke<Result: JsonPrimitive>(_ method: String, params: Invocation<Result>.Params? = nil) -> Promise<Result>
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
