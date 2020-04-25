// ----------------------------------------------------------------------------
//
//  HTTPRequest.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

// ----------------------------------------------------------------------------

public struct HTTPRequest
{
// MARK: - Properties

    public var method: HTTPMethod

    public var url: URL

    public var headers: [String: String]

    public var body: Data?

}

// ----------------------------------------------------------------------------

extension HTTPRequest: Equatable
{
// MARK: - Functions

    public static func ==(lhs: HTTPRequest, rhs: HTTPRequest) -> Bool
    {
        return lhs.method == rhs.method &&
               lhs.url == rhs.url &&
               lhs.headers == rhs.headers &&
               lhs.body == rhs.body
    }

}

// ----------------------------------------------------------------------------

public enum HTTPMethod: String
{
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

// ----------------------------------------------------------------------------
