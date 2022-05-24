// ----------------------------------------------------------------------------
//
//  Request.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class Request
{
// MARK: Construction

    init<R>(id: String? = nil, invocation: Invocation<R>)
    {
        // Init instance variables
        self.id = id
        self.method = invocation.method
        self.params = invocation.params != nil ? Request.prepareParams(invocation.params!) : nil

    }

// MARK: Properties

    public let id: String?

    public let method: String

    public let params: [Any]?

// MARK: Functions

    public func buildBody() -> [String: AnyObject]
    {
        var body: [String: AnyObject] = [
            JsonKeys.JsonRPC: RPCClient.Version as AnyObject,
            JsonKeys.Method: self.method as AnyObject,
            JsonKeys.Params: self.params as AnyObject,
        ]

        if let id = self.id {
            body[JsonKeys.Id] = id as AnyObject?
        }

        return body
    }

// MARK: Private Functions

    private static func prepareParams(_ params: [Any]) -> [Any]
    {
        return params
    }

// MARK: Constants

    private struct JsonKeys
    {
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

// ----------------------------------------------------------------------------
