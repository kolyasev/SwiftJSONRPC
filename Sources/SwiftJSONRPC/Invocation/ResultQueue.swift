// ----------------------------------------------------------------------------
//
//  ResultQueue.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

// ----------------------------------------------------------------------------

public enum ResultQueue
{
    case main
    case background
    case custom(queue: DispatchQueue)
}

// ----------------------------------------------------------------------------

extension ResultQueue
{
// MARK: - Functions

    func dispatchQueue() -> DispatchQueue
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
