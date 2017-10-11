// ----------------------------------------------------------------------------
//
//  RequestExecutor.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public protocol RequestExecutor
{
// MARK: - Functions

    func execute(request: Request, completionHandler: @escaping (RequestExecutorResult) -> Void)

}

// ----------------------------------------------------------------------------

public enum RequestExecutorResult
{
    case response(Response)
    case error(RequestExecutorError)
    case cancel
}

// ----------------------------------------------------------------------------

public protocol RequestExecutorError: Error { }

// ----------------------------------------------------------------------------
