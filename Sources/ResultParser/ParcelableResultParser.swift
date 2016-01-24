// ----------------------------------------------------------------------------
//
//  ParcelableResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class ParcelableResultParser<ResultType: Parcelable>: ResultParser
{
// MARK: Functions

    func parse(object: AnyObject) -> ResultType?
    {
        var result: ResultType?

        if let params = object as? [String: AnyObject] {
            result = ResultType(params: params)
        }

        return result
    }

}

// ----------------------------------------------------------------------------

extension RPC
{
// MARK: Functions

    public func invocation<Result: Parcelable>(method: String, params: Params? = nil) -> Invocation<Result>
    {
        return invocation(method, params: params, parser: ParcelableResultParser())
    }

}

// ----------------------------------------------------------------------------
