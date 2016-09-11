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

public class HTTPRequestManager: RequestManager
{
// MARK: - Construction

    public init(baseURL: NSURL)
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

    public let baseURL: NSURL

// MARK: - Functions

    override func performRequest(request: Request)
    {
        let httpRequest = buildHTTPRequest(request)
        performHTTPRequest(httpRequest)
    }

    func buildHTTPRequest(request: Request) -> HTTPRequest {
        return HTTPRequest(url: self.baseURL, headers: [:], body: request)
    }

    func performHTTPRequest(httpRequest: HTTPRequest) {
        self.httpClient.performRequest(httpRequest)
    }

    func dispatchHTTPResponse(httpResponse: HTTPResponse, forHTTPRequest httpRequest: HTTPRequest) {
        dispatchResponse(httpResponse.body, forRequest: httpRequest.body)
    }

    func dispatchHTTPError(error: HTTPClientError, forHTTPRequest httpRequest: HTTPRequest) {
        dispatchError(error.cause, forRequest: httpRequest.body)
    }

    func dispatchResponse(response: Response, forRequest request: Request) {
        self.delegate?.requestManager(self, didReceiveResponse: response, forRequest: request)
    }

    func dispatchError(error: ErrorType, forRequest request: Request) {
        self.delegate?.requestManager(self, didFailWithError: error, forRequest: request)
    }

// MARK: - Variables

    private let httpClient: HTTPClient
}

// ----------------------------------------------------------------------------

extension HTTPRequestManager: HTTPClientDelegate
{
// MARK: - Functions

    func httpClient(client: HTTPClient, didReceiveResponse response: HTTPResponse, forRequest request: HTTPRequest) {
        dispatchHTTPResponse(response, forHTTPRequest: request)
    }

    func httpClient(client: HTTPClient, didFailWithError error: HTTPClientError, forRequest request: HTTPRequest) {
        dispatchHTTPError(error, forHTTPRequest: request)
    }

}

// ----------------------------------------------------------------------------
