// ----------------------------------------------------------------------------
//
//  InvocationError.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public enum InvocationError: Error
{
    case applicationError(cause: Error)
    case rpcError(error: RPCError)
    case canceled
}

// ----------------------------------------------------------------------------

