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
        XCTAssert(app.tables.cells.count == 3)

        app.tables.staticTexts["NEW ACTIVITY"].tap()
        
        let scrollViewsQuery = app.scrollViews
        
        scrollViewsQuery.otherElements.buttons["TimeButton"].tap()
        scrollViewsQuery.otherElements.containingType(.StaticText, identifier:"Label start").element.tap()
        app.navigationBars["Select Time"].buttons["Done"].tap()
        
        let textView = scrollViewsQuery.otherElements.containingType(.StaticText, identifier:"Project").childrenMatchingType(.TextView).element
        textView.tap()
        textView.typeText("Some activity")
        app.navigationBars["New Activity"].buttons["Done"].tap()
        
        XCTAssert(app.navigationBars["Apr 30, 2014 (9.50)"].exists)
        XCTAssert(app.tables.cells.count == 4)
        
    }
    
    func testDeleteActivity() {
        
        let app = XCUIApplication()
        
        XCTAssert(app.tables.cells.count == 3)

        let apr302014850NavigationBar = app.navigationBars["Apr 30, 2014 (8.50)"]
        let editButton = apr302014850NavigationBar.buttons["Edit"]
        editButton.tap()
        
        let tablesQuery = app.tables
        tablesQuery.buttons["Delete Digiprod, Website, Twitter bootstrap integration, 7.00"].tap()
        tablesQuery.buttons["Delete"].tap()
        
        XCTAssert(app.navigationBars["Apr 30, 2014 (1.50)"].exists)
        XCTAssert(app.tables.cells.count == 2)
        
    }
    
    func testNavigateToDate() {

        let app = XCUIApplication()
        app.navigationBars["Apr 30, 2014 (8.50)"].buttons["calendar"].tap()
        app.tables.childrenMatchingType(.Cell).elementBoundByIndex(79).buttons["April 29, 2014"].doubleTap()
        
        XCTAssert(app.navigationBars["Apr 29, 2014 (4.00)"].exists)
        XCTAssert(app.tables.cells.count == 2)
        
    }
    
    func testEditActivity() {
        
        let app = XCUIApplication()
        let firstCell = app.tables.cells.elementBoundByIndex(0)
        firstCell.tap()

        let textView = app.scrollViews.otherElements.containingType(.StaticText, identifier:"Project").childrenMatchingType(.TextView).element
        
        textView.tap()
        textView.typeText("Extraeasy ")
        app.navigationBars["Edit Activity"].buttons["Done"].tap()

        let label = app.tables.cells.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Extraeasy '")).element
        XCTAssert(label.exists)
        
        XCTAssert(app.navigationBars["Apr 30, 2014 (8.50)"].exists)
        XCTAssert(app.tables.cells.count == 3)

    }
    
}

