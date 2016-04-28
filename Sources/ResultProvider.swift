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

    func result(queue: ResultQueue, block: ResultBlock) -> Self

    func error(queue: ResultQueue, block: ErrorBlock) -> Self

    func start(queue: ResultQueue, block: StartBlock) -> Self

    func finish(queue: ResultQueue, block: FinishBlock) -> Self

// MARK: - Inner Types

    associatedtype ResultType

    associatedtype ResultBlock = (r: ResultType) -> Void

    associatedtype ErrorBlock = (e: InvocationError) -> Void

    associatedtype StartBlock = () -> Void

    associatedtype FinishBlock = () -> Void

}

// ----------------------------------------------------------------------------

public enum ResultQueue
{
    case MainQueue
    case BackgroundQueue
    case CustomQueue(queue: dispatch_queue_t)
}

// ----------------------------------------------------------------------------

extension ResultProvider
{
// MARK: - Functions

    public func result(block: ResultBlock) -> Self {
        return result(.BackgroundQueue, block: block)
    }

    public func error(block: ErrorBlock) -> Self {
        return error(.BackgroundQueue, block: block)
    }

    public func start(block: StartBlock) -> Self {
        return start(.BackgroundQueue, block: block)
    }

    public func finish(block: FinishBlock) -> Self {
        return finish(.BackgroundQueue, block: block)
    }

}

// ----------------------------------------------------------------------------
