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
let publisher = AWNetworkManager.begin(URLRequest(url: URL(string: "http://www.google.com")!))
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
