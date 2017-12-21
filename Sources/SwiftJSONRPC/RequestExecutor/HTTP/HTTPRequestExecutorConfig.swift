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
        throttleInterval: DispatchTimeInterval = HTTPRequestExecutorConfig.defaultThrottleInterval
    )
    {
        self.baseURL = baseURL
        self.throttleInterval = throttleInterval
    }

// MARK: - Properties

    public let baseURL: URL

    public let throttleInterval: DispatchTimeInterval

// MARK: - Constants

    public static let defaultThrottleInterval: DispatchTimeInterval = .milliseconds(100)

}

// ----------------------------------------------------------------------------
