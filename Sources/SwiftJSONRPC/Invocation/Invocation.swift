// ----------------------------------------------------------------------------
//
//  Invocation.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public struct Invocation<Params, Result> where Params: InvocationParams, Result: InvocationResult {

    // MARK: - Initialization

    init(method: String, params: Params, resultType: Result.Type) {
        self.method = method
        self.params = params
    }

    // MARK: - Properties

    public let method: String

    public let params: Params

}

public typealias InvocationParams = Encodable
public typealias InvocationResult = Decodable

public struct VoidInvocationParams: InvocationParams {}
public struct VoidInvocationResult: InvocationResult {}
