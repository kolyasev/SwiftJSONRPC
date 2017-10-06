// ----------------------------------------------------------------------------
//
//  ResultProvider.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class ResultProvider<R>
{
// MARK: - Functions

    func on(event: CallbackEvent<R>.Simple, queue: ResultQueue, block: @escaping CallbackEventBlock) {
        fatalError("Not implemented.")
    }

// MARK: - Inner Types

    public typealias Result = R

    public typealias CallbackEventBlock = (CallbackEvent<R>) -> Void

}

// ----------------------------------------------------------------------------

extension ResultProvider
{
// MARK: - Functions

    @discardableResult
    public func result(queue: ResultQueue, block: @escaping ResultBlock) -> Self
    {
        on(event: .result, queue: queue) { event in
            if case .result(let value) = event {
                block(value)
            }
        }

        return self
    }

    @discardableResult
    public func error(queue: ResultQueue, block: @escaping ErrorBlock) -> Self
    {
        on(event: .error, queue: queue) { event in
            if case .error(let value) = event {
                block(value)
            }
        }

        return self
    }

    @discardableResult
    public func cancel(queue: ResultQueue, block: @escaping CancelBlock) -> Self
    {
        on(event: .cancel, queue: queue) { event in
            if case .cancel = event {
                block()
            }
        }

        return self
    }

    @discardableResult
    public func start(queue: ResultQueue, block: @escaping StartBlock) -> Self
    {
        on(event: .start, queue: queue) { event in
            if case .start = event {
                block()
            }
        }

        return self
    }

    @discardableResult
    public func finish(queue: ResultQueue, block: @escaping FinishBlock) -> Self
    {
        on(event: .finish, queue: queue) { event in
            if case .finish = event {
                block()
            }
        }

        return self
    }

// MARK: - Inner Types

    public typealias ResultBlock = (Result) -> Void

    public typealias ErrorBlock = (InvocationError) -> Void

    public typealias CancelBlock = () -> Void

    public typealias StartBlock = () -> Void

    public typealias FinishBlock = () -> Void

}

// ----------------------------------------------------------------------------

extension ResultProvider
{
// MARK: - Functions

    @discardableResult
    public func result(_ block: @escaping ResultBlock) -> Self {
        return result(queue: .background, block: block)
    }

    @discardableResult
    public func error(_ block: @escaping ErrorBlock) -> Self {
        return error(queue: .background, block: block)
    }

    @discardableResult
    public func cancel(_ block: @escaping CancelBlock) -> Self {
        return cancel(queue: .background, block: block)
    }

    @discardableResult
    public func start(_ block: @escaping StartBlock) -> Self {
        return start(queue: .background, block: block)
    }

    @discardableResult
    public func finish(_ block: @escaping FinishBlock) -> Self {
        return finish(queue: .background, block: block)
    }

}

// ----------------------------------------------------------------------------
