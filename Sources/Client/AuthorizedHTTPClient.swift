// ----------------------------------------------------------------------------
//
//  AuthorizedHTTPClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Atomic

// ----------------------------------------------------------------------------

public class AuthorizedHTTPClient: HTTPClient
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

    public weak var authorizationDelegate: AuthorizedHTTPClientDelegate?

// MARK: - Public Functions

    public func updateAuthorizationHeader(authorizationHeader: String)
    {
        self.authorizationHeader.value = authorizationHeader

        // Resume delayed requests
        performDelayedRequests()
    }

// MARK: - Inner Functions

    override func performRequest(request: Request)
    {
        if self.authorized.value
        {
            // Default behaviour
            super.performRequest(request)
        }
        else {
            // Delay request
            self.delayedRequests.value.append(request)
        }
    }

    override func dispatchError(error: HTTPClientError, forRequest request: Request)
    {
        if (error.response?.statusCode == HttpStatus.Unauthorized)
        {
            // Check if request have used right headers
            if (error.request?.allHTTPHeaderFields?[Header.Authorization] == self.authorizationHeader.value)
            {
                // Delay request
                self.delayedRequests.value.append(request)

                // Notify delegate if needed
                if self.authorized.swap(false) {
                    self.authorizationDelegate?.authorizedHTTPClient(self, didFailWithAuthorizationError: error)
                }
            }
            else {
                // Repeat request with valid headers
                performRequest(request)
            }
        }
        else {
            // Default behaviour
            super.dispatchError(error, forRequest: request)
        }
    }

    override func buildHeaders() -> [String : String]
    {
        var headers = super.buildHeaders()

        // Add authorization header
        headers[Header.Authorization] = self.authorizationHeader.value

        return headers
    }

// MARK: - Private Functions

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

public protocol AuthorizedHTTPClientDelegate: class
{
// MARK: - Functions

    func authorizedHTTPClient(client: AuthorizedHTTPClient, didFailWithAuthorizationError error: ErrorType)

}

// ----------------------------------------------------------------------------
