// ----------------------------------------------------------------------------
//
//  RPCClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Atomic

// ----------------------------------------------------------------------------

public class RPCClient
{
// MARK: - Construction

    public init(baseURL: String, headers: [String: String]? = nil)
    {
        let baseURL = NSURL(string: baseURL)!
        let headers = headers ?? [:]

        // Init instance variables
        self.httpClient = HTTPClient(baseURL: baseURL, headers: headers)
        self.httpClient.delegate = self
    }

// MARK: - Properties

    public static var logEnabled: Bool =  false

// MARK: - Public Functions

    public func perform<R>(invocation: Invocation<R>) // TODO: ... -> Cancelable
    {
        // TODO: Support notification type calls without identifiers
        // Generate invocation indentifier
        let identifier = String(self.invocationSeqNo.modify{ $0 + 1 })

        // ...
        self.invocations.value[identifier] = invocation

        // Init request
        let request = Request(id: identifier, invocation: invocation)

        // Dispatch start blocks
        invocation.dispatchStart()

        // Perform request
        self.httpClient.performRequest(request)
    }

// MARK: - Private Functions

    private func dispatchResponse(response: Response, forRequest request: Request)
    {
        assert(request.id == response.id)

        let identifier = response.id
        if let invocation = self.invocations.value.removeValueForKey(identifier)
        {
            // Dispatch response
            switch response.body
            {
                case .Success(let result):
                    invocation.dispatchResult(result)

                case .Error(let error):
                    invocation.dispatchError(InvocationError.RpcError(error: error))
            }

            // Dispatch invocation finish blocks
            invocation.dispatchFinish()
        }
    }

    private func dispatchError(error: ErrorType, forRequest request: Request)
    {
        // TODO: Support notification type calls without identifiers
        if let identifier = request.id,
           let invocation = self.invocations.value.removeValueForKey(identifier)
        {
            // Dispatch error
            invocation.dispatchError(InvocationError.ApplicationError(cause: error))

            // Dispatch invocation finish blocks
            invocation.dispatchFinish()
        }
    }

// MARK: - Constants

    static let Version = "2.0"

// MARK: - Variables

    private let httpClient: HTTPClient

    private let invocationSeqNo = Atomic<Int>(0)

    private let invocations = Atomic<[String: InvocationType]>([:])

}

// ----------------------------------------------------------------------------

extension RPCClient: HTTPClientDelegate
{
// MARK: - Functions

    func httpClient(client: HTTPClient, didReceiveResponse response: Response, forRequest request: Request) {
        dispatchResponse(response, forRequest: request)
    }

    func httpClient(client: HTTPClient, didFailWithError error: ErrorType, forRequest request: Request) {
        dispatchError(error, forRequest: request)
    }

}

// ----------------------------------------------------------------------------
