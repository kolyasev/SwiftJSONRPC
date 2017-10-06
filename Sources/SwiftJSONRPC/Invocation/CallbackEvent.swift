// ----------------------------------------------------------------------------
//
//  CallbackEvent.swift
//
//  @author Denis Kolyasev <kolyasev@gmail.com>
//
// ----------------------------------------------------------------------------

public enum CallbackEvent<R>
{
    case start
    case result(R)
    case error(InvocationError)
    case cancel
    case finish
}

// ----------------------------------------------------------------------------

extension CallbackEvent
{
    enum Simple
    {
        case start
        case result
        case error
        case cancel
        case finish
    }

    var simple: Simple
    {
        switch self
        {
            case .start:     return .start
            case .result(_): return .result
            case .error(_):  return .error
            case .cancel:    return .cancel
            case .finish:    return .finish
        }
    }
}

// ----------------------------------------------------------------------------

