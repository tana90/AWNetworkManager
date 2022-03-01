import Foundation

public class AWNetworkManager {

    static public func begin(_ request: URLRequest,
                             retry: Bool = false,
                             verbose: Bool = false,
                             _ result: @escaping (Result<Data, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { (data, status, error) in
#if DEBUG
            if verbose {
                print("Response url: \(String(describing: request.url)) : \(String(describing: String(data: data ?? Data(), encoding: .utf8)))")
            }
#endif
            guard let data = data, error == nil else {
                
                if (error?.domain == "NSPOSIXErrorDomain" || error?.domain == "NSURLErrorDomain") && retry {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                        Self.begin(request, result)
                    }
                }
                
                result(.failure(error!))
                return
            }
            
            result(.success(data))
            
        }.resume()
    }
    
    @available(macOS 10.11, *)
    @available(iOS 9.0, *)
    static public func stopAll() {
        URLSession.shared.getAllTasks { (tasks) in
            tasks.forEach({ (task) in
                task.cancel()
            })
        }
    }
}

// MARK: Error
extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
