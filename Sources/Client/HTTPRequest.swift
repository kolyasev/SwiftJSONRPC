// ----------------------------------------------------------------------------
//
//  HTTPRequest.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class HTTPRequest
{
// MARK: - Construction

    init(url: URL, headers: [String: String], body: Request)
    {
        self.url = url
        self.headers = headers
        self.body = body
    }

// MARK: - Properties

    let url: URL

    let headers: [String: String]

    let body: Request

}

// ----------------------------------------------------------------------------
