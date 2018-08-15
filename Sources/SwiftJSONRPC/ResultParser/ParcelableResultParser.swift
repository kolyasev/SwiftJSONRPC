// ----------------------------------------------------------------------------
//
//  ParcelableResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import PromiseKit

// ----------------------------------------------------------------------------

class ParcelableResultParser<Result: Parcelable>: ResultParser
{
// MARK: Functions

    func parse(_ object: AnyObject) throws -> Result
    {
        guard let params = object as? [String: AnyObject] else {
            throw ResultParserError.invalidFormat(object: object)
        }

        return try Result(params: params)
    }

}

// ----------------------------------------------------------------------------

extension RPCService
{
// MARK: Functions

    open func invoke<Result: Parcelable>(_ method: String, params: Invocation<Result>.Params? = nil) -> Promise<Result>
    {
        return invoke(method, params: params, parser: ParcelableResultParser())
    }

}

// ----------------------------------------------------------------------------
