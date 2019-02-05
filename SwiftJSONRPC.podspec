Pod::Spec.new do |s|
  s.name             = "SwiftJSONRPC"
  s.version          = "0.6.2"
  s.summary          = "Swift JSON-RPC client based on Alamofire"
  s.homepage         = "https://github.com/kolyasev/SwiftJSONRPC"
  s.license          = 'MIT'
  s.author           = { "Denis Kolyasev" => "kolyasev@gmail.com" }
  s.source           = { :git => "https://github.com/kolyasev/SwiftJSONRPC.git", :tag => s.version.to_s }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.12"
  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'

  s.frameworks = 'Foundation'
  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'PromiseKit', '~> 6.3'

  # TODO: Convert to Swift 3.x
  # s.dependency 'Atomic', '~> 1.0'
end
