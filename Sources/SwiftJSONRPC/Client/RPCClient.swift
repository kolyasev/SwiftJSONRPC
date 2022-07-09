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

    open func invoke<Result>(_ invocation: Invocation<Result>) async throws -> Result {
        // Init request
        let request = makeRequest(invocation: invocation)

        // Perform request
        return try await execute(request: request, with: invocation.parser)
    }

    // MARK: - Private Functions

    private func makeRequest<Result>(invocation: Invocation<Result>) -> Request {
        // TODO: Support notification type calls without identifiers
        // Generate request identifier
        let identifier = requestIdGenerator.next()

        // Init request
        return Request(
            id: identifier,
            method: invocation.method,
            params: invocation.params
        )
    }

    private func execute<Result>(request: Request, with parser: AnyResultParser<Result>) async throws -> Result {
        return try await withCheckedThrowingContinuation { continuation in
            execute(request: request) { result in
                do {
                    continuation.resume(returning: try result.result(with: parser))
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

    func result<Result>(with parser: AnyResultParser<Result>) throws -> Result {
        switch self {
        case .response(let response):
            return try result(for: response, with: parser)
        case .error(let error):
            throw InvocationError.applicationError(cause: error)
        case .cancel:
            throw InvocationError.canceled
        }
    }

    // MARK: - Private Functions

    private func result<Result>(for response: Response, with parser: AnyResultParser<Result>) throws -> Result {
        switch response.body {
        case .success(let successBody):
            return try resultForSuccessBody(successBody, with: parser)
        case .error(let error):
            throw InvocationError.rpcError(error: error)
        }
    }

    private func resultForSuccessBody<Result>(_ body: AnyObject, with parser: AnyResultParser<Result>) throws -> Result {
        do {
            return try parser.parse(body)
        } catch {
            throw InvocationError.applicationError(cause: error)
        }
    }
}
