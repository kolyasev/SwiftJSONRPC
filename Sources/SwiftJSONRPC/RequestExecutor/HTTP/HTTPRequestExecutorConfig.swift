// ----------------------------------------------------------------------------
//
//  HTTPRequestExecutorConfig.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public struct HTTPRequestExecutorConfig
{
// MARK: - Construction

    public init(
        baseURL: URL,
        throttle: Throttle = .interval(HTTPRequestExecutorConfig.defaultThrottleInterval)
    )
    {
        self.baseURL = baseURL
        self.throttle = throttle
    }

// MARK: - Properties

    public let baseURL: URL

    public let throttle: Throttle

// MARK: - Inner Types

    public enum Throttle
    {
        case disabled
        case interval(DispatchTimeInterval)
    }

// MARK: - Constants

    public static let defaultThrottleInterval: DispatchTimeInterval = .milliseconds(100)

}

// ----------------------------------------------------------------------------
