//
//  CustomFit_iOSTests.swift
//  CustomFit_iOSTests
//
//  Created by Bharath R on 02/10/19.
//  Copyright © 2019 CustomFit. All rights reserved.
//

import XCTest
@testable import CustomFit_iOS

class CustomFit_iOSTests: XCTestCase {

    override func setUp() {
        swiftyLib = SwiftyLib()
    }
    
    func testAdd() {
        XCTAssertEqual(swiftyLib.add(a: 1, b: 1), 2)
    }
    
    func testSub() {
        XCTAssertEqual(swiftyLib.sub(a: 2, b: 1), 1)
    }

}
