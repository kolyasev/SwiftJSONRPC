// ----------------------------------------------------------------------------
//
//  RPCError.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class RPCError
{
// MARK: Construction

    init(code: Int, message: String, data: Any?)
    {
        // Init instance variables
        self.code = code
        self.message = message
        self.data = data
    }

// MARK: Properties

    open let code: Int

    open let message: String

    open let data: Any?

}

// ----------------------------------------------------------------------------
