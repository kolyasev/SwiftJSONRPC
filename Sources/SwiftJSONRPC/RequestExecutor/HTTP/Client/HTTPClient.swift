// ----------------------------------------------------------------------------
//
//  HTTPClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

protocol HTTPClient
{
// MARK: - Functions

    func perform(request: HTTPRequest, completionHandler: @escaping (PerformRequestResult) -> Void)

// MARK: - Inner Types

    typealias PerformRequestResult = Result<HTTPResponse, HTTPClientError>

}

// ----------------------------------------------------------------------------
