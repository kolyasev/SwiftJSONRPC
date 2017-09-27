// ----------------------------------------------------------------------------
//
//  HTTPRequest.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Alamofire
import Foundation

// ----------------------------------------------------------------------------

public struct HTTPRequest
{
// MARK: - Properties

    public var method: HTTPMethod

    public var url: URL

    public var headers: [String: String]

    public var body: Data

}

// ----------------------------------------------------------------------------

extension HTTPRequest: URLRequestConvertible
{
// MARK: - Functions

    public func asURLRequest() throws -> URLRequest
    {
        var request = URLRequest(url: self.url)

        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.headers
        request.httpBody = self.body

        return request
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
