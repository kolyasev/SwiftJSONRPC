//
//  URLSessionHTTPClient.swift
//  
//
//  Created by Denis Kolyasev on 09.07.2022.
//

import Foundation

struct URLSessionHTTPClient: HTTPClient {

    // MARK: - Private Properties

    private let urlSession: URLSession

    // MARK: - Initialization

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Functions

    func perform(request: HTTPRequest, completionHandler: @escaping (PerformRequestResult) -> Void) {
        let urlRequest = request.asURLRequest()
        let task = urlSession.dataTask(
            with: urlRequest,
            completionHandler: { data, response, error in
                Self.responseQueue().async {
                    if let error = error {
                        return completionHandler(.error(URLSessionError(cause: error)))
                    }

                    guard let response = response as? HTTPURLResponse else {
                        return completionHandler(.error(NoResponseError()))
                    }
                    guard let data = data else {
                        return completionHandler(.error(NoResponseDataError()))
                    }

                    // Parse response headers
                    let url = (response.url ?? request.url)
                    let code = response.statusCode
                    let headers = (response.allHeaderFields as? [String: String]) ?? [:]

                    let httpResponse = HTTPResponse(url: url, code: code, headers: headers, body: data)
                    return completionHandler(.success(httpResponse))
                }
            }
        )
        task.resume()
    }

    // MARK: - Private Functions

    private static func responseQueue() -> DispatchQueue {
        return DispatchQueue.global()
    }

    // MARK: - Inner Types

    class URLSessionError: NestedError<Error>, HTTPClientError { }
    class NoResponseError: HTTPClientError { }
    class NoResponseDataError: HTTPClientError { }

}

extension HTTPRequest  {

    // MARK: - Functions

    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: self.url)

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body

        return request
    }
}
