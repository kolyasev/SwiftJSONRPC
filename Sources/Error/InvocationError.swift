// ----------------------------------------------------------------------------
//
//  InvocationError.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public enum InvocationError: ErrorType
{
    case ApplicationError(cause: ErrorType)
    case RpcError(error: RPCError)
}

// ----------------------------------------------------------------------------
