// ----------------------------------------------------------------------------
//
//  RequestRetrier.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public protocol RequestRetrier
{
// MARK: - Functions

    func should(client: RPCClient, retryRequest request: Request, afterResponse response: Response) -> Bool

}

// ----------------------------------------------------------------------------
