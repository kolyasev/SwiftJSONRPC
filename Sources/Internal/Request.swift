// ----------------------------------------------------------------------------
//
//  Request.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class Request
{
// MARK: Construction

    init<R>(id: String? = nil, invocation: Invocation<R>)
    {
        // Init instance variables
        self.id = id
        self.method = invocation.method
        self.params = Request.prepareParams(invocation.params)
    }

// MARK: Properties

    let id: String?

    let method: String

    let params: [String: AnyObject]

// MARK: Functions

    func buildBody() -> [String: AnyObject]
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

    fileprivate static func prepareParams(_ params: [String: AnyObject?]) -> [String: AnyObject]
    {
        var result: [String: AnyObject] = [:]

        // Remove 'nil' values
        for (key, value) in params
        {
            if let value = value {
                result[key] = value
            }
        }

        return result
    }

// MARK: Constants

    fileprivate struct JsonKeys
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
