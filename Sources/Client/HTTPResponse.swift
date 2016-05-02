// ----------------------------------------------------------------------------
//
//  HTTPResponse.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class HTTPResponse
{
// MARK: - Construction

    init(url: NSURL, headers: [String: String], body: Response)
    {
        self.url = url
        self.headers = headers
        self.body = body
    }

// MARK: - Construction

    let url: NSURL

    let headers: [String: String]

    let body: Response

}

// ----------------------------------------------------------------------------
