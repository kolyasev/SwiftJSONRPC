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

    func parse(object: AnyObject) -> ResultType?

// MARK: - Inner Types

    typealias ResultType

}

// ----------------------------------------------------------------------------

public enum ResultParserError: ErrorType
{
    case InvalidResponseFormat(object: AnyObject)
}

// ----------------------------------------------------------------------------

class AnyResultParser<T>: ResultParser
{
// MARK: - Construction

    init<P: ResultParser where P.ResultType == T>(_ base: P)
    {
        // Init instance
        _parse = base.parse
    }

// MARK: - Functions

    func parse(object: AnyObject) -> ResultType? {
        return _parse(object)
    }

// MARK: - Inner Types

    typealias ResultType = T

// MARK: - Variables

    private let _parse: (AnyObject) -> ResultType?

}

// ----------------------------------------------------------------------------
