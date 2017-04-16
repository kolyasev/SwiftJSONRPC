// ----------------------------------------------------------------------------
//
//  AuthorizedHTTPRequestManager.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Atomic

// ----------------------------------------------------------------------------

public enum AuthorizationRequestResult
{
    case AuthorizationHeader(authorizationHeader: String)
    case Error(error: ErrorType)
    case Cancel
}

// ----------------------------------------------------------------------------

public protocol AuthorizedHTTPRequestManagerDelegate: class
{
// MARK: - Functions

    func authorizedHTTPRequestManager(manager: AuthorizedHTTPRequestManager, requestAuthorizationWithCompletionHandler completionHandler: (AuthorizationRequestResult) -> Void)

}

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
        if !(self.hasActiveAuthorizationRequest.value)
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

    override func dispatchHTTPError(error: HTTPClientError, forHTTPRequest httpRequest: HTTPRequest)
    {
        if (error.response?.statusCode == HttpStatus.Unauthorized)
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
        if !(self.hasActiveAuthorizationRequest.value)
        {
            // Check if request have used right headers
            if (httpRequest.headers[Header.Authorization] == self.authorizationHeader.value)
            {
                // Delay request
                self.delayedRequests.value.append(httpRequest.body)

                // Request authorization
                requestAuthorization()
            }
            else {
                // Repeat request with valid headers
                performRequest(httpRequest.body)
            }
        }
        else {
            // Delay request
            self.delayedRequests.value.append(httpRequest.body)
        }
    }

    private func performDelayedRequests()
    {
        for request in self.delayedRequests.swap([]) {
            performRequest(request)
        }
    }

    private func requestAuthorization()
    {
        if !(self.hasActiveAuthorizationRequest.swap(true))
        {
            weak var weakSelf = self
            self.authorizationDelegate?.authorizedHTTPRequestManager(self, requestAuthorizationWithCompletionHandler: { result in
                weakSelf?.handleAuthorizationRequestResult(result)
                weakSelf?.hasActiveAuthorizationRequest.value = false
            })
        }
    }

    private func handleAuthorizationRequestResult(result: AuthorizationRequestResult)
    {
        switch result
        {
            case .AuthorizationHeader(let authorizationHeader):
                updateAuthorizationHeader(authorizationHeader)

            case .Error(_), .Cancel:
                cancelDelayedRequests()
        }
    }

    private func updateAuthorizationHeader(authorizationHeader: String)
    {
        self.authorizationHeader.value = authorizationHeader

        // Resume delayed requests
        performDelayedRequests()
    }

    private func cancelDelayedRequests()
    {
        for request in self.delayedRequests.swap([]) {
            self.delegate?.requestManager(self, didCancelRequest: request)
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

    private let hasActiveAuthorizationRequest = Atomic<Bool>(false)

    private let delayedRequests = Atomic<[Request]>([])

}

// ----------------------------------------------------------------------------
