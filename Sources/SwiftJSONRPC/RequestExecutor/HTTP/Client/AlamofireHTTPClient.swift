// ----------------------------------------------------------------------------
//
//  AlamofireHTTPClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation
import Alamofire

// ----------------------------------------------------------------------------

class AlamofireHTTPClient: HTTPClient
{
// MARK: - Functions

    func perform(request: HTTPRequest, completionHandler: @escaping (HTTPClient.PerformRequestResult) -> Void)
    {
        Alamofire
            .request(request)
            .responseData(queue: responseQueue(), completionHandler: { result in
                switch result.result
                {
                    case .success(let data):
                        if let response = result.response
                        {
                            // Parse response headers
                            let url = (response.url ?? request.url)
                            let code = response.statusCode
                            let headers = (response.allHeaderFields as? [String: String]) ?? [:]

                            let response = HTTPResponse(url: url, code: code, headers: headers, body: data)
                            completionHandler(.success(response))
                        }
                        else {
                            fatalError("Unexpected result.")
                        }

                    case .failure(let error):
                        let error = AlamofireHTTPClientError(cause: error)
                        completionHandler(.error(error))
                }
            })
    }

// MARK: - Private Functions

    private func responseQueue() -> DispatchQueue {
        return DispatchQueue.global()
    }

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

class AlamofireHTTPClientError: NestedError<Error>, HTTPClientError { }

// ----------------------------------------------------------------------------
