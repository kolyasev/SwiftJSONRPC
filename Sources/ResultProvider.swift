// ----------------------------------------------------------------------------
//
//  ResultProvider.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

// ----------------------------------------------------------------------------

public protocol ResultProvider
{
// MARK: - Functions

    @discardableResult
    func result(_ queue: ResultQueue, block: @escaping ResultBlock) -> Self

    @discardableResult
    func error(_ queue: ResultQueue, block: @escaping ErrorBlock) -> Self

    @discardableResult
    func cancel(_ queue: ResultQueue, block: @escaping CancelBlock) -> Self

    @discardableResult
    func start(_ queue: ResultQueue, block: @escaping StartBlock) -> Self

    @discardableResult
    func finish(_ queue: ResultQueue, block: @escaping FinishBlock) -> Self

// MARK: - Inner Types

    associatedtype ResultType

    typealias ResultBlock = (ResultType) -> Void

    typealias ErrorBlock = (InvocationError) -> Void

    typealias CancelBlock = () -> Void

    typealias StartBlock = () -> Void

    typealias FinishBlock = () -> Void

}

// ----------------------------------------------------------------------------

public enum ResultQueue
{
    case mainQueue
    case backgroundQueue
    case customQueue(queue: DispatchQueue)
}

// ----------------------------------------------------------------------------

extension ResultProvider
{
// MARK: - Functions

    @discardableResult
    public func result(_ block: @escaping ResultBlock) -> Self {
        return result(.backgroundQueue, block: block)
    }

    @discardableResult
    public func error(_ block: @escaping ErrorBlock) -> Self {
        return error(.backgroundQueue, block: block)
    }

    @discardableResult
    public func cancel(_ block: @escaping CancelBlock) -> Self {
        return cancel(.backgroundQueue, block: block)
    }

    @discardableResult
    public func start(_ block: @escaping StartBlock) -> Self {
        return start(.backgroundQueue, block: block)
    }

    @discardableResult
    public func finish(_ block: @escaping FinishBlock) -> Self {
        return finish(.backgroundQueue, block: block)
    }

}

// ----------------------------------------------------------------------------
