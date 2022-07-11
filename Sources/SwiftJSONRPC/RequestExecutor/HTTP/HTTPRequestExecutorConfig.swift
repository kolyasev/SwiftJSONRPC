// ----------------------------------------------------------------------------
//
//  HTTPRequestExecutorConfig.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

import Foundation

public struct HTTPRequestExecutorConfig {

    // MARK: - Properties

    public let baseURL: URL

    public let throttle: Throttle

    public let maxBatchCount: Int

    // MARK: - Initialization

    public init(
        baseURL: URL,
        throttle: Throttle = .interval(HTTPRequestExecutorConfig.defaultThrottleInterval),
        maxBatchCount: Int = HTTPRequestExecutorConfig.defaultMaxBatchCount
    ) {
        guard maxBatchCount > 0 else {
            fatalError("`HTTPRequestExecutorConfig.maxBatchCount` must be greater than zero.")
        }

        self.baseURL = baseURL
        self.throttle = throttle
        self.maxBatchCount = maxBatchCount
    }

    // MARK: - Inner Types

    public enum Throttle {
        case disabled
        case interval(DispatchTimeInterval)
    }

    // MARK: - Constants

    public static let defaultThrottleInterval: DispatchTimeInterval = .milliseconds(100)

    public static let defaultMaxBatchCount: Int = 10

}
