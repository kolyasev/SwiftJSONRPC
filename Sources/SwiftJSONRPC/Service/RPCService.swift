// ----------------------------------------------------------------------------
//
//  RPCService.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class RPCService {

    // MARK: - Private Properties

    private let client: RPCClient

    // MARK: - Initialization

    public init(client: RPCClient) {
        self.client = client
    }

    // MARK: - Public Functions

    open func invoke(_ method: String) async throws {
        _ = try await invoke(method, params: VoidInvocationParams()) as VoidInvocationResult
    }

    open func invoke<Result>(_ method: String) async throws -> Result where Result: InvocationResult {
        return try await invoke(method, params: VoidInvocationParams())
    }

    open func invoke<Params>(_ method: String, params: Params?) async throws where Params: InvocationParams {
        _ = try await invoke(method, params: params) as VoidInvocationResult
    }

    open func invoke<Params, Result>(_ method: String, params: Params?) async throws -> Result
    where Params: InvocationParams, Result: InvocationResult {

        // Init invocation object
        let invocation = Invocation(method: method, params: params, resultType: Result.self)

        // Perform invocation
        return try await client.invoke(invocation)
    }
}
