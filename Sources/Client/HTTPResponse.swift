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

    init(url: URL, headers: [String: String], body: Response)
    {
        self.url = url
        self.headers = headers
        self.body = body
    }

// MARK: - Construction

    let url: URL

    let headers: [String: String]

    let body: Response

}

// ----------------------------------------------------------------------------
