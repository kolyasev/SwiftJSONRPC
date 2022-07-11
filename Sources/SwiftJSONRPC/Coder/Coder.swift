//
//  Coder.swift
//  
//
//  Created by Denis Kolyasev on 09.07.2022.
//

import Foundation

public struct Coder {

    // MARK: - Initialization

    public init(paramsEncoder: JSONEncoder = JSONEncoder(),
                resultDecoder: JSONDecoder = JSONDecoder()) {

        self.paramsEncoder = paramsEncoder
        self.resultDecoder = resultDecoder
    }

    // MARK: - Properties

    public var paramsEncoder: JSONEncoder

    public var resultDecoder: JSONDecoder

    // MARK: - Functions

    func encode<Params: InvocationParams>(_ params: Params) throws -> Request.Params? {
        guard Params.self != VoidInvocationParams.self else {
            return nil
        }
        do {
            let data = try paramsEncoder.encode(params)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            throw ParamsEncodingError(cause: error)
        }
    }

    func decode<Result: InvocationResult>(_ type: Result.Type, from result: Response.Result) throws -> Result {
        guard Result.self != VoidInvocationResult.self else {
            return VoidInvocationResult() as! Result // swiftlint:disable:this force_cast
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: result, options: .fragmentsAllowed)
            return try resultDecoder.decode(Result.self, from: data)
        } catch {
            throw ResultDecodingError(cause: error)
        }
    }

    // MARK: - Inner Types

    final class ParamsEncodingError: NestedError<Error> { }
    final class ResultDecodingError: NestedError<Error> { }

}
