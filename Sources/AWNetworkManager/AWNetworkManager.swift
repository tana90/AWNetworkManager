import Foundation

public class AWNetworkManager {

    public enum Result<Success, Failure: Error> {
        case success(Success)
        case failure(Failure)
    }

    static public func begin(_ request: URLRequest,
                             retry: Bool = false,
                             _ result: @escaping (Result<Data, Error>) -> Void) {

        URLSession.shared.dataTask(with: request) { (data, status, error) in

            #if DEBUG
            print("Response url: \(String(describing: request.url)) : \(String(describing: String(data: data ?? Data(), encoding: .utf8))) : \(status)")
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
