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
// MARK: - Construction

    init(baseURL: NSURL, headers: [String: String])
    {
        self.baseURL = baseURL
        self.headers = headers
    }

// MARK: - Properties

    let baseURL: NSURL

    let headers: [String: String]

    weak var delegate: HTTPClientDelegate?

// MARK: - Functions

    func performRequest(request: Request)
    {
        weak var weakSelf = self

        // Build json-rpc body params
        let body = request.buildBody()

        // Log request
        if RPCClient.logEnabled {
            NSLog("Request: '%@'", body)
        }

        // Perform request
        Alamofire.request(.POST, self.baseURL, parameters: body, encoding: .JSON, headers: self.headers)
            .responseJSON(queue: responseQueue()) { response in
                switch response.result
                {
                    case .Success(let json):
                        // Log response
                        if RPCClient.logEnabled {
                            NSLog("Response: '%@'", json.description)
                        }

                        // Try to parse response
                        do {
                            let response = try Response(response: json)
                            weakSelf?.dispatchResponse(response, forRequest: request)
                        }
                        catch (let error) {
                            weakSelf?.dispatchError(error, forRequest: request)
                        }

                    case .Failure(let error):
                        weakSelf?.dispatchError(error, forRequest: request)
                }
        }
    }

// MARK: - Private Functions

    private func dispatchResponse(response: Response, forRequest request: Request) {
        self.delegate?.httpClient(self, didReceiveResponse: response, forRequest: request)
    }

    private func dispatchError(error: ErrorType, forRequest request: Request) {
        self.delegate?.httpClient(self, didFailWithError: error, forRequest: request)
    }

    private func responseQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    }

}

// ----------------------------------------------------------------------------

protocol HTTPClientDelegate: class
{
// MARK: - Functions

    func httpClient(client: HTTPClient, didReceiveResponse response: Response, forRequest request: Request)

    func httpClient(client: HTTPClient, didFailWithError error: ErrorType, forRequest request: Request)

}

// ----------------------------------------------------------------------------
