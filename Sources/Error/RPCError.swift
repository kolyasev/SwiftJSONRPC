// ----------------------------------------------------------------------------
//
//  RPCError.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class RPCError
{
// MARK: Construction

    init(code: Int, message: String, data: AnyObject?)
    {
        // Init instance variables
        self.code = code
        self.message = message
        self.data = data
    }

// MARK: Properties

    public let code: Int

    public let message: String

    public let data: AnyObject?

}

// ----------------------------------------------------------------------------
