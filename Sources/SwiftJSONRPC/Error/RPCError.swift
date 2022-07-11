// ----------------------------------------------------------------------------
//
//  RPCError.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public struct RPCError: Error {

    // MARK: - Properties

        public let code: Int

        public let message: String

        public let data: Any?

    // MARK: - Initialization

    init(code: Int, message: String, data: Any?) {
        self.code = code
        self.message = message
        self.data = data
    }
}

extension RPCError {

    // MARK: - Constants

    /// Invalid JSON was received by the server.
    /// An error occurred on the server while parsing the JSON text.
    public static let parseError = RPCError(code: -32700, message: "Parse error", data: nil)

    /// The JSON sent is not a valid Request object.
    public static let invalidRequest = RPCError(code: -32600, message: "Invalid Request", data: nil)

    /// The method does not exist / is not available.
    public static let methodNotFound = RPCError(code: -32601, message: "Method not found", data: nil)

    /// Invalid method parameter(s).
    public static let invalidParams = RPCError(code: -32602, message: "Invalid params", data: nil)

    /// Internal JSON-RPC error.
    public static let internalError = RPCError(code: -32603, message: "Internal error", data: nil)

}
