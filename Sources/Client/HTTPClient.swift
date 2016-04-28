// ----------------------------------------------------------------------------
//
//  HTTPClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Alamofire

// ----------------------------------------------------------------------------

public class HTTPClient
{
// MARK: - Construction

    public init(baseURL: NSURL)
    {
        // Init instance variables
        self.baseURL = baseURL
    }

// MARK: - Properties

    public let baseURL: NSURL

    public var additionalHeaders: [String: String] = [:]

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
        Alamofire.request(.POST, self.baseURL, parameters: body, encoding: .JSON, headers: buildHeaders())
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
                            let error = HTTPClientError(cause: error, request: response.request, response: response.response)
                            weakSelf?.dispatchError(error, forRequest: request)
                        }

                    case .Failure(let error):
                        let error = HTTPClientError(cause: error, request: response.request, response: response.response)
                        weakSelf?.dispatchError(error, forRequest: request)
                }
        }
    }

    func dispatchResponse(response: Response, forRequest request: Request) {
        self.delegate?.httpClient(self, didReceiveResponse: response, forRequest: request)
    }

    func dispatchError(error: HTTPClientError, forRequest request: Request) {
        self.delegate?.httpClient(self, didFailWithError: error, forRequest: request)
    }

    func buildHeaders() -> [String: String] {
        return self.additionalHeaders
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

    func httpClient(client: HTTPClient, didReceiveResponse response: Response, forRequest request: Request)

    func httpClient(client: HTTPClient, didFailWithError error: HTTPClientError, forRequest request: Request)

}

// ----------------------------------------------------------------------------
