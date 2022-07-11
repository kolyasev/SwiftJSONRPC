// ----------------------------------------------------------------------------
//
//  DefaultHTTPResponseAdapter.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class DefaultHTTPResponseAdapter: HTTPResponseAdapter {

    // MARK: - Initialization

    public init() { }

    // MARK: - Functions

    open func adapt(response: HTTPResponse, forRequest request: HTTPRequest) throws -> HTTPResponse {
        guard (200..<300).contains(response.code) else {
            throw HTTPResponseStatusCodeError(cause: nil)
        }

        return response
    }
}
