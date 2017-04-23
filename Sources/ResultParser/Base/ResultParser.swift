// ----------------------------------------------------------------------------
//
//  ResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public protocol ResultParser
{
// MARK: - Functions

    func parse(_ object: AnyObject) -> ResultType?

// MARK: - Inner Types

    associatedtype ResultType

}

// ----------------------------------------------------------------------------

public enum ResultParserError: Error
{
    case invalidResponseFormat(object: AnyObject)
}

// ----------------------------------------------------------------------------

class AnyResultParser<T>: ResultParser
{
// MARK: - Construction

    init<P: ResultParser>(_ base: P) where P.ResultType == T
    {
        // Init instance
        _parse = base.parse
    }

// MARK: - Functions

    func parse(_ object: AnyObject) -> ResultType? {
        return _parse(object)
    }

// MARK: - Inner Types

    typealias ResultType = T

// MARK: - Variables

    fileprivate let _parse: (AnyObject) -> ResultType?

}

// ----------------------------------------------------------------------------
