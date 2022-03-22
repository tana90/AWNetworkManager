# AWNetworkManager
## Simple - lightweight Networking Manager
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>

Requirements

iOS 12.0+
Swift 5.0+

```
var request = URLRequest(url: url)
AWNetworkManager.begin(request) { result in
            
    switch result {
     case .success(let data):
        // ...
     case .failure(let error):
        // ...
     }
}

```

iOS 13.0+

```

struct User: Decodable {
    var firstName
    var lastName
    // ...
}

enum Endpoint: AWEndpoint {
    
    case login
    case getUserData
    
    var url: URL {
        switch self {
        case .login:
            return // Login API
        case .getUserData:
            return // Fetch user data API
        }
    }
    
    var request: URLRequest {
        switch self {
        case .login:
            return URLRequest(url: Self.login.url)
        case .getUserData:
            var request = URLRequest(url: Self.getUserData.url)
            request.body = Self.getUserData.body
            return request
        }
    }
    
    var body: Data? {
        switch self {
        case .login:
            return nil
        case .getUserData:
            return Data() // Payload
        }
    }
}


let publisher = AWNetworkManager<UserData>().call(endpoint: Endpoint.login)
    .sink { completion in
        switch completion {
            case .finished:
                // ...
            case .failure(let error):
                // ...
            }
    } receiveValue: { data in
        // ...
    }
```

Contributors

@tana90
