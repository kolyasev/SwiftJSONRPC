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

    public init(requestManager: RequestManager)
    {
        // Init instance variables
        self.requestManager = requestManager
        self.requestManager.delegate = self
    }

    public convenience init(baseURL: NSURL)
    {
        // Init http request manager
        let requestManager = HTTPRequestManager(baseURL: baseURL)

        // Parent processing
        self.init(requestManager: requestManager)
    }

// MARK: - Properties

    public static var logEnabled: Bool =  false

// MARK: - Public Functions

    public func perform<R>(invocation: Invocation<R>) // TODO: ... -> Cancelable
    {
        weak var weakSelf = self
        dispatch.async.bg
        {
            guard let instance = weakSelf else { return }

            // TODO: Support notification type calls without identifiers
            // Generate invocation indentifier
            let identifier = String(instance.invocationSeqNo.modify{ $0 + 1 })

            // ...
            instance.invocations.value[identifier] = invocation

            // Init request
            let request = Request(id: identifier, invocation: invocation)

            // Dispatch start blocks
            invocation.dispatchStart()

            // Perform request
            instance.requestManager.performRequest(request)
        }
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

    private let requestManager: RequestManager

    private let invocationSeqNo = Atomic<Int>(1)

    private let invocations = Atomic<[String: InvocationType]>([:])

}

// ----------------------------------------------------------------------------

extension RPCClient: RequestManagerDelegate
{
// MARK: - Functions

    func requestManager(requestManager: RequestManager, didReceiveResponse response: Response, forRequest request: Request) {
        dispatchResponse(response, forRequest: request)
    }

    func requestManager(requestManager: RequestManager, didFailWithError error: ErrorType, forRequest request: Request) {
        dispatchError(error, forRequest: request)
    }

}

// ----------------------------------------------------------------------------
