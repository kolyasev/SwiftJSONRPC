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

    open func invoke<Params>(_ method: String, params: Params) async throws where Params: InvocationParams {
        _ = try await invoke(method, params: params) as VoidInvocationResult
    }

    open func invoke<Params, Result>(_ method: String, params: Params) async throws -> Result
    where Params: InvocationParams, Result: InvocationResult {

        // Init invocation object
        let invocation = makeInvocation(method: method, params: params, resultType: Result.self)

        // Perform invocation
        return try await client.invoke(invocation)
    }

    // MARK: - Private Functions

    private func makeInvocation<Params, Result>(method: String, params: Params, resultType: Result.Type) -> Invocation<Params, Result> {
        return Invocation(method: method, params: params, resultType: resultType)
    }
}
