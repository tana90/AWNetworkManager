//
//  AWNetworkManager.swift
//  AWNetworkManager
//
//  Created by Tudor Ana on 01/02/2020.
//  Copyright © 2020 Tudor Ana. All rights reserved.
//

import Foundation

public class NetworkManager {
    
    static func request(with url: String,
                        method: String = "GET",
                        headers: [String:String] = [:],
                        _ completion: @escaping (Data?) -> ()) {
        
        let manager = NetworkManager()
        
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            manager.begin(request) { (data) in
                
                completion(data)
            }
        }
    }
    
    static func stopAll() {
        URLSession.shared.getAllTasks { (tasks) in
            tasks.forEach({ (task) in
                task.cancel()
            })
        }
    }
}

extension NetworkManager {
    
    private func begin(_ request: URLRequest,
                      with statusCode: ((_ code: Int) -> Void)? = nil,
                      and response: @escaping (_ response: Data?) -> Void) {
        
        
        URLSession.shared.dataTask(with: request) { (data, httpResponse, error) in
            
            #if DEBUG
            print("Response url : \(String(describing: request.url)) : \(String(describing: String(data: data ?? Data(), encoding: .utf8)))")
            #endif
            
            guard let data = data, error == nil else {
                if (error?.domain == "NSPOSIXErrorDomain" || error?.domain == "NSURLErrorDomain") {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.begin(request, with: statusCode, and: response)
                    }
                }
                return
            }

            response(data)
        }.resume()
    }
}

// MARK: Error
extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
