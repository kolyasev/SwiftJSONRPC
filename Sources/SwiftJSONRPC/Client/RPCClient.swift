// ----------------------------------------------------------------------------
//
//  RPCClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation
import PromiseKit

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

    public var requestRetrier: RequestRetrier? = nil

// MARK: - Public Functions

    open func invoke<Result>(_ invocation: Invocation<Result>) -> Promise<Result>
    {
        // Init request
        let request = makeRequest(invocation: invocation)

        // Init result dispatcher
        let resultDispatcher = ResultDispatcher(invocation: invocation)

        // Perform request
        DispatchQueue.global().async { [weak self] in
            self?.execute(request: request, withResultDispatcher: resultDispatcher)
        }

        return resultDispatcher.promise
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

    private func execute<R>(request: Request, withResultDispatcher resultDispatcher: ResultDispatcher<R>)
    {
        execute(request: request) { result in
            resultDispatcher.dispatch(result: result)
        }
    }

    private func execute(request: Request, completionHandler: @escaping (RequestExecutorResult) -> Void)
    {
        self.requestExecutor.execute(request: request) { [weak self] result in
            if let instance = self,
               instance.shouldRetry(request: request, afterResult: result)
            {
                instance.execute(request: request, completionHandler: completionHandler)
            }
            else {
                completionHandler(result)
            }
        }
    }

    private func shouldRetry(request: Request, afterResult result: RequestExecutorResult) -> Bool
    {
        let retry: Bool

        if case .response(let response) = result,
           let requestRetrier = self.requestRetrier
        {
            retry = requestRetrier.should(client: self, retryRequest: request, afterResponse: response)
        }
        else {
            retry = false
        }

        return retry
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
                dispatch(error: InvocationError.applicationError(cause: error))

            case .cancel:
                dispatch(error: InvocationError.canceled)
        }
    }

    fileprivate func dispatch(response: Response)
    {
        switch response.body
        {
            case .success(let successBody):
                dispatchSuccessBody(successBody)

            case .error(let error):
                dispatch(error: InvocationError.rpcError(error: error))
        }
    }

    fileprivate func dispatchSuccessBody(_ body: AnyObject)
    {
        do {
            let result = try self.invocation.parser.parse(body)
            dispatch(result: result)
        }
        catch (let cause)
        {
            let error = InvocationError.applicationError(cause: cause)
            dispatch(error: error)
        }
    }

}

// ----------------------------------------------------------------------------

