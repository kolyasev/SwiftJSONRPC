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

    public let params: [String: Any]?

    // MARK: - Initialization

    init(id: String? = nil, method: String, params: [String: Any?]?) {
        self.id = id
        self.method = method
        self.params = params.map { Request.prepareParams($0) }
    }

    // MARK: - Functions

    public func buildBody() -> [String: AnyObject] {
        var body: [String: AnyObject] = [
            JsonKeys.JsonRPC: RPCClient.Version as AnyObject,
            JsonKeys.Method: method as AnyObject,
            JsonKeys.Params: params as AnyObject,
        ]

        if let id = id {
            body[JsonKeys.Id] = id as AnyObject?
        }
        
        return body
    }

    // MARK: - Private Functions

    private static func prepareParams(_ params: [String: Any?]?) -> [String: Any] {
        var result: [String: Any] = [:]

        // Remove 'nil' values
        for (key, value) in params ?? [:]
        {
            if let value = value {
                result[key] = value
            }
        }

        return result
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
}
