// ----------------------------------------------------------------------------
//
//  RequestManager.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

open class RequestManager
{
// MARK: - Properties

    weak var delegate: RequestManagerDelegate?

// MARK: - Functions

    func performRequest(_ request: Request) {
        fatalError("Abstract method")
    }

}

// ----------------------------------------------------------------------------

protocol RequestManagerDelegate: class
{
// MARK: - Functions

    func requestManager(_ requestManager: RequestManager, didReceiveResponse response: Response, forRequest request: Request)

    func requestManager(_ requestManager: RequestManager, didFailWithError error: Error, forRequest request: Request)

    func requestManager(_ requestManager: RequestManager, didCancelRequest request: Request)

}

// ----------------------------------------------------------------------------
