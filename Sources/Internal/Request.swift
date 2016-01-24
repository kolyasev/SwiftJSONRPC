// ----------------------------------------------------------------------------
//
//  Request.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Alamofire
import SwiftyJSON

// ----------------------------------------------------------------------------

class Request
{
// MARK: Construction

    init(method: String, params: [String: AnyObject], id: String? = nil)
    {
        // Init instance variables
        self.method = method
        self.params = params
        self.id = id
    }

// MARK: Properties

    let method: String

    let params: [String: AnyObject]

    let id: String?

// MARK: Functions

    func perform(baseUrl: String, completionBlock: CompletionBlock)
    {
        // Build json-rpc body params
        let body = buildBody()

        // Log request
        if RPC.logEnabled {
            NSLog("Request: '%@'", body)
        }

        // Perform request
        Alamofire.request(.POST, baseUrl, parameters: body, encoding: .JSON)
            .responseJSON { response in
                dispatch.async.bg
                {
                    switch response.result
                    {
                        case .Success(let json):
                            // Log response
                            if RPC.logEnabled {
                                NSLog("Response: '%@'", json.description)
                            }

                            // Handle 'result' object if exists
                            if let optionalResult = json[JsonKeys.Result],
                               let result = optionalResult
                            {
                                // Init response with result
                                let response = Response(result: result)

                                // Complete perform request with response
                                completionBlock(.Success(response))
                            }
                            else
                            // Handle 'error' object if exists
                            if let error   = json[JsonKeys.Error] as? [String: AnyObject],
                               let code    = error[JsonKeys.Code] as? Int,
                               let message = error[JsonKeys.Message] as? String
                            {
                                let data = error[JsonKeys.Data]

                                // Init JSON-RPC error
                                let rpcError = RPCError(code: code, message: message, data: data)

                                // Init response with error
                                let response = Response(error: rpcError)

                                // Complete perform request with response
                                completionBlock(.Success(response))
                            }
                            // Handle JSON-RPC format error
                            else {
                                let error = RequestError.InvalidResponseFormat(response: json)
                                completionBlock(.Failure(error as NSError))
                            }

                        case .Failure(let error):
                            // Complete perform request with error
                            completionBlock(.Failure(error))
                    }
                }
            }
    }

// MARK: Private Functions

    private func buildBody() -> [String: AnyObject]
    {
        var body: [String: AnyObject] =
        [
            JsonKeys.JsonRPC: Request.Version,
            JsonKeys.Method: self.method,
            JsonKeys.Params: self.params,
        ]

        if let id = self.id {
            body[JsonKeys.Id] = id
        }

        return body
    }

// MARK: Inner Types

    typealias CompletionBlock = (Result<Response, NSError>) -> Void

// MARK: Constants

    static let Version = "2.0"

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

enum RequestError: ErrorType
{
    case InvalidResponseFormat(response: AnyObject)
}

// ----------------------------------------------------------------------------
