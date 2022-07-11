// ----------------------------------------------------------------------------
//
//  Request.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class Request {

    // MARK: - Properties

    public let id: String?

    public let method: String

    public let params: Params?

    // MARK: - Initialization

    init(id: String? = nil, method: String, params: Params?) {
        self.id = id
        self.method = method
        self.params = params
    }

    // MARK: - Functions

    public func buildBody() -> [String: Any] {
        var body: [String: Any] = [
            JsonKeys.JsonRPC: RPCClient.Version,
            JsonKeys.Method: method
        ]

        if let id = id {
            body[JsonKeys.Id] = id
        }
        if let params = params {
            body[JsonKeys.Params] = params
        }

        return body
    }

    // MARK: - Constants

    private struct JsonKeys {
        static let JsonRPC = "jsonrpc"
        static let Method = "method"
        static let Params = "params"
        static let Result = "result"
        static let Error = "error"
        static let Code = "code"
        static let Message = "message"
        static let Data = "data"
        static let Id = "id"
    }

    // MARK: - Inner Types

    public typealias Params = Any

}
