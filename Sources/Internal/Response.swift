// ----------------------------------------------------------------------------
//
//  Response.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class Response
{
// MARK: Construction

    init(result: AnyObject)
    {
        // Init instance variables
        self.result = result
        self.error = nil
    }

    init(error: RPCError)
    {
        // Init instance variables
        self.result = nil
        self.error = error
    }

// MARK: Properties

    let result: AnyObject?

    let error: RPCError?

}

// ----------------------------------------------------------------------------
