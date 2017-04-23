// ----------------------------------------------------------------------------
//
//  RPCClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

// import Atomic

// ----------------------------------------------------------------------------

open class RPCClient
{
// MARK: - Construction

    public init(requestManager: RequestManager)
    {
        // Init instance variables
        self.requestManager = requestManager
        self.requestManager.delegate = self
    }

    public convenience init(baseURL: URL)
    {
        // Init http request manager
        let requestManager = HTTPRequestManager(baseURL: baseURL)

        // Parent processing
        self.init(requestManager: requestManager)
    }

// MARK: - Properties

    open static var logEnabled: Bool =  false

// MARK: - Public Functions

    open func perform<R>(_ invocation: Invocation<R>) // TODO: ... -> Cancelable
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

    fileprivate func dispatchResponse(_ response: Response, forRequest request: Request)
    {
        assert(request.id == response.id)

        let identifier = response.id
        if let invocation = self.invocations.value.removeValue(forKey: identifier)
        {
            // Dispatch response
            switch response.body
            {
                case .success(let result):
                    invocation.dispatchResult(result)

                case .error(let error):
                    invocation.dispatchError(InvocationError.rpcError(error: error))
            }

            // Dispatch invocation finish blocks
            invocation.dispatchFinish()
        }
    }

    fileprivate func dispatchError(_ error: Error, forRequest request: Request)
    {
        // TODO: Support notification type calls without identifiers
        if let identifier = request.id,
           let invocation = self.invocations.value.removeValue(forKey: identifier)
        {
            // Dispatch error
            invocation.dispatchError(InvocationError.applicationError(cause: error))

            // Dispatch invocation finish blocks
            invocation.dispatchFinish()
        }
    }

    fileprivate func dispatchCancel(forRequest request: Request)
    {
        // TODO: Support notification type calls without identifiers
        if let identifier = request.id,
           let invocation = self.invocations.value.removeValue(forKey: identifier)
        {
            // Dispatch cancel
            invocation.dispatchCancel()

            // Dispatch invocation finish blocks
            invocation.dispatchFinish()
        }
    }

// MARK: - Constants

    static let Version = "2.0"

// MARK: - Variables

    fileprivate let requestManager: RequestManager

    fileprivate let invocationSeqNo = Atomic<Int>(1)

    fileprivate let invocations = Atomic<[String: InvocationType]>([:])

}

// ----------------------------------------------------------------------------

extension RPCClient: RequestManagerDelegate
{
// MARK: - Functions

    func requestManager(_ requestManager: RequestManager, didReceiveResponse response: Response, forRequest request: Request) {
        dispatchResponse(response, forRequest: request)
    }

    func requestManager(_ requestManager: RequestManager, didFailWithError error: Error, forRequest request: Request) {
        dispatchError(error, forRequest: request)
    }

    func requestManager(_ requestManager: RequestManager, didCancelRequest request: Request) {
        dispatchCancel(forRequest: request)
    }

}

// ----------------------------------------------------------------------------
