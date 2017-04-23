// ----------------------------------------------------------------------------
//
//  HTTPClientError.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

// ----------------------------------------------------------------------------

struct HTTPClientError: Error
{
// MARK: - Construction

    // ...

// MARK: - Properties

    let cause: Error

    let request: URLRequest?

    let response: HTTPURLResponse?

// MARK: - Functions

    // ...

// MARK: - Actions

    // ...

// MARK: - Private Functions

    // ...

// MARK: - Inner Types

    // ...

// MARK: - Constants

    // ...

// MARK: - Variables

    // ...

}

// ----------------------------------------------------------------------------
