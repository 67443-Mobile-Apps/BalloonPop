// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0
// Qapla'

import XCTest

@MainActor
class ScreenshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testTakeScreenshots() {
        snapshot("01Launch")

        // Wait a moment for balloons to appear
        sleep(5)
        snapshot("02Gameplay")
    }
}
