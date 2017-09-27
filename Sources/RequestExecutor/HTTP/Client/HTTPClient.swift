// ----------------------------------------------------------------------------
//
//  HTTPClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Alamofire

// ----------------------------------------------------------------------------

class HTTPClient
{
// MARK: - Functions

    func perform(request: HTTPRequest, completionHandler: @escaping (PerformRequestResult) -> Void)
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

    fileprivate func responseQueue() -> DispatchQueue {
        return DispatchQueue.global()
    }

// MARK: - Inner Types

    typealias PerformRequestResult = Result<HTTPResponse, HTTPClientError>

}

// ----------------------------------------------------------------------------

class AlamofireHTTPClientError: NestedError<Error>, HTTPClientError { }

// ----------------------------------------------------------------------------
