import Foundation

enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}

public class AWNetworkManager {
    
    static public func begin(_ request: URLRequest,
                             _ result: @escaping (Result<Data, Error>) -> Void) {
        
        
        URLSession.shared.dataTask(with: request) { (data, httpResponse, error) in
            
            #if DEBUG
            print("Response url : \(String(describing: request.url)) : \(String(describing: String(data: data ?? Data(), encoding: .utf8)))")
            #endif
            
            guard let data = data, error == nil else {
                if (error?.domain == "NSPOSIXErrorDomain" || error?.domain == "NSURLErrorDomain") {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        Self.begin(request, response)
                    }
                }
                result(.failure(error))
                return
            }

            result(.success(data))
        }.resume()
    }
    
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
