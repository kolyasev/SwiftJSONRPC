// ----------------------------------------------------------------------------
//
//  ResultProvider.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

// ----------------------------------------------------------------------------

public class ResultProvider<R>
{
// MARK: - Functions

    @discardableResult
    public func result(_ queue: ResultQueue, block: @escaping ResultBlock) -> Self {
        fatalError("Not implemented.")
    }

    @discardableResult
    public func error(_ queue: ResultQueue, block: @escaping ErrorBlock) -> Self {
        fatalError("Not implemented.")
    }

    @discardableResult
    public func cancel(_ queue: ResultQueue, block: @escaping CancelBlock) -> Self {
        fatalError("Not implemented.")
    }

    @discardableResult
    public func start(_ queue: ResultQueue, block: @escaping StartBlock) -> Self {
        fatalError("Not implemented.")
    }

    @discardableResult
    public func finish(_ queue: ResultQueue, block: @escaping FinishBlock) -> Self {
        fatalError("Not implemented.")
    }

// MARK: - Inner Types

    public typealias Result = R

    public typealias ResultBlock = (Result) -> Void

    public typealias ErrorBlock = (InvocationError) -> Void

    public typealias CancelBlock = () -> Void

    public typealias StartBlock = () -> Void

    public typealias FinishBlock = () -> Void

}

// ----------------------------------------------------------------------------

public enum ResultQueue
{
    case main
    case background
    case custom(queue: DispatchQueue)
}

// ----------------------------------------------------------------------------

extension ResultProvider
{
// MARK: - Functions

    @discardableResult
    public func result(_ block: @escaping ResultBlock) -> Self {
        return result(.background, block: block)
    }

    @discardableResult
    public func error(_ block: @escaping ErrorBlock) -> Self {
        return error(.background, block: block)
    }

    @discardableResult
    public func cancel(_ block: @escaping CancelBlock) -> Self {
        return cancel(.background, block: block)
    }

    @discardableResult
    public func start(_ block: @escaping StartBlock) -> Self {
        return start(.background, block: block)
    }

    @discardableResult
    public func finish(_ block: @escaping FinishBlock) -> Self {
        return finish(.background, block: block)
    }

}

// ----------------------------------------------------------------------------
