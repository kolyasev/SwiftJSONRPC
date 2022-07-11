// ----------------------------------------------------------------------------
//
//  HTTPResponseAdapter.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public protocol HTTPResponseAdapter {

    // MARK: - Functions

    func adapt(response: HTTPResponse, forRequest request: HTTPRequest) throws -> HTTPResponse

}
