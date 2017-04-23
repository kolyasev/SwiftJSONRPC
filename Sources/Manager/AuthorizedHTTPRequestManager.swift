// ----------------------------------------------------------------------------
//
//  AuthorizedHTTPRequestManager.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

// import Atomic

// ----------------------------------------------------------------------------

public enum AuthorizationRequestResult
{
    case authorizationHeader(authorizationHeader: String)
    case error(error: Error)
    case cancel
}

// ----------------------------------------------------------------------------

public protocol AuthorizedHTTPRequestManagerDelegate: class
{
// MARK: - Functions

    func authorizedHTTPRequestManager(_ manager: AuthorizedHTTPRequestManager, requestAuthorizationWithCompletionHandler completionHandler: (AuthorizationRequestResult) -> Void)

}

// ----------------------------------------------------------------------------

open class AuthorizedHTTPRequestManager: HTTPRequestManager
{
// MARK: - Construction

    public init(baseURL: URL, authorizationHeader: String)
    {
        // Init instance variables
        self.authorizationHeader = Atomic(authorizationHeader)

        // Parent processing
        super.init(baseURL: baseURL)
    }

// MARK: - Properties

    open weak var authorizationDelegate: AuthorizedHTTPRequestManagerDelegate?

// MARK: - Inner Functions

    override func buildHTTPRequest(_ request: Request) -> HTTPRequest
    {
        let httpRequest = super.buildHTTPRequest(request)
        var headers = httpRequest.headers

        // Add authorization header
        headers[Header.Authorization] = self.authorizationHeader.value

        // Create copy with updated headers
        let authorizedHttpRequest = HTTPRequest(url: httpRequest.url, headers: headers, body: httpRequest.body)

        return authorizedHttpRequest
    }

    override func performHTTPRequest(_ httpRequest: HTTPRequest)
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

    override func dispatchHTTPResponse(_ httpResponse: HTTPResponse, forHTTPRequest httpRequest: HTTPRequest)
    {
        if case .error(let error) = httpResponse.body.body, (error.code == HttpStatus.Unauthorized)
        {
            dispatchAuthorizationError(nil, forHTTPRequest: httpRequest)
        }
        else {
            super.dispatchHTTPResponse(httpResponse, forHTTPRequest: httpRequest)
        }
    }

    override func dispatchHTTPError(_ error: HTTPClientError, forHTTPRequest httpRequest: HTTPRequest)
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

    fileprivate func dispatchAuthorizationError(_ error: Error?, forHTTPRequest httpRequest: HTTPRequest)
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

    fileprivate func performDelayedRequests()
    {
        for request in self.delayedRequests.swap([]) {
            performRequest(request)
        }
    }

    fileprivate func requestAuthorization()
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

    fileprivate func handleAuthorizationRequestResult(_ result: AuthorizationRequestResult)
    {
        switch result
        {
            case .authorizationHeader(let authorizationHeader):
                updateAuthorizationHeader(authorizationHeader)

            case .error(_), .cancel:
                cancelDelayedRequests()
        }
    }

    fileprivate func updateAuthorizationHeader(_ authorizationHeader: String)
    {
        self.authorizationHeader.value = authorizationHeader

        // Resume delayed requests
        performDelayedRequests()
    }

    fileprivate func cancelDelayedRequests()
    {
        for request in self.delayedRequests.swap([]) {
            self.delegate?.requestManager(self, didCancelRequest: request)
        }
    }

// MARK: - Inner Types

    // ...

// MARK: - Constants

    fileprivate struct Header {
        static let Authorization = "Authorization"
    }

    fileprivate struct HttpStatus {
        static let Unauthorized = 401
    }

// MARK: - Variables

    fileprivate let authorizationHeader: Atomic<String>

    fileprivate let hasActiveAuthorizationRequest = Atomic<Bool>(false)

    fileprivate let delayedRequests = Atomic<[Request]>([])

}

// ----------------------------------------------------------------------------
