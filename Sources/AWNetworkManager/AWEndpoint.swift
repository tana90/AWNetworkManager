//
//  File.swift
//  
//
//  Created by Tudor Octavian Ana on 13.10.2022.
//

import Foundation

// MARK: Endpoint protocol

public protocol AWEndpoint {
    
    /// URL of the Endpoint
    var url: URL { get }
    
    /// Request to make
    var request: URLRequest { get }
    
    /// Body of the request
    var body: Data? { get }
}
