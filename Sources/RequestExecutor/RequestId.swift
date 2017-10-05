// ----------------------------------------------------------------------------
//
//  Request.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

// import Atomic

// ----------------------------------------------------------------------------

public typealias RequestId = String

// ----------------------------------------------------------------------------

class RequestIdGenerator
{
// MARK: - Functions

    func next() -> RequestId {
        return RequestId(self.lastIdx.modify{ $0 + 1 })
    }

// MARK: - Variables

    private let lastIdx = Atomic<Int>(1)

}

// ----------------------------------------------------------------------------

