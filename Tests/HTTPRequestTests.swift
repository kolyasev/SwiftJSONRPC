//
//  HTTPRequestTests.swift
//  SwiftJSONRPCTests
//
//  Created by Denis Kolyasev on 10/4/17.
//  Copyright © 2017 Denis Kolyasev. All rights reserved.
//

import XCTest

@testable
import SwiftJSONRPC

final class HTTPRequestTests: XCTestCase {

    // MARK: - Functions

    func testConvertToURLRequest() {
        // Given
        let method = HTTPMethod(rawValue: "GET")!
        let url = URL(string: "http://example.com")!
        let headers = ["Foo": "bar"]
        let body = "test".data(using: .utf8)!

        let request = HTTPRequest(method: method, url: url, headers: headers, body: body)

        // When
        let urlRequest: URLRequest! = request.asURLRequest()

        // Then
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url, url)
        XCTAssertNotNil(urlRequest.allHTTPHeaderFields)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!, ["Foo": "bar"])
        XCTAssertEqual(urlRequest.httpBody, body)
    }
}
