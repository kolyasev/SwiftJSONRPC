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

    func parse(_ object: AnyObject) throws -> Result

// MARK: - Inner Types

    associatedtype Result

}

// ----------------------------------------------------------------------------

public enum ResultParserError: Error
{
    case invalidFormat(object: AnyObject)
}

// ----------------------------------------------------------------------------

public struct AnyResultParser<T>: ResultParser
{
// MARK: - Construction

    init<P: ResultParser>(_ base: P) where P.Result == T
    {
        // Init instance
        _parse = base.parse
    }

// MARK: - Functions

    public func parse(_ object: AnyObject) throws -> Result {
        return try _parse(object)
    }

// MARK: - Inner Types

    public typealias Result = T

// MARK: - Variables

    fileprivate let _parse: (AnyObject) throws -> Result

}

// ----------------------------------------------------------------------------
