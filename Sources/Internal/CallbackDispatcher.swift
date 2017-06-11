// ----------------------------------------------------------------------------
//
//  CallbackDispatcher.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation
// import Atomic

// ----------------------------------------------------------------------------

class CallbackDispatcher<Result>
{
// MARK: - Functions

    func dispatchResult(_ result: Result)
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

    fileprivate var resultBlocks: [CallbackHolder<CallbackDispatcher.ResultBlock>] = []

    fileprivate var errorBlocks: [CallbackHolder<CallbackDispatcher.ErrorBlock>] = []

    fileprivate var cancelBlocks: [CallbackHolder<CallbackDispatcher.CancelBlock>] = []

    fileprivate var startBlocks: [CallbackHolder<CallbackDispatcher.StartBlock>] = []

    fileprivate var finishBlocks: [CallbackHolder<CallbackDispatcher.FinishBlock>] = []

// MARK: - Variables: State

    fileprivate let hasStart = Atomic<Bool>(false)

    fileprivate let hasFinish = Atomic<Bool>(false)

    fileprivate let hasResult = Atomic<Result?>(nil)

    fileprivate let hasError = Atomic<InvocationError?>(nil)

    fileprivate let hasCancel = Atomic<Bool>(false)

}

// ----------------------------------------------------------------------------

extension CallbackDispatcher: ResultProvider
{
// MARK: - Functions

    @discardableResult
    func result(_ queue: ResultQueue, block: @escaping CallbackDispatcher.ResultBlock) -> Self
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
    func error(_ queue: ResultQueue, block: @escaping CallbackDispatcher.ErrorBlock) -> Self
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
    func cancel(_ queue: ResultQueue, block: @escaping CallbackDispatcher.CancelBlock) -> Self
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
    func start(_ queue: ResultQueue, block: @escaping CallbackDispatcher.StartBlock) -> Self
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
    func finish(_ queue: ResultQueue, block: @escaping CallbackDispatcher.FinishBlock) -> Self
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

// MARK: - Inner Types

    typealias ResultType = Result

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
            case .mainQueue:
                result = DispatchQueue.main

            case .backgroundQueue:
                result = DispatchQueue.global()

            case .customQueue(let queue):
                result = queue
        }

        return result
    }

}

// ----------------------------------------------------------------------------
