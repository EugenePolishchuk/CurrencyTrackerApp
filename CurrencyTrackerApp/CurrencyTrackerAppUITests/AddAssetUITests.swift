//
//  AddAssetUITests.swift
//  CurrencyTrackerAppUITests
//
//  Created by Yevhen on 08.04.2025.
//

import XCTest

final class AddAssetUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAddingAndRemovingCurrency() throws {
        app.navigationBars.buttons["plus"].tap()
        XCTAssertTrue(app.navigationBars["Add Asset"].exists)

        let cell = app.cells.element(boundBy: 0)
        if cell.exists {
            cell.tap()
        }

        app.navigationBars.buttons.element(boundBy: 0).tap() // Back to home
        XCTAssertTrue(app.staticTexts["Exchange Rates"].exists)
    }

    func testEmptySearchResultInAddAsset() {
        app.navigationBars.buttons["plus"].tap()

        let searchField = app.searchFields.element
        searchField.tap()
        searchField.typeText("XYZNotExist")

        XCTAssertTrue(app.staticTexts["No matching found. Try a different search"].waitForExistence(timeout: 1))
    }
}
