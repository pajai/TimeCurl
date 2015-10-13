//
//  TimeUtilsTests.swift
//  TimeCurl
//
//  Created by Patrick Jayet on 13/10/15.
//  Copyright © 2015 zuehlke. All rights reserved.
//

import XCTest

class TimeUtilsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTimeStringFromDouble() {
        XCTAssert(TimeUtils.timeStringFromDouble(1.5)  == "1:30")
        XCTAssert(TimeUtils.timeStringFromDouble(2.25) == "2:15")
        XCTAssert(TimeUtils.timeStringFromDouble(14.75) == "14:45")
    }
    
    
}
