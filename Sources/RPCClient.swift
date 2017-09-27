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

    public init(requestExecutor: RequestExecutor)
    {
        // Init instance variables
        self.requestExecutor = requestExecutor
    }

// MARK: - Properties

    open static var logEnabled: Bool =  false

// MARK: - Public Functions

    open func perform<R>(_ invocation: Invocation<R>) // TODO: ... -> Cancelable
    {
        weak var weakSelf = self
        DispatchQueue.global().async
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
            instance.perform(request: request)
        }
    }

// MARK: - Private Functions

    private func perform(request: Request)
    {
        weak var weakSelf = self
        self.requestExecutor.execute(request: request) { result in
            switch result
            {
                case .response(let response):
                    weakSelf?.dispatch(response: response, forRequest: request)

                case .error(let error):
                    weakSelf?.dispatch(error: error, forRequest: request)

                case .cancel:
                    weakSelf?.dispatchCancel(forRequest: request)
            }
        }
    }

    private func dispatch(response: Response, forRequest request: Request)
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

    private func dispatch(error: Error, forRequest request: Request)
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

    private func dispatchCancel(forRequest request: Request)
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

    fileprivate let requestExecutor: RequestExecutor

    fileprivate let invocationSeqNo = Atomic<Int>(1)

    fileprivate let invocations = Atomic<[String: InvocationType]>([:])

}

// ----------------------------------------------------------------------------
