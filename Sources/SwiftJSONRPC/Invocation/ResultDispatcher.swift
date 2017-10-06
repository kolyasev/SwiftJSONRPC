// ----------------------------------------------------------------------------
//
//  ResultDispatcher.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

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

    override func on(event: CallbackEvent<R>.Simple, queue: ResultQueue, block: @escaping CallbackEventBlock)
    {
        self.queue.async
        {
            let callbackHolder = CallbackHolder(event: event, queue: queue, block: block)

            if let event = self.events[event]
            {
                self.dispatch(event: event, toCallbackHolder: callbackHolder)
            }
            else {
                var callbacks = self.callbackHolders[event] ?? []
                callbacks.append(callbackHolder)
                self.callbackHolders[event] = callbacks
            }
        }
    }

// MARK: - Functions

    func dispatchResult(_ result: R)
    {
        dispatch(event: .result(result))
    }

    func dispatchError(_ error: InvocationError)
    {
        dispatch(event: .error(error))
    }

    func dispatchCancel()
    {
        dispatch(event: .cancel)
    }

    func dispatchStart()
    {
        dispatch(event: .start)
    }

    func dispatchFinish()
    {
        dispatch(event: .finish)
    }

// MARK: - Private Functions

    private func dispatch(event: CallbackEvent<R>)
    {
        self.queue.async
        {
            let inserted = (self.events.updateValue(event, forKey: event.simple) == nil)
            if  inserted
            {
                if let holders = self.callbackHolders.removeValue(forKey: event.simple)
                {
                    for holder in holders {
                        self.dispatch(event: event, toCallbackHolder: holder)
                    }
                }
            }
        }
    }

    private func dispatch(event: CallbackEvent<R>, toCallbackHolder callbackHolder: CallbackHolder)
    {
        let dispatchQueue = callbackHolder.queue.dispatchQueue()
        dispatchQueue.async {
            callbackHolder.block(event)
        }
    }

// MARK: - Inner Types

    private struct CallbackHolder
    {
        let event: CallbackEvent<R>.Simple
        let queue: ResultQueue
        let block: CallbackEventBlock
    }

// MARK: - Variables

    private let queue = DispatchQueue(label: "ru.kolyasev.SwiftJSONRPC.ResultDispatcher.queue")

    private var events: [CallbackEvent<R>.Simple: CallbackEvent<R>] = [:]

    private var callbackHolders: [CallbackEvent<R>.Simple: [CallbackHolder]] = [:]

}

// ----------------------------------------------------------------------------

