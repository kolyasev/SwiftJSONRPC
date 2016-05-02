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

    func performRequest(request: HTTPRequest)
    {
        weak var weakSelf = self

        // Build json-rpc body params
        let body = request.body.buildBody()

        // Log request
        if RPCClient.logEnabled {
            NSLog("Request: '%@'", body)
        }

        // Perform request
        Alamofire.request(.POST, request.url, parameters: body, encoding: .JSON, headers: request.headers)
            .responseJSON(queue: responseQueue()) { result in
                switch result.result
                {
                    case .Success(let json):
                        // Log response
                        if RPCClient.logEnabled {
                            NSLog("Response: '%@'", json.description)
                        }

                        // Try to parse response
                        do {
                            let body = try Response(response: json)
                            let httpResponse = HTTPResponse(
                                url: result.response?.URL ?? request.url,
                                headers: (result.response?.allHeaderFields as? [String: String]) ?? [:],
                                body: body
                            )
                            weakSelf?.dispatchResponse(httpResponse, forRequest: request)
                        }
                        catch (let error) {
                            let error = HTTPClientError(cause: error, request: result.request, response: result.response)
                            weakSelf?.dispatchError(error, forRequest: request)
                        }

                    case .Failure(let error):
                        let error = HTTPClientError(cause: error, request: result.request, response: result.response)
                        weakSelf?.dispatchError(error, forRequest: request)
                }
        }
    }

    func dispatchResponse(response: HTTPResponse, forRequest request: HTTPRequest) {
        self.delegate?.httpClient(self, didReceiveResponse: response, forRequest: request)
    }

    func dispatchError(error: HTTPClientError, forRequest request: HTTPRequest) {
        self.delegate?.httpClient(self, didFailWithError: error, forRequest: request)
    }

// MARK: - Private Functions

    private func responseQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    }

}

// ----------------------------------------------------------------------------

protocol HTTPClientDelegate: class
{
// MARK: - Functions

    func httpClient(client: HTTPClient, didReceiveResponse response: HTTPResponse, forRequest request: HTTPRequest)

    func httpClient(client: HTTPClient, didFailWithError error: HTTPClientError, forRequest request: HTTPRequest)

}

// ----------------------------------------------------------------------------
