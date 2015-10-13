//
//  TimeCurlUITests.swift
//  TimeCurlUITests
//
//  Created by Patrick Jayet on 13/10/15.
//  Copyright © 2015 zuehlke. All rights reserved.
//

import XCTest

class TimeCurlUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddNewActivity() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["NEW ACTIVITY"].tap()
        
        let scrollViewsQuery = app.scrollViews
        
        scrollViewsQuery.otherElements.buttons["TimeButton"].tap()
        scrollViewsQuery.otherElements.containingType(.StaticText, identifier:"Label start").element.tap()
        app.navigationBars["Select Time"].buttons["Done"].tap()
        
        let textView = scrollViewsQuery.otherElements.containingType(.StaticText, identifier:"Project").childrenMatchingType(.TextView).element
        textView.tap()
        textView.typeText("Some activity")
        app.navigationBars["New Activity"].buttons["Done"].tap()
        
        
    }
    
}
