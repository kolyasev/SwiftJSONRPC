// ----------------------------------------------------------------------------
//
//  CallbackDispatcher.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation
import Atomic

// ----------------------------------------------------------------------------

class CallbackDispatcher<Result>
{
// MARK: - Functions

    func dispatchResult(result: Result)
    {
        self.hasResult.value = result

        for resultBlock in self.resultBlocks {
            dispatch(resultBlock) { $0(r: result) }
        }
    }

    func dispatchError(error: InvocationError)
    {
        self.hasError.value = error

        for errorBlock in self.errorBlocks {
            dispatch(errorBlock) { $0(e: error) }
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

    private func dispatch<B>(holder: CallbackHolder<B>, block: (B) -> Void)
    {
        let dispatchQueue = holder.queue.dispatchQueue()
        dispatch_sync(dispatchQueue) {
            block(holder.block)
        }
    }

// MARK: - Variables: Callbacks

    private var resultBlocks: [CallbackHolder<CallbackDispatcher.ResultBlock>] = []

    private var errorBlocks: [CallbackHolder<CallbackDispatcher.ErrorBlock>] = []

    private var startBlocks: [CallbackHolder<CallbackDispatcher.StartBlock>] = []

    private var finishBlocks: [CallbackHolder<CallbackDispatcher.FinishBlock>] = []

// MARK: - Variables: State

    private let hasStart = Atomic<Bool>(false)

    private let hasFinish = Atomic<Bool>(false)

    private let hasResult = Atomic<Result?>(nil)

    private let hasError = Atomic<InvocationError?>(nil)

}

// ----------------------------------------------------------------------------

extension CallbackDispatcher: ResultProvider
{
// MARK: - Functions

    func result(queue: ResultQueue, block: CallbackDispatcher.ResultBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        if let result = self.hasResult.value
        {
            dispatch(holder) { $0(r: result) }
        }
        else {
            self.resultBlocks.append(holder)
        }

        return self
    }

    func error(queue: ResultQueue, block: CallbackDispatcher.ErrorBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        if let error = self.hasError.value
        {
            dispatch(holder) { $0(e: error) }
        }
        else {
            self.errorBlocks.append(holder)
        }

        return self
    }

    func start(queue: ResultQueue, block: CallbackDispatcher.StartBlock) -> Self
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

    func finish(queue: ResultQueue, block: CallbackDispatcher.FinishBlock) -> Self
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

    private func dispatchQueue() -> dispatch_queue_t
    {
        let result: dispatch_queue_t

        switch self
        {
            case .MainQueue:
                result = dispatch_get_main_queue()

            case .BackgroundQueue:
                result = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

            case .CustomQueue(let queue):
                result = queue
        }

        return result
    }

}

// ----------------------------------------------------------------------------
