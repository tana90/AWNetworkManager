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
    
    public init() { }
    
    /// Make a request to an URL
    
    @available(macOS 10.12, iOS 10, watchOS 4, tvOS 10, *)
    public func call(
        url: URL,
        retry: Bool = false,
        verbose: Bool = false,
        _ result: @escaping (Result<Model, Error>) -> Void
    ) {
        makeAndDecode(URLRequest(url: url),
                      retry: retry,
                      verbose: verbose,
                      result)
    }
    
    /// Make a request to an Endpoint
    
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func call(
        endpoint: AWEndpoint,
        retry: Bool = false,
        verbose: Bool = false
    ) -> Future<Model, Error> {
        Future { [weak self] promise in
            self?.makeAndDecode(endpoint.request,
                                retry: retry,
                                verbose: verbose) { result in
                promise(result)
            }
        }
    }

    // Make a request and return raw data

    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func callRaw(
        url: URL,
        retry: Bool = false,
        verbose: Bool = false,
        rawResult: @escaping (Result<Data, Error>) -> Void
    ) {
        make(URLRequest(url: url),
             retry: retry,
             verbose: verbose,
             rawResult)
    }
    
    // Make a request and return a publisher
    
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func call(endpoint: AWEndpoint) -> URLSession.DataTaskPublisher {
        return URLSession.shared.dataTaskPublisher(for: endpoint.request)
    }
}

// MARK: Network manager private helpers

extension AWNetworkManager {
    
    private func makeAndDecode(_ request: URLRequest,
                               retry: Bool = false,
                               retryTimout: TimeInterval = 5,
                               verbose: Bool = false,
                               _ result: @escaping (Result<Model, Error>) -> Void) {

        make(request, retry: retry, retryTimout: retryTimout, verbose: verbose) { requestResult in
            switch requestResult {
                case .success(let data):
                    do {
                        result(.success(try JSONDecoder().decode(Model.self, from: data)))
                    } catch {
                        print(error)
                        result(.failure(error))
                    }
                case .failure(let error):
                    result(.failure(error))
            }
        }
    }

    private func make(_ request: URLRequest,
                      retry: Bool = false,
                      retryTimout: TimeInterval = 5,
                      verbose: Bool = false,
                      _ result: @escaping (Result<Data, Error>) -> Void) {

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

            result(.success(data))

        }.resume()
    }
}
