//
//  ResultDispatcherTests.swift
//  SwiftJSONRPCTests
//
//  Created by Denis Kolyasev on 10/5/17.
//  Copyright © 2017 Denis Kolyasev. All rights reserved.
//

import XCTest

@testable
import SwiftJSONRPC

class ResultDispatcherTests: XCTestCase
{
    var resultDispatcher: ResultDispatcher<String>!
        
    override func setUp() {
        super.setUp()

        let invocation = Invocation<String>(method: "test", params: [:], parser: JsonPrimitiveResultParser())
        self.resultDispatcher = ResultDispatcher(invocation: invocation)
    }

    func testResultCallback()
    {
        // Given
        let message = "Hello world!"

        let expectation = self.expectation(description: "Dispatcher should call callback.")
        var result: String!

        // When
        self.resultDispatcher.result { res in
            result = res
            expectation.fulfill()
        }

        self.resultDispatcher.dispatchResult(message)

        wait(for: [expectation], timeout: 0.1)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, message)
    }

    func testResultCallbackAsync()
    {
        // Given
        let message = "Hello world!"

        let expectation = self.expectation(description: "Dispatcher should call callback.")
        var result: String!

        // When
        DispatchQueue.global().async {
            self.resultDispatcher.result { res in
                result = res
                expectation.fulfill()
            }
        }

        DispatchQueue.global().async {
            self.resultDispatcher.dispatchResult(message)
        }

        wait(for: [expectation], timeout: 0.1)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, message)
    }

    func testResultCallbackDispatchFirst()
    {
        // Given
        let message = "Hello world!"

        let expectation = self.expectation(description: "Dispatcher should call callback.")
        var result: String!

        // When
        self.resultDispatcher.dispatchResult(message)

        self.resultDispatcher.result { res in
            result = res
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, message)
    }

    func testResultCallbackDispatchFirstAsync()
    {
        // Given
        let message = "Hello world!"

        let expectation = self.expectation(description: "Dispatcher should call callback.")
        var result: String!

        // When
        DispatchQueue.global().async {
            self.resultDispatcher.dispatchResult(message)
        }

        DispatchQueue.global().async {
            self.resultDispatcher.result { res in
                result = res
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.1)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, message)
    }
    
}
