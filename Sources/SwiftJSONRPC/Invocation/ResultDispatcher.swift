// ----------------------------------------------------------------------------
//
//  ResultDispatcher.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import PromiseKit

// ----------------------------------------------------------------------------

final class ResultDispatcher<Result>
{
// MARK: - Initialization

    init(invocation: Invocation<Result>)
    {
        self.invocation = invocation
        (self.promise, self.resolver) = Promise<Result>.pending()
    }

// MARK: - Properties

    let invocation: Invocation<Result>

    let promise: Promise<Result>

// MARK: - Functions

    func dispatch(result: Result)
    {
        self.resolver.fulfill(result)
    }

    func dispatch(error: Error)
    {
        self.resolver.reject(error)
    }

// MARK: - Variables

    private let resolver: Resolver<Result>

}

// ----------------------------------------------------------------------------

