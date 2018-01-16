//
//  HTTPClientTests.swift
//  SwiftJSONRPCTests
//
//  Created by Denis Kolyasev on 10/4/17.
//  Copyright © 2017 Denis Kolyasev. All rights reserved.
//

import XCTest

@testable
import SwiftJSONRPC

class HTTPClientTests: XCTestCase
{
    var httpClient: HTTPClient!
    
    override func setUp() {
        super.setUp()

        self.httpClient = AlamofireHTTPClient()
    }

    func testHasResponse()
    {
        // Given
        let method = HTTPMethod(rawValue: "GET")!
        let url = URL(string: "https://httpbin.org/get")!

        let request = HTTPRequest(method: method, url: url, headers: [:], body: Data())

        let expectation = self.expectation(description: "Request should succeed.")
        var response: HTTPResponse!

        // When
        self.httpClient.perform(request: request) { result in
            switch result
            {
                case .success(let resp):
                    response = resp
                    expectation.fulfill()

                case .error(let error):
                    XCTFail("Request failed with error: \(error).")
            }
        }

        wait(for: [expectation], timeout: 10.0)

        // Then
        XCTAssertNotNil(response)
    }

    func testResponseStatusCode()
    {
        // Given
        let method = HTTPMethod(rawValue: "GET")!
        let url = URL(string: "https://httpbin.org/status/401")!

        let request = HTTPRequest(method: method, url: url, headers: [:], body: Data())

        let expectation = self.expectation(description: "Request should succeed.")
        var response: HTTPResponse!

        // When
        self.httpClient.perform(request: request) { result in
            switch result
            {
            case .success(let resp):
                response = resp
                expectation.fulfill()

            case .error(let error):
                XCTFail("Request failed with error: \(error).")
            }
        }

        wait(for: [expectation], timeout: 10.0)

        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response.code, 401)
    }

    func testResponseHeaders()
    {
        // Given
        let method = HTTPMethod(rawValue: "GET")!
        let url = URL(string: "https://httpbin.org/response-headers?Foo=bar&Baz=bat")!

        let request = HTTPRequest(method: method, url: url, headers: [:], body: Data())

        let expectation = self.expectation(description: "Request should succeed.")
        var response: HTTPResponse!

        // When
        self.httpClient.perform(request: request) { result in
            switch result
            {
            case .success(let resp):
                response = resp
                expectation.fulfill()

            case .error(let error):
                XCTFail("Request failed with error: \(error).")
            }
        }

        wait(for: [expectation], timeout: 10.0)

        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response.headers["Foo"], "bar")
        XCTAssertEqual(response.headers["Baz"], "bat")
    }

    func testResponseBody()
    {
        // Given
        let method = HTTPMethod(rawValue: "GET")!
        let url = URL(string: "https://httpbin.org//bytes/100")!

        let request = HTTPRequest(method: method, url: url, headers: [:], body: Data())

        let expectation = self.expectation(description: "Request should succeed.")
        var response: HTTPResponse!

        // When
        self.httpClient.perform(request: request) { result in
            switch result
            {
            case .success(let resp):
                response = resp
                expectation.fulfill()

            case .error(let error):
                XCTFail("Request failed with error: \(error).")
            }
        }

        wait(for: [expectation], timeout: 10.0)

        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response.body.count, 100)
    }

}
