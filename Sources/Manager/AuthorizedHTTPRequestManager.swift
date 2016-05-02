// ----------------------------------------------------------------------------
//
//  AuthorizedHTTPRequestManager.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Atomic

// ----------------------------------------------------------------------------

public class AuthorizedHTTPRequestManager: HTTPRequestManager
{
// MARK: - Construction

    public init(baseURL: NSURL, authorizationHeader: String)
    {
        // Init instance variables
        self.authorizationHeader = Atomic(authorizationHeader)

        // Parent processing
        super.init(baseURL: baseURL)
    }

// MARK: - Properties

    public weak var authorizationDelegate: AuthorizedHTTPRequestManagerDelegate?

// MARK: - Public Functions

    public func updateAuthorizationHeader(authorizationHeader: String)
    {
        self.authorizationHeader.value = authorizationHeader

        // Resume delayed requests
        performDelayedRequests()
    }

// MARK: - Inner Functions

    override func buildHTTPRequest(request: Request) -> HTTPRequest
    {
        let httpRequest = super.buildHTTPRequest(request)
        var headers = httpRequest.headers

        // Add authorization header
        headers[Header.Authorization] = self.authorizationHeader.value

        // Create copy with updated headers
        let authorizedHttpRequest = HTTPRequest(url: httpRequest.url, headers: headers, body: httpRequest.body)

        return authorizedHttpRequest
    }

    override func performHTTPRequest(httpRequest: HTTPRequest)
    {
        if self.authorized.value
        {
            // Default behaviour
            super.performHTTPRequest(httpRequest)
        }
        else {
            // Delay request
            self.delayedRequests.value.append(httpRequest.body)
        }
    }

    override func dispatchHTTPResponse(httpResponse: HTTPResponse, forHTTPRequest httpRequest: HTTPRequest)
    {
        if case .Error(let error) = httpResponse.body.body where (error.code == HttpStatus.Unauthorized)
        {
            dispatchAuthorizationError(nil, forHTTPRequest: httpRequest)
        }
        else {
            super.dispatchHTTPResponse(httpResponse, forHTTPRequest: httpRequest)
        }
    }

    override func dispatchHTTPError(error: ErrorType, forHTTPRequest httpRequest: HTTPRequest)
    {
        if let error = (error as? HTTPClientError) where (error.response?.statusCode == HttpStatus.Unauthorized)
        {
            dispatchAuthorizationError(error, forHTTPRequest: httpRequest)
        }
        else {
            super.dispatchHTTPError(error, forHTTPRequest: httpRequest)
        }
    }

// MARK: - Private Functions

    private func dispatchAuthorizationError(error: ErrorType?, forHTTPRequest httpRequest: HTTPRequest)
    {
        // Check if request have used right headers
        if (httpRequest.headers[Header.Authorization] == self.authorizationHeader.value)
        {
            // Delay request
            self.delayedRequests.value.append(httpRequest.body)

            // Notify delegate if needed
            if self.authorized.swap(false) {
                self.authorizationDelegate?.authorizedHTTPRequestManager(self, didFailWithAuthorizationError: error)
            }
        }
        else {
            // Repeat request with valid headers
            performRequest(httpRequest.body)
        }
    }

    private func performDelayedRequests()
    {
        for request in self.delayedRequests.swap([]) {
            performRequest(request)
        }
    }

// MARK: - Inner Types

    // ...

// MARK: - Constants

    private struct Header {
        static let Authorization = "Authorization"
    }

    private struct HttpStatus {
        static let Unauthorized = 401
    }

// MARK: - Variables

    private let authorizationHeader: Atomic<String>

    private let authorized = Atomic<Bool>(true)

    private let delayedRequests = Atomic<[Request]>([])

}

// ----------------------------------------------------------------------------

public protocol AuthorizedHTTPRequestManagerDelegate: class
{
// MARK: - Functions

    func authorizedHTTPRequestManager(manager: AuthorizedHTTPRequestManager, didFailWithAuthorizationError error: ErrorType?)

}

// ----------------------------------------------------------------------------
