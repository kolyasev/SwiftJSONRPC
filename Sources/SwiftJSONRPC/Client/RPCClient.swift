// ----------------------------------------------------------------------------
//
//  RPCClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

open class RPCClient {

    // MARK: - Properties

    public var requestRetrier: RequestRetrier? = nil

    public var coder = Coder()

    // MARK: - Private Properties

    private let requestExecutor: RequestExecutor

    private let requestIdGenerator = RequestIdGenerator()

    // MARK: - Initialization

    public init(requestExecutor: RequestExecutor) {
        self.requestExecutor = requestExecutor
    }

    public convenience init(url: URL) {
        let requestExecutor = HTTPRequestExecutor(url: url)
        self.init(requestExecutor: requestExecutor)
    }

    // MARK: - Public Functions

    open func invoke<Params, Result>(_ invocation: Invocation<Params, Result>) async throws -> Result {
        // Init request
        let request = try makeRequest(invocation: invocation)

        // Perform request
        return try await execute(request: request)
    }

    // MARK: - Private Functions

    private func makeRequest<Params, Result>(invocation: Invocation<Params, Result>) throws -> Request {
        // TODO: Support notification type calls without identifiers
        // Generate request identifier
        let identifier = requestIdGenerator.next()

        // Init request
        return Request(
            id: identifier,
            method: invocation.method,
            params: try coder.encode(invocation.params)
        )
    }

    private func execute<Result: InvocationResult>(request: Request) async throws -> Result {
        return try await withCheckedThrowingContinuation { [coder] continuation in
            execute(request: request) { result in
                do {
                    continuation.resume(returning: try result.result(with: coder))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func execute(request: Request, completionHandler: @escaping (RequestExecutorResult) -> Void) {
        requestExecutor.execute(request: request) { [weak self] result in
            if let self = self,
               self.shouldRetry(request: request, afterResult: result) {
                self.execute(request: request, completionHandler: completionHandler)
            } else {
                completionHandler(result)
            }
        }
    }

    private func shouldRetry(request: Request, afterResult result: RequestExecutorResult) -> Bool {
        let retry: Bool

        if case .response(let response) = result,
           let requestRetrier = self.requestRetrier {
            retry = requestRetrier.should(client: self, retryRequest: request, afterResponse: response)
        } else {
            retry = false
        }

        return retry
    }

    // MARK: - Constants

    static let Version = "2.0"

}

private extension RequestExecutorResult {

    // MARK: - Functions

    func result<Result: InvocationResult>(with coder: Coder) throws -> Result {
        switch self {
        case .response(let response):
            return try result(for: response, with: coder)
        case .error(let error):
            throw InvocationError.applicationError(cause: error)
        case .cancel:
            throw InvocationError.canceled
        }
    }

    // MARK: - Private Functions

    private func result<Result: InvocationResult>(for response: Response, with coder: Coder) throws -> Result {
        switch response.body {
        case .success(let successBody):
            return try resultForSuccessBody(successBody, with: coder)
        case .error(let error):
            throw InvocationError.rpcError(error: error)
        }
    }

    private func resultForSuccessBody<Result: InvocationResult>(_ body: Any, with coder: Coder) throws -> Result {
        do {
            return try coder.decode(Result.self, from: body)
        } catch {
            throw InvocationError.applicationError(cause: error)
        }
    }
}
