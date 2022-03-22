import Foundation
import Combine

// MARK: Endpoint protocol

public protocol AWEndpoint {
    
    /// URL of the Endpoint
    var url: URL { get }
    
    /// Request to make
    var request: URLRequest { get }
    
    /// Body of the request
    var body: Data? { get }
}

// MARK: Network manager

public class AWNetworkManager<Model> where Model: Decodable {
    
    /// Make a request to an Endpoint
    
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func call(endpoint: AWEndpoint,
                     retry: Bool = false,
                     verbose: Bool = false) -> Future<Model, Error> {
        Future { [weak self] promise in
            self?.make(endpoint.request,
                       retry: retry,
                       verbose: verbose) { result in
                promise(result)
            }
        }
    }
    
    /// Stop all the tasks in the URLSession queue
    
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

// MARK: Network manager private helpers

extension AWNetworkManager {
    
    public func make(_ request: URLRequest,
                          retry: Bool = false,
                          retryTimout: TimeInterval = 5,
                          verbose: Bool = false,
                          _ result: @escaping (Result<Model, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { (data, status, error) in
        #if DEBUG
            if verbose {
                print("Response url: \(String(describing: request.url)) : \(String(describing: String(data: data ?? Data(), encoding: .utf8)))")
            }
        #endif
            guard let data = data, error == nil else {
                
                if ((error as? NSError)?.domain == "NSPOSIXErrorDomain" ||
                    (error as? NSError)?.domain == "NSURLErrorDomain") && retry {
                    DispatchQueue.global().asyncAfter(deadline: .now() + retryTimout) { [weak self] in
                        self?.make(request, result)
                    }
                }
                
                guard let error = error else { return }
                result(.failure(error))
                return
            }
            
            do {
                result(.success(try JSONDecoder().decode(Model.self, from: data)))
            } catch {
                print(error)
                result(.failure(error))
            }
            
        }.resume()
    }
}
