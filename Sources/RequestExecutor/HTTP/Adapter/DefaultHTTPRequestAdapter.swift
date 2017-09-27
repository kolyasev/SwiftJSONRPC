// ----------------------------------------------------------------------------
//
//  DefaultHTTPRequestAdapter.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class DefaultHTTPRequestAdapter: HTTPRequestAdapter
{
// MARK: - Construction

    public init() { }

// MARK: - Functions

    open func adapt(request: HTTPRequest) -> HTTPRequest {
        return request
    }

}

// ----------------------------------------------------------------------------
