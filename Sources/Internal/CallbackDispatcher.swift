// ----------------------------------------------------------------------------
//
//  CallbackDispatcher.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

class CallbackDispatcher<Result>
{
// MARK: - Functions

    func dispatchResult(result: Result)
    {
        for resultBlock in self.resultBlocks {
            dispatch(resultBlock) { $0(r: result) }
        }
    }

    func dispatchError(error: InvocationError)
    {
        for errorBlock in self.errorBlocks {
            dispatch(errorBlock) { $0(e: error) }
        }
    }


    func dispatchStart()
    {
        for startBlock in self.startBlocks {
            dispatch(startBlock) { $0() }
        }
    }

    func dispatchFinish()
    {
        for finishBlock in self.finishBlocks {
            dispatch(finishBlock) { $0() }
        }
    }

// MARK: - Private Functions

    private func dispatch<B>(holder: CallbackHolder<B>, block: (B) -> Void)
    {
        let dispatchQueue: dispatch_queue_t
        switch holder.queue
        {
        case .MainQueue:
            dispatchQueue = dispatch_get_main_queue()

        case .BackgroundQueue:
            dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

        case .CustomQueue(let queue):
            dispatchQueue = queue
        }

        dispatch_async(dispatchQueue) {
            block(holder.block)
        }
    }

// MARK: - Variables

    private var resultBlocks: [CallbackHolder<CallbackDispatcher.ResultBlock>] = []

    private var errorBlocks: [CallbackHolder<CallbackDispatcher.ErrorBlock>] = []

    private var startBlocks: [CallbackHolder<CallbackDispatcher.StartBlock>] = []

    private var finishBlocks: [CallbackHolder<CallbackDispatcher.FinishBlock>] = []

}

// ----------------------------------------------------------------------------

extension CallbackDispatcher: ResultProvider
{
// MARK: - Functions

    func result(queue: ResultQueue, block: CallbackDispatcher.ResultBlock) -> Self
    {
        self.resultBlocks.append(CallbackHolder(block: block, queue: queue))
        return self
    }

    func error(queue: ResultQueue, block: CallbackDispatcher.ErrorBlock) -> Self
    {
        self.errorBlocks.append(CallbackHolder(block: block, queue: queue))
        return self
    }

    func start(queue: ResultQueue, block: CallbackDispatcher.StartBlock) -> Self
    {
        self.startBlocks.append(CallbackHolder(block: block, queue: queue))
        return self
    }

    func finish(queue: ResultQueue, block: CallbackDispatcher.FinishBlock) -> Self
    {
        self.finishBlocks.append(CallbackHolder(block: block, queue: queue))
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
