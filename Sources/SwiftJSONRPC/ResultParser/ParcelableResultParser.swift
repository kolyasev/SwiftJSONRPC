// ----------------------------------------------------------------------------
//
//  ParcelableResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
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

extension JSONRPCService
{
// MARK: Functions

    open func invoke<Result: Parcelable>(_ method: String, params: Invocation<Result>.Params? = nil) -> ResultProvider<Result>
    {
        return invoke(method, params: params, parser: ParcelableResultParser())
    }

}

// ----------------------------------------------------------------------------
