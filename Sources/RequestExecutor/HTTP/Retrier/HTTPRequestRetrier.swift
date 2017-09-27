// ----------------------------------------------------------------------------
//
//  HTTPRequestRetrier.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public protocol HTTPRequestRetrier
{
// MARK: - Functions

    func should(executor: HTTPRequestExecutor, retryRequest request: HTTPRequest, afterError error: HTTPRequestExecutorError) -> Bool

}

// ----------------------------------------------------------------------------
