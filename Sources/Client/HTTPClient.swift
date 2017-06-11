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
// MARK: - Properties

    weak var delegate: HTTPClientDelegate?

// MARK: - Functions

    func performRequest(_ request: HTTPRequest)
    {
        weak var weakSelf = self

        // Build json-rpc body params
        let body = request.body.buildBody()

        // Log request
        if RPCClient.logEnabled {
            NSLog("Request: '%@'", body)
        }

        // Perform request
        Alamofire.request(request.url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: request.headers)
            .validate()
            .responseJSON(queue: responseQueue()) { result in
                switch result.result
                {
                    case .success(let json):
                        // Log response
                        if RPCClient.logEnabled {
                            NSLog("Response: '%@'", String(describing: json))
                        }

                        // Try to parse response
                        do {
                            let body = try Response(response: json)
                            let httpResponse = HTTPResponse(
                                url: result.response?.url ?? request.url,
                                headers: (result.response?.allHeaderFields as? [String: String]) ?? [:],
                                body: body
                            )
                            weakSelf?.dispatchResponse(httpResponse, forRequest: request)
                        }
                        catch (let error) {
                            let error = HTTPClientError(cause: error, request: result.request, response: result.response)
                            weakSelf?.dispatchError(error, forRequest: request)
                        }

                    case .failure(let error):
                        let error = HTTPClientError(cause: error, request: result.request, response: result.response)
                        weakSelf?.dispatchError(error, forRequest: request)
                }
        }
    }

    func dispatchResponse(_ response: HTTPResponse, forRequest request: HTTPRequest) {
        self.delegate?.httpClient(self, didReceiveResponse: response, forRequest: request)
    }

    func dispatchError(_ error: HTTPClientError, forRequest request: HTTPRequest) {
        self.delegate?.httpClient(self, didFailWithError: error, forRequest: request)
    }

// MARK: - Private Functions

    fileprivate func responseQueue() -> DispatchQueue {
        return DispatchQueue.global()
    }

}

// ----------------------------------------------------------------------------

protocol HTTPClientDelegate: class
{
// MARK: - Functions

    func httpClient(_ client: HTTPClient, didReceiveResponse response: HTTPResponse, forRequest request: HTTPRequest)

    func httpClient(_ client: HTTPClient, didFailWithError error: HTTPClientError, forRequest request: HTTPRequest)

}

// ----------------------------------------------------------------------------
