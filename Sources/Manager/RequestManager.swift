// ----------------------------------------------------------------------------
//
//  RequestManager.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class RequestManager
{
// MARK: - Properties

    weak var delegate: RequestManagerDelegate?

// MARK: - Functions

    func performRequest(request: Request) {
        fatalError("Abstract method")
    }
}

// ----------------------------------------------------------------------------

protocol RequestManagerDelegate: class
{
// MARK: - Functions

    func requestManager(requestManager: RequestManager, didReceiveResponse response: Response, forRequest request: Request)

    func requestManager(requestManager: RequestManager, didFailWithError error: ErrorType, forRequest request: Request)

}

// ----------------------------------------------------------------------------
