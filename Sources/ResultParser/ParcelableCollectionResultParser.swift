// ----------------------------------------------------------------------------
//
//  ParcelableCollectionResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class ParcelableCollectionResultParser<ResultType: Collection, ElementType: Parcelable>: ResultParser where ResultType.Iterator.Element == ElementType
{
// MARK: Functions

    func parse(_ object: AnyObject) -> ResultType?
    {
        var result: ResultType?

        if let array = object as? [[String: AnyObject]]
        {
            result = array.map { ElementType(params: $0) } as? ResultType
        }

        return result
    }

}

// ----------------------------------------------------------------------------

extension RPC
{
// MARK: Functions

    public static func invocation<Result: Collection, ElementType: Parcelable>(_ method: String, params: Invocation<Result>.Params? = nil) -> Invocation<Result> where Result.Iterator.Element == ElementType
    {
        return invocation(method, params: params, parser: ParcelableCollectionResultParser())
    }

}

// ----------------------------------------------------------------------------
