// ----------------------------------------------------------------------------
//
//  ResultDispatcher.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation
// import Atomic

// ----------------------------------------------------------------------------

public final class ResultDispatcher<R>: ResultProvider<R>
{
// MARK: - Constructions

    init(invocation: Invocation<R>) {
        self.invocation = invocation
    }

// MARK: - Properties

    let invocation: Invocation<R>

// MARK: - Public Functions

    @discardableResult
    public override func result(_ queue: ResultQueue, block: @escaping ResultDispatcher.ResultBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        if let result = self.hasResult.value
        {
            dispatch(holder) { $0(result) }
        }
        else {
            self.resultBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func error(_ queue: ResultQueue, block: @escaping ResultDispatcher.ErrorBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        if let error = self.hasError.value
        {
            dispatch(holder) { $0(error) }
        }
        else {
            self.errorBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func cancel(_ queue: ResultQueue, block: @escaping ResultDispatcher.CancelBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        if self.hasCancel.value
        {
            dispatch(holder) { $0() }
        }
        else {
            self.cancelBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func start(_ queue: ResultQueue, block: @escaping ResultDispatcher.StartBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        if self.hasStart.value
        {
            dispatch(holder) { $0() }
        }
        else {
            self.startBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func finish(_ queue: ResultQueue, block: @escaping ResultDispatcher.FinishBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        if self.hasFinish.value
        {
            dispatch(holder) { $0() }
        }
        else {
            self.finishBlocks.append(holder)
        }

        return self
    }

// MARK: - Functions

    func dispatchResult(_ result: R)
    {
        self.hasResult.value = result

        for resultBlock in self.resultBlocks {
            dispatch(resultBlock) { $0(result) }
        }
    }

    func dispatchError(_ error: InvocationError)
    {
        self.hasError.value = error

        for errorBlock in self.errorBlocks {
            dispatch(errorBlock) { $0(error) }
        }
    }

    func dispatchCancel()
    {
        self.hasCancel.value = true

        for cancelBlock in self.cancelBlocks {
            dispatch(cancelBlock) { $0() }
        }
    }

    func dispatchStart()
    {
        self.hasStart.value = true

        for startBlock in self.startBlocks {
            dispatch(startBlock) { $0() }
        }
    }

    func dispatchFinish()
    {
        self.hasFinish.value = true

        for finishBlock in self.finishBlocks {
            dispatch(finishBlock) { $0() }
        }
    }

// MARK: - Private Functions

    fileprivate func dispatch<B>(_ holder: CallbackHolder<B>, block: (B) -> Void)
    {
        let dispatchQueue = holder.queue.dispatchQueue()
        dispatchQueue.sync {
            block(holder.block)
        }
    }

// MARK: - Variables: Callbacks

    fileprivate var resultBlocks: [CallbackHolder<ResultDispatcher.ResultBlock>] = []

    fileprivate var errorBlocks: [CallbackHolder<ResultDispatcher.ErrorBlock>] = []

    fileprivate var cancelBlocks: [CallbackHolder<ResultDispatcher.CancelBlock>] = []

    fileprivate var startBlocks: [CallbackHolder<ResultDispatcher.StartBlock>] = []

    fileprivate var finishBlocks: [CallbackHolder<ResultDispatcher.FinishBlock>] = []

// MARK: - Variables: State

    fileprivate let hasStart = Atomic<Bool>(false)

    fileprivate let hasFinish = Atomic<Bool>(false)

    fileprivate let hasResult = Atomic<R?>(nil)

    fileprivate let hasError = Atomic<InvocationError?>(nil)

    fileprivate let hasCancel = Atomic<Bool>(false)

}

// ----------------------------------------------------------------------------

private struct CallbackHolder<Block>
{
// MARK: - Properties

    let block: Block

    let queue: ResultQueue

}

// ----------------------------------------------------------------------------

extension ResultQueue
{
// MARK: - Functions

    fileprivate func dispatchQueue() -> DispatchQueue
    {
        let result: DispatchQueue

        switch self
        {
            case .main:
                result = DispatchQueue.main

            case .background:
                result = DispatchQueue.global()

            case .custom(let queue):
                result = queue
        }

        return result
    }

}

// ----------------------------------------------------------------------------
