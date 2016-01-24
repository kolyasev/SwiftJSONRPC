// ----------------------------------------------------------------------------
//
//  ResultParser.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public protocol ResultParser
{
// MARK: Functions

    func parse(object: AnyObject) -> ResultType?

// MARK: Inner Types

    typealias ResultType

}

// ----------------------------------------------------------------------------

public enum ResultParserError: ErrorType
{
    case InvalidResponseFormat(object: AnyObject)
}

// ----------------------------------------------------------------------------
