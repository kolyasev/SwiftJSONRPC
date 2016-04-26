// ----------------------------------------------------------------------------
//
//  RPCClient.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public class RPCClient
{
// MARK: - Construction

    public init(baseURL: String, headers: [String: String]? = nil)
    {
        let baseURL = NSURL(string: baseURL)!
        let headers = headers ?? [:]

        // Init instance variables
        self.httpClient = HTTPClient(baseURL: baseURL, headers: headers)
        self.httpClient.delegate = self
    }

// MARK: - Properties

    public static var logEnabled: Bool =  false

// MARK: - Public Functions

    public func perform<R>(invocation: Invocation<R>) // TODO: ... -> Cancelable
    {
        weak var weakSelf = self

        // TODO: Support notification type calls without identifiers
        // Generate invocation indentifier
        let identifier = String(++self.invocationSeqNo)

        // ...
        self.invocations[identifier] = invocation

        // Init request
        let request = Request(id: identifier, invocation: invocation)

        // Dispatch start blocks
        invocation.dispatchStart()

        // Perform request
        self.httpClient.performRequest(request)
    }

// MARK: - Private Functions

    private func dispatchResponse(response: Response, forRequest request: Request)
    {
        assert(request.id == response.id)

        let identifier = response.id
        if let invocation = self.invocations.removeValueForKey(identifier)
        {
            // Dispatch response
            switch response.body
            {
                case .Success(let result):
                    invocation.dispatchResult(result)

                case .Error(let error):
                    invocation.dispatchError(InvocationError.RpcError(error: error))
            }

            // Dispatch invocation finish blocks
            invocation.dispatchFinish()
        }
    }

    private func dispatchError(error: ErrorType, forRequest request: Request)
    {
        // TODO: Support notification type calls without identifiers
        if let identifier = request.id,
           let invocation = self.invocations.removeValueForKey(identifier)
        {
            // Dispatch error
            invocation.dispatchError(InvocationError.ApplicationError(cause: error))

            // Dispatch invocation finish blocks
            invocation.dispatchFinish()
        }
    }

// MARK: - Constants

    static let Version = "2.0"

// MARK: - Variables

    private let httpClient: HTTPClient

    private var invocationSeqNo: Int = 0

    private var invocations: [String: InvocationType] = [:]

}

// ----------------------------------------------------------------------------

extension RPCClient: HTTPClientDelegate
{
// MARK: - Functions

    func httpClient(client: HTTPClient, didReceiveResponse response: Response, forRequest request: Request) {
        dispatchResponse(response, forRequest: request)
    }

    func httpClient(client: HTTPClient, didFailWithError error: ErrorType, forRequest request: Request) {
        dispatchError(error, forRequest: request)
    }

}

// ----------------------------------------------------------------------------
