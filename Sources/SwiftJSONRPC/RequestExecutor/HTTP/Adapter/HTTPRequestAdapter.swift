// ----------------------------------------------------------------------------
//
//  HTTPRequestAdapter.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public protocol HTTPRequestAdapter {

    // MARK: - Functions

    func adapt(request: HTTPRequest) throws -> HTTPRequest

}
