# SwiftJSONRPC

[![CI Status](http://img.shields.io/travis/kolyasev/SwiftJSONRPC.svg?style=flat)](https://travis-ci.org/kolyasev/SwiftJSONRPC)
<!-- [![Version](https://img.shields.io/cocoapods/v/SwiftJSONRPC.svg?style=flat)](http://cocoapods.org/pods/SwiftJSONRPC) -->
<!-- [![License](https://img.shields.io/cocoapods/l/SwiftJSONRPC.svg?style=flat)](http://cocoapods.org/pods/SwiftJSONRPC) -->
<!-- [![Platform](https://img.shields.io/cocoapods/p/SwiftJSONRPC.svg?style=flat)](http://cocoapods.org/pods/SwiftJSONRPC) -->

## Usage

### Defining a Service

```swift
import SwiftJSONRPC

class UserService: RPCService {
    func vote(rating: Int) async throws -> Int {
        return try await invoke("vote", params: ["rating": rating])
    }

    func create(name: String) async throws -> UserModel {
        return try await invoke("create", params: ["name": name])
    }

    // And other JSON-RPC methods
}
```

You can define as many services as you want depending on your requirements.

### Making a Request

```swift
// Init JSON-RPC client
let url = URL(string: "http://example.com/rpc")!
let client = RPCClient(url: url)

// Init JSON-RPC service
let service = MyService(client: client)

// Perform request
try await service.vote(rating: 5)
```

#### Result Serialization

SwiftJSONRPC provides built-in result serialization for `Int`, `String`, `Bool` types.

##### `Parcelable` Protocol

To serialize your custom type result from JSON you can implement `Parcelable` protocol.

```swift
protocol Parcelable {
    init(params: [String: Any]) throws
}
```

For example:

```swift
struct UserModel: Parcelable {
    let id: String
    let name: String
    
    required init(params: [String: Any]) throws {
        // Parse params to struct
        // ...
    }
}
```

> You can use libraries like [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper), [MAPPER](https://github.com/LYFT/MAPPER) or other to adapt `Parcelable` protocol. Or you can adapt Swift 4 `Decodable`.

After that use this struct as `RPCService.Result` generic parameter:

```swift
class UserService: RPCService {
    func create(name: String) async throws -> UserModel {
        return try await invoke("create", params: ["name": name])
    }
}
```
```swift
let user = try await service.create(name: "testuser")
print("User created with ID = \(user.id)")
```

Using array of `Parcelable` objects is also supported:

```swift
extension UserService {
    func allUsers() async throws -> [UserModel] {
        return try await invoke("all_users")
    }
}
```

## Advanced Usage

### Request Executor

## Requirements

## Installation

### CocoaPods

SwiftJSONRPC is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftJSONRPC"
```

### Carthage

```ruby
github "kolyasev/SwiftJSONRPC"
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/kolyasev/SwiftJSONRPC.git", .upToNextMajor(from: "0.7.0"))
]
```

## ToDo

- [ ] Add support for notification request object without an "id" member.
- [ ] Remove `Parcelable` protocol and use `Decodable`.

## Author

Denis Kolyasev, kolyasev@gmail.com

## License

SwiftJSONRPC is available under the MIT license. See the LICENSE file for more info.
