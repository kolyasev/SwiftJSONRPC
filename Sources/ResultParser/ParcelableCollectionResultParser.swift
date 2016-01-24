// ----------------------------------------------------------------------------
//
//  ParcelableCollectionResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class ParcelableCollectionResultParser<ResultType: CollectionType, ElementType: Parcelable where ResultType.Generator.Element == ElementType>: ResultParser
{
// MARK: Functions

    func parse(object: AnyObject) -> ResultType?
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

    public func invocation<Result: CollectionType, ElementType: Parcelable where Result.Generator.Element == ElementType>(method: String, params: Params? = nil) -> Invocation<Result>
    {
        return invocation(method, params: params, parser: ParcelableCollectionResultParser())
    }

}

// ----------------------------------------------------------------------------
