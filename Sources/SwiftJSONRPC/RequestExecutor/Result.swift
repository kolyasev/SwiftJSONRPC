// ----------------------------------------------------------------------------
//
//  Result.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

enum Result<V, E> {
    case success(V)
    case error(E)

}
