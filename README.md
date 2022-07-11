# SwiftJSONRPC

## Usage

### Defining a Service

```swift
import SwiftJSONRPC

class UserService: RPCService {
    func vote(rating: Int) async throws -> Int {
        return try await invoke("vote", params: ["rating": rating])
    }

    func create(name: String) async throws -> User {
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

#### Result Decoding

SwiftJSONRPC uses Swift's `Decodable` protocol to decode response objects.

```swift
struct User: Decodable {
    let id: String
    let name: String
}

class UserService: RPCService {
    func getCurrentUser() async throws -> User {
        return try await invoke("getCurrentUser")
    }
}

let user = try await userService.getCurrentUser()
print("Current user ID = \(user.id), name = \(user.name)")
```

If you need to modify `JSONDecoder`'s behaviour, use `RPCClient.coder.resultDecoder` for that.

```swift
client.coder.resultDecoder.dateDecodingStrategy = .iso8601
```

#### Params Encoding

SwiftJSONRPC uses Swift's `Encodable` protocol to encode request params.

```swift
struct Message: Encodable {
    let text: String
}

class MessageService: RPCService {
    func send(message: Message) async throws {
        return try await invoke("sendMessage", params: message)
    }
}

let message = Message(text: "Hello World")
try await messageService.send(message: message)
```

If you need to modify `JSONEncoder`'s behaviour, use `RPCClient.coder.paramsEncoder` for that. 

```swift
client.coder.paramsEncoder.dateDecodingStrategy = .iso8601
```

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
    .package(url: "https://github.com/kolyasev/SwiftJSONRPC.git", .upToNextMajor(from: "0.9.0"))
]
```

## ToDo

- [ ] Add support for notification request object without an "id" member.

## Author

Denis Kolyasev, kolyasev@gmail.com

## License

SwiftJSONRPC is available under the MIT license. See the LICENSE file for more info.
