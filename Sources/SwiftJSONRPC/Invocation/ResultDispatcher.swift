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

        self.queue.async
        {
            if let result = self.hasResult {
                self.dispatch(holder) { $0(result) }
            }

            self.resultBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func error(_ queue: ResultQueue, block: @escaping ResultDispatcher.ErrorBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        self.queue.async
        {
            if let error = self.hasError {
                self.dispatch(holder) { $0(error) }
            }

            self.errorBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func cancel(_ queue: ResultQueue, block: @escaping ResultDispatcher.CancelBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        self.queue.async
        {
            if self.hasCancel {
                self.dispatch(holder) { $0() }
            }

            self.cancelBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func start(_ queue: ResultQueue, block: @escaping ResultDispatcher.StartBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        self.queue.async
        {
            if self.hasStart {
                self.dispatch(holder) { $0() }
            }

            self.startBlocks.append(holder)
        }

        return self
    }

    @discardableResult
    public override func finish(_ queue: ResultQueue, block: @escaping ResultDispatcher.FinishBlock) -> Self
    {
        let holder = CallbackHolder(block: block, queue: queue)

        self.queue.async
        {
            if self.hasFinish {
                self.dispatch(holder) { $0() }
            }

            self.finishBlocks.append(holder)
        }

        return self
    }

// MARK: - Functions

    func dispatchResult(_ result: R)
    {
        self.queue.async
        {
            self.hasResult = result

            for resultBlock in self.resultBlocks {
                self.dispatch(resultBlock) { $0(result) }
            }
        }
    }

    func dispatchError(_ error: InvocationError)
    {
        self.queue.async
        {
            self.hasError = error

            for errorBlock in self.errorBlocks {
                self.dispatch(errorBlock) { $0(error) }
            }
        }
    }

    func dispatchCancel()
    {
        self.queue.async
        {
            self.hasCancel = true

            for cancelBlock in self.cancelBlocks {
                self.dispatch(cancelBlock) { $0() }
            }
        }
    }

    func dispatchStart()
    {
        self.queue.async
        {
            self.hasStart = true

            for startBlock in self.startBlocks {
                self.dispatch(startBlock) { $0() }
            }
        }
    }

    func dispatchFinish()
    {
        self.queue.async
        {
            self.hasFinish = true

            for finishBlock in self.finishBlocks {
                self.dispatch(finishBlock) { $0() }
            }
        }
    }

// MARK: - Private Functions

    private func dispatch<B>(_ holder: CallbackHolder<B>, block: @escaping (B) -> Void)
    {
        let dispatchQueue = holder.queue.dispatchQueue()
        dispatchQueue.async {
            block(holder.block)
        }
    }

// MARK: - Variables

    private let queue = DispatchQueue(label: "ru.kolyasev.SwiftJSONRPC.ResultDispatcher.queue")

// MARK: - Variables: Callbacks

    private var resultBlocks: [CallbackHolder<ResultDispatcher.ResultBlock>] = []

    private var errorBlocks: [CallbackHolder<ResultDispatcher.ErrorBlock>] = []

    private var cancelBlocks: [CallbackHolder<ResultDispatcher.CancelBlock>] = []

    private var startBlocks: [CallbackHolder<ResultDispatcher.StartBlock>] = []

    private var finishBlocks: [CallbackHolder<ResultDispatcher.FinishBlock>] = []

// MARK: - Variables: State

    private var hasStart: Bool = false

    private var hasFinish: Bool = false

    private var hasResult: R? = nil

    private var hasError: InvocationError? = nil

    private var hasCancel: Bool = false

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
