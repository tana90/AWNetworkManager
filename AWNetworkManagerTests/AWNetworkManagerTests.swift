//
//  AWNetworkManagerTests.swift
//  AWNetworkManagerTests
//
//  Created by Tudor Ana on 01/02/2020.
//  Copyright © 2020 Tudor Ana. All rights reserved.
//

import XCTest
@testable import AWNetworkManager

class AWNetworkManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        NetworkManager.request(with: "https://www.google.ro") { (data) in
            
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            NetworkManager.request(with: "https://www.google.ro") { (data) in
                
            }
        }
    }

}
