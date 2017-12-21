// ----------------------------------------------------------------------------
//
//  RPCClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class RPCClient
{
// MARK: - Construction

    public init(requestExecutor: RequestExecutor)
    {
        // Init instance variables
        self.requestExecutor = requestExecutor
    }

    public convenience init(url: URL)
    {
        let requestExecutor = HTTPRequestExecutor(url: url)
        self.init(requestExecutor: requestExecutor)
    }

// MARK: - Properties

    open static var logEnabled: Bool = false

// MARK: - Public Functions

    open func invoke<Result>(_ invocation: Invocation<Result>) -> ResultProvider<Result>
    {
        // Init request
        let request = makeRequest(invocation: invocation)

        // Init result dispatcher
        let resultDispatcher = ResultDispatcher(invocation: invocation)

        // Perform request
        DispatchQueue.global().async { [weak self] in
            self?.perform(request: request, withResultDispatcher: resultDispatcher)
        }

        return resultDispatcher
    }

// MARK: - Private Functions

    private func makeRequest<Result>(invocation: Invocation<Result>) -> Request
    {
        // TODO: Support notification type calls without identifiers
        // Generate request indentifier
        let identifier = self.requestIdGenerator.next()

        // Init request
        return Request(id: identifier, invocation: invocation)
    }

    private func perform<R>(request: Request, withResultDispatcher resultDispatcher: ResultDispatcher<R>)
    {
        resultDispatcher.dispatchStart()
        self.requestExecutor.execute(request: request) { result in
            resultDispatcher.dispatch(result: result)
            resultDispatcher.dispatchFinish()
        }
    }

// MARK: - Constants

    static let Version = "2.0"

// MARK: - Variables

    private let requestExecutor: RequestExecutor

    private let requestIdGenerator = RequestIdGenerator()

}

// ----------------------------------------------------------------------------

extension ResultDispatcher
{
// MARK: - Private Functions

    fileprivate func dispatch(result: RequestExecutorResult)
    {
        switch result
        {
            case .response(let response):
                dispatch(response: response)

            case .error(let error):
                dispatchError(InvocationError.applicationError(cause: error))

            case .cancel:
                dispatchCancel()
        }
    }

    fileprivate func dispatch(response: Response)
    {
        switch response.body
        {
            case .success(let successBody):
                dispatchSuccessBody(successBody)

            case .error(let error):
                dispatchError(InvocationError.rpcError(error: error))
        }
    }

    fileprivate func dispatchSuccessBody(_ body: AnyObject)
    {
        do {
            let result = try self.invocation.parser.parse(body)
            dispatchResult(result)
        }
        catch (let cause)
        {
            let error = InvocationError.applicationError(cause: cause)
            dispatchError(error)
        }
    }

}

// ----------------------------------------------------------------------------

