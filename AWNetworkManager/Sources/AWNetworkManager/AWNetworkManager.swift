import Foundation

public class AWNetworkManager {
    
    static public func begin(_ request: URLRequest,
                             _ response: @escaping (_ response: Data?) -> Void) {
        
        
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
                return
            }
            
            response(data)
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
