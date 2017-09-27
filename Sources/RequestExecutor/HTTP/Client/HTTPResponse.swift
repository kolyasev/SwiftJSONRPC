// ----------------------------------------------------------------------------
//
//  HTTPResponse.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public struct HTTPResponse
{
// MARK: - Properties

    public var url: URL

    public var code: Int

    public var headers: [String: String]

    public var body: Data

}

// ----------------------------------------------------------------------------
