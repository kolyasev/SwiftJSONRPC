// ----------------------------------------------------------------------------
//
//  RequestManager.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------
//
// TODO: Implement packing multiple rpc-requests to one http-request
//
// ----------------------------------------------------------------------------

open class HTTPRequestManager: RequestManager
{
// MARK: - Construction

    public init(baseURL: URL)
    {
        // Init instance variables
        self.baseURL = baseURL
        self.httpClient = HTTPClient()

        // Parent processing
        super.init()

        // ...
        self.httpClient.delegate = self
    }

// MARK: - Properties

    open let baseURL: URL

// MARK: - Functions

    override func performRequest(_ request: Request)
    {
        let httpRequest = buildHTTPRequest(request)
        performHTTPRequest(httpRequest)
    }

    func buildHTTPRequest(_ request: Request) -> HTTPRequest {
        return HTTPRequest(url: self.baseURL, headers: [:], body: request)
    }

    func performHTTPRequest(_ httpRequest: HTTPRequest) {
        self.httpClient.performRequest(httpRequest)
    }

    func dispatchHTTPResponse(_ httpResponse: HTTPResponse, forHTTPRequest httpRequest: HTTPRequest) {
        dispatchResponse(httpResponse.body, forRequest: httpRequest.body)
    }

    func dispatchHTTPError(_ error: HTTPClientError, forHTTPRequest httpRequest: HTTPRequest) {
        dispatchError(error.cause, forRequest: httpRequest.body)
    }

    func dispatchResponse(_ response: Response, forRequest request: Request) {
        self.delegate?.requestManager(self, didReceiveResponse: response, forRequest: request)
    }

    func dispatchError(_ error: Error, forRequest request: Request) {
        self.delegate?.requestManager(self, didFailWithError: error, forRequest: request)
    }

// MARK: - Variables

    fileprivate let httpClient: HTTPClient
}

// ----------------------------------------------------------------------------

extension HTTPRequestManager: HTTPClientDelegate
{
// MARK: - Functions

    func httpClient(_ client: HTTPClient, didReceiveResponse response: HTTPResponse, forRequest request: HTTPRequest) {
        dispatchHTTPResponse(response, forHTTPRequest: request)
    }

    func httpClient(_ client: HTTPClient, didFailWithError error: HTTPClientError, forRequest request: HTTPRequest) {
        dispatchHTTPError(error, forHTTPRequest: request)
    }

}

// ----------------------------------------------------------------------------
