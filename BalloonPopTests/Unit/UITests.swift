// Created for BalloonPop Testing
// Unit tests for UI management
// Testing GameScene+UI.swift functionality

import XCTest
import SpriteKit
@testable import BalloonPop

/// Unit tests for user interface setup and updates
///
/// This test suite covers UI-related functionality including:
/// - Score label setup and configuration
/// - Missed balloons label setup and configuration
/// - Label positioning and alignment
/// - Label text updates
/// - Font styling and sizing
/// - Z-position layering
///
/// **Testing Pattern**: UI tests verify both initial setup and dynamic updates,
/// ensuring labels always reflect current game state accurately.
@MainActor
class UITests: XCTestCase {

    // MARK: - Properties

    /// The game scene being tested
    var scene: GameScene!

    /// Mock view for presenting the scene
    var view: SKView!

    // MARK: - Test Lifecycle

    /// Set up test environment before each test
    override func setUp() {
        super.setUp()

        // Create test scene with iPhone dimensions
        scene = GameScene(size: CGSize(width: 393, height: 852))

        // Create test view
        view = SKView(frame: CGRect(x: 0, y: 0, width: 393, height: 852))

        // Present scene (triggers didMove(to:))
        view.presentScene(scene)

        // Allow scene to complete setup
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
    }

    // MARK: - Helper Methods

    /// Helper method to assert a color is white by checking RGBA components
    ///
    /// **Why we need this**: Direct color equality fails when colors use different color spaces
    /// (e.g., UIExtendedSRGBColorSpace vs UIExtendedGrayColorSpace), even when visually identical.
    /// Comparing components avoids this issue.
    ///
    /// - Parameters:
    ///   - color: The color to check
    ///   - message: Custom assertion message
    private func assertColorIsWhite(_ color: SKColor?, message: String = "Color should be white") {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        XCTAssertEqual(red, 1.0, accuracy: 0.01, "\(message) - Red component should be 1.0")
        XCTAssertEqual(green, 1.0, accuracy: 0.01, "\(message) - Green component should be 1.0")
        XCTAssertEqual(blue, 1.0, accuracy: 0.01, "\(message) - Blue component should be 1.0")
        XCTAssertEqual(alpha, 1.0, accuracy: 0.01, "\(message) - Alpha should be 1.0")
    }

    /// Clean up test environment after each test
    override func tearDown() {
        // Stop timers to prevent interference
        scene.balloonTimer?.invalidate()
        scene.difficultyTimer?.invalidate()

        scene = nil
        view = nil

        super.tearDown()
    }

    // MARK: - Score Label Setup Tests

    /// Test that score label is created during scene setup
    ///
    /// **What we're testing**: Label initialization
    /// **Why it matters**: Score display is essential for gameplay feedback
    func testScoreLabelIsCreated() {
        // Assert: Score label should exist after scene setup
        XCTAssertNotNil(scene.scoreLabel, "Score label should be initialized during scene setup")
    }

    /// Test that score label is added to the scene
    ///
    /// **What we're testing**: Label is in scene hierarchy
    /// **Why it matters**: Must be in hierarchy to be rendered
    func testScoreLabelIsAddedToScene() {
        // Assert: Score label should be a child of the scene
        XCTAssertTrue(scene.children.contains(scene.scoreLabel),
                     "Score label should be added to scene hierarchy")
    }

    /// Test that score label has correct initial text
    ///
    /// **What we're testing**: Initial text content
    /// **Why it matters**: Must show starting score of 0
    func testScoreLabelHasCorrectInitialText() {
        // Assert: Should show "Score: 0"
        XCTAssertEqual(scene.scoreLabel.text, "Score: 0",
                      "Score label should display 'Score: 0' initially")
    }

    /// Test that score label has correct font
    ///
    /// **What we're testing**: Font styling
    /// **Why it matters**: Consistent visual appearance
    func testScoreLabelHasCorrectFont() {
        // Assert: Should use Arial-BoldMT
        XCTAssertEqual(scene.scoreLabel.fontName, "Arial-BoldMT",
                      "Score label should use Arial-BoldMT font")
    }

    /// Test that score label has correct font size
    ///
    /// **What we're testing**: Text size
    /// **Why it matters**: Must be readable
    func testScoreLabelHasCorrectFontSize() {
        // Assert: Should be 36 points
        XCTAssertEqual(scene.scoreLabel.fontSize, 36,
                      "Score label should have font size of 36")
    }

    /// Test that score label has correct color
    ///
    /// **What we're testing**: Text color
    /// **Why it matters**: Visibility against background
    func testScoreLabelHasCorrectColor() {
        // Assert: Should be white
        assertColorIsWhite(scene.scoreLabel.fontColor, message: "Score label should have white color")
    }

    /// Test that score label has correct horizontal alignment
    ///
    /// **What we're testing**: Text centering
    /// **Why it matters**: Proper alignment around position point
    func testScoreLabelHasCorrectHorizontalAlignment() {
        // Assert: Should be center-aligned
        XCTAssertEqual(scene.scoreLabel.horizontalAlignmentMode, .center,
                      "Score label should be horizontally center-aligned")
    }

    /// Test that score label has correct vertical alignment
    ///
    /// **What we're testing**: Vertical positioning
    /// **Why it matters**: Controls how text sits relative to position
    func testScoreLabelHasCorrectVerticalAlignment() {
        // Assert: Should be top-aligned
        XCTAssertEqual(scene.scoreLabel.verticalAlignmentMode, .top,
                      "Score label should be vertically top-aligned")
    }

    /// Test that score label is positioned correctly
    ///
    /// **What we're testing**: Spatial positioning
    /// **Why it matters**: Must be at top center of screen
    func testScoreLabelPositioning() {
        // Assert: Should be at top center
        let expectedX = scene.frame.midX
        let expectedY = scene.frame.maxY - 60

        XCTAssertEqual(scene.scoreLabel.position.x, expectedX, accuracy: 1.0,
                      "Score label should be horizontally centered")
        XCTAssertEqual(scene.scoreLabel.position.y, expectedY, accuracy: 1.0,
                      "Score label should be 60 points from top")
    }

    /// Test that score label has correct z-position
    ///
    /// **What we're testing**: Layering depth
    /// **Why it matters**: Must appear above game objects
    func testScoreLabelZPosition() {
        // Assert: Should have high z-position (100)
        XCTAssertEqual(scene.scoreLabel.zPosition, 100,
                      "Score label should have z-position of 100 to appear above game objects")
    }

    // MARK: - Missed Balloons Label Setup Tests

    /// Test that missed balloons label is created during scene setup
    ///
    /// **What we're testing**: Label initialization
    /// **Why it matters**: Shows player how close they are to game over
    func testMissedLabelIsCreated() {
        // Assert: Missed label should exist after scene setup
        XCTAssertNotNil(scene.missedLabel, "Missed balloons label should be initialized during scene setup")
    }

    /// Test that missed label is added to the scene
    ///
    /// **What we're testing**: Label in hierarchy
    /// **Why it matters**: Must be rendered
    func testMissedLabelIsAddedToScene() {
        // Assert: Missed label should be a child of the scene
        XCTAssertTrue(scene.children.contains(scene.missedLabel),
                     "Missed label should be added to scene hierarchy")
    }

    /// Test that missed label has correct initial text
    ///
    /// **What we're testing**: Initial text with max value
    /// **Why it matters**: Shows progress toward game over
    func testMissedLabelHasCorrectInitialText() {
        // Assert: Should show "Missed: 0/5" (or whatever maxMissedBalloons is)
        let expectedText = "Missed: 0/\(scene.maxMissedBalloons)"
        XCTAssertEqual(scene.missedLabel.text, expectedText,
                      "Missed label should display 'Missed: 0/\(scene.maxMissedBalloons)' initially")
    }

    /// Test that missed label has correct font
    ///
    /// **What we're testing**: Font consistency
    /// **Why it matters**: Matches score label style
    func testMissedLabelHasCorrectFont() {
        // Assert: Should use Arial-BoldMT
        XCTAssertEqual(scene.missedLabel.fontName, "Arial-BoldMT",
                      "Missed label should use Arial-BoldMT font")
    }

    /// Test that missed label has correct font size
    ///
    /// **What we're testing**: Size hierarchy
    /// **Why it matters**: Slightly smaller than score (24 vs 36)
    func testMissedLabelHasCorrectFontSize() {
        // Assert: Should be 24 points (smaller than score label)
        XCTAssertEqual(scene.missedLabel.fontSize, 24,
                      "Missed label should have font size of 24")
    }

    /// Test that missed label has correct color
    ///
    /// **What we're testing**: Color consistency
    /// **Why it matters**: Same as score label
    func testMissedLabelHasCorrectColor() {
        // Assert: Should be white
        assertColorIsWhite(scene.missedLabel.fontColor, message: "Missed label should have white color")
    }

    /// Test that missed label has correct horizontal alignment
    ///
    /// **What we're testing**: Alignment consistency
    /// **Why it matters**: Centers text like score label
    func testMissedLabelHasCorrectHorizontalAlignment() {
        // Assert: Should be center-aligned
        XCTAssertEqual(scene.missedLabel.horizontalAlignmentMode, .center,
                      "Missed label should be horizontally center-aligned")
    }

    /// Test that missed label is positioned below score label
    ///
    /// **What we're testing**: Relative positioning
    /// **Why it matters**: Visual hierarchy - score more important
    func testMissedLabelPositioning() {
        // Assert: Should be at top center, below score label
        let expectedX = scene.frame.midX
        let expectedY = scene.frame.maxY - 120

        XCTAssertEqual(scene.missedLabel.position.x, expectedX, accuracy: 1.0,
                      "Missed label should be horizontally centered")
        XCTAssertEqual(scene.missedLabel.position.y, expectedY, accuracy: 1.0,
                      "Missed label should be 120 points from top (below score label)")
    }

    /// Test that missed label is below score label
    ///
    /// **What we're testing**: Vertical spacing
    /// **Why it matters**: Proper visual hierarchy
    func testMissedLabelIsBelowScoreLabel() {
        // Assert: Missed label Y should be less than score label Y
        XCTAssertLessThan(scene.missedLabel.position.y, scene.scoreLabel.position.y,
                         "Missed label should be positioned below score label")
    }

    /// Test that missed label has correct z-position
    ///
    /// **What we're testing**: Layer depth
    /// **Why it matters**: Same layer as score label
    func testMissedLabelZPosition() {
        // Assert: Should have high z-position (100)
        XCTAssertEqual(scene.missedLabel.zPosition, 100,
                      "Missed label should have z-position of 100 to appear above game objects")
    }

    // MARK: - Score Label Update Tests

    /// Test that updateScoreLabel reflects current score
    ///
    /// **What we're testing**: Dynamic text updates
    /// **Why it matters**: Label must show actual score
    func testUpdateScoreLabelReflectsScore() {
        // Arrange: Set score
        scene.score = 10

        // Act: Update label
        scene.updateScoreLabel()

        // Assert: Label should show new score
        XCTAssertEqual(scene.scoreLabel.text, "Score: 10",
                      "Score label should update to show 'Score: 10'")
    }

    /// Test score label update with zero
    ///
    /// **What we're testing**: Edge case - zero score
    /// **Why it matters**: Initial/reset state
    func testUpdateScoreLabelWithZero() {
        // Arrange: Set score to 0
        scene.score = 0

        // Act: Update label
        scene.updateScoreLabel()

        // Assert: Should show 0
        XCTAssertEqual(scene.scoreLabel.text, "Score: 0",
                      "Score label should display 'Score: 0'")
    }

    /// Test score label update with large number
    ///
    /// **What we're testing**: High score display
    /// **Why it matters**: Must handle triple digits
    func testUpdateScoreLabelWithLargeNumber() {
        // Arrange: Set high score
        scene.score = 999

        // Act: Update label
        scene.updateScoreLabel()

        // Assert: Should show large number
        XCTAssertEqual(scene.scoreLabel.text, "Score: 999",
                      "Score label should display 'Score: 999'")
    }

    /// Test multiple consecutive score label updates
    ///
    /// **What we're testing**: Repeated updates
    /// **Why it matters**: Score changes frequently during gameplay
    func testMultipleScoreLabelUpdates() {
        // Act & Assert: Multiple updates
        for expectedScore in 0...10 {
            scene.score = expectedScore
            scene.updateScoreLabel()
            XCTAssertEqual(scene.scoreLabel.text, "Score: \(expectedScore)",
                          "Score label should update correctly to \(expectedScore)")
        }
    }

    /// Test that score label retains formatting after update
    ///
    /// **What we're testing**: Style persistence
    /// **Why it matters**: Updates shouldn't change appearance
    func testScoreLabelRetainsFormattingAfterUpdate() {
        // Arrange: Update score
        scene.score = 42
        scene.updateScoreLabel()

        // Assert: Formatting should remain unchanged
        XCTAssertEqual(scene.scoreLabel.fontName, "Arial-BoldMT",
                      "Font should remain Arial-BoldMT after update")
        XCTAssertEqual(scene.scoreLabel.fontSize, 36,
                      "Font size should remain 36 after update")
        assertColorIsWhite(scene.scoreLabel.fontColor, message: "Color should remain white after update")
        XCTAssertEqual(scene.scoreLabel.zPosition, 100,
                      "Z-position should remain 100 after update")
    }

    // MARK: - Missed Label Update Tests

    /// Test that updateMissedLabel reflects current count
    ///
    /// **What we're testing**: Dynamic count updates
    /// **Why it matters**: Shows progress toward game over
    func testUpdateMissedLabelReflectsCount() {
        // Arrange: Set missed count
        scene.missedBalloons = 3

        // Act: Update label
        scene.updateMissedLabel()

        // Assert: Label should show current/max
        XCTAssertEqual(scene.missedLabel.text, "Missed: 3/\(scene.maxMissedBalloons)",
                      "Missed label should show 'Missed: 3/\(scene.maxMissedBalloons)'")
    }

    /// Test missed label update with zero
    ///
    /// **What we're testing**: Initial state
    /// **Why it matters**: Game start display
    func testUpdateMissedLabelWithZero() {
        // Arrange: Set count to 0
        scene.missedBalloons = 0

        // Act: Update label
        scene.updateMissedLabel()

        // Assert: Should show 0
        XCTAssertEqual(scene.missedLabel.text, "Missed: 0/\(scene.maxMissedBalloons)",
                      "Missed label should display 'Missed: 0/\(scene.maxMissedBalloons)'")
    }

    /// Test missed label update at maximum
    ///
    /// **What we're testing**: Game over threshold display
    /// **Why it matters**: Shows when limit is reached
    func testUpdateMissedLabelAtMaximum() {
        // Arrange: Set to maximum
        scene.missedBalloons = scene.maxMissedBalloons

        // Act: Update label
        scene.updateMissedLabel()

        // Assert: Should show max/max
        XCTAssertEqual(scene.missedLabel.text, "Missed: \(scene.maxMissedBalloons)/\(scene.maxMissedBalloons)",
                      "Missed label should show maximum when limit reached")
    }

    /// Test multiple consecutive missed label updates
    ///
    /// **What we're testing**: Progressive updates
    /// **Why it matters**: Count increases during gameplay
    func testMultipleMissedLabelUpdates() {
        // Act & Assert: Multiple updates
        for count in 0...scene.maxMissedBalloons {
            scene.missedBalloons = count
            scene.updateMissedLabel()
            let expectedText = "Missed: \(count)/\(scene.maxMissedBalloons)"
            XCTAssertEqual(scene.missedLabel.text, expectedText,
                          "Missed label should update correctly to '\(expectedText)'")
        }
    }

    /// Test that missed label retains formatting after update
    ///
    /// **What we're testing**: Style persistence
    /// **Why it matters**: Updates shouldn't change appearance
    func testMissedLabelRetainsFormattingAfterUpdate() {
        // Arrange: Update count
        scene.missedBalloons = 2
        scene.updateMissedLabel()

        // Assert: Formatting should remain unchanged
        XCTAssertEqual(scene.missedLabel.fontName, "Arial-BoldMT",
                      "Font should remain Arial-BoldMT after update")
        XCTAssertEqual(scene.missedLabel.fontSize, 24,
                      "Font size should remain 24 after update")
        assertColorIsWhite(scene.missedLabel.fontColor, message: "Color should remain white after update")
        XCTAssertEqual(scene.missedLabel.zPosition, 100,
                      "Z-position should remain 100 after update")
    }

    // MARK: - Label Visibility Tests

    /// Test that labels are visible on scene
    ///
    /// **What we're testing**: Alpha/visibility
    /// **Why it matters**: Labels must be visible to player
    func testLabelsAreVisible() {
        // Assert: Both labels should have full alpha
        XCTAssertEqual(scene.scoreLabel.alpha, 1.0,
                      "Score label should be fully visible (alpha = 1.0)")
        XCTAssertEqual(scene.missedLabel.alpha, 1.0,
                      "Missed label should be fully visible (alpha = 1.0)")
    }

    /// Test that labels are not hidden
    ///
    /// **What we're testing**: isHidden flag
    /// **Why it matters**: Alternative to alpha for visibility
    func testLabelsAreNotHidden() {
        // Assert: Both labels should not be hidden
        XCTAssertFalse(scene.scoreLabel.isHidden,
                      "Score label should not be hidden")
        XCTAssertFalse(scene.missedLabel.isHidden,
                      "Missed label should not be hidden")
    }

    // MARK: - Label Layering Tests

    /// Test that labels appear above balloons
    ///
    /// **What we're testing**: Z-ordering
    /// **Why it matters**: UI must be visible over gameplay
    func testLabelsAppearAboveBalloons() {
        // Arrange: Spawn a balloon (z-position = 10)
        scene.spawnBalloon()
        let balloon = scene.children.first { $0.name == "balloon" }

        // Assert: Labels should have higher z-position than balloons
        XCTAssertGreaterThan(scene.scoreLabel.zPosition, balloon?.zPosition ?? 0,
                           "Score label should appear above balloons")
        XCTAssertGreaterThan(scene.missedLabel.zPosition, balloon?.zPosition ?? 0,
                           "Missed label should appear above balloons")
    }

    /// Test that both labels have same z-position
    ///
    /// **What we're testing**: Layer consistency
    /// **Why it matters**: Labels should be on same layer
    func testLabelsHaveSameZPosition() {
        // Assert: Both labels should have z-position of 100
        XCTAssertEqual(scene.scoreLabel.zPosition, scene.missedLabel.zPosition,
                      "Both labels should have the same z-position")
    }

    // MARK: - Label Positioning Relationship Tests

    /// Test that labels are horizontally aligned
    ///
    /// **What we're testing**: Horizontal consistency
    /// **Why it matters**: Visual cleanliness
    func testLabelsAreHorizontallyAligned() {
        // Assert: Both labels should have same X position
        XCTAssertEqual(scene.scoreLabel.position.x, scene.missedLabel.position.x,
                      "Labels should be horizontally aligned (same X position)")
    }

    /// Test that labels are both centered
    ///
    /// **What we're testing**: Screen centering
    /// **Why it matters**: Symmetrical layout
    func testLabelsAreCentered() {
        // Assert: Both labels should be at screen center X
        let centerX = scene.frame.midX
        XCTAssertEqual(scene.scoreLabel.position.x, centerX, accuracy: 1.0,
                      "Score label should be at horizontal center")
        XCTAssertEqual(scene.missedLabel.position.x, centerX, accuracy: 1.0,
                      "Missed label should be at horizontal center")
    }

    /// Test that there is adequate spacing between labels
    ///
    /// **What we're testing**: Vertical spacing
    /// **Why it matters**: Labels shouldn't overlap or be too far apart
    func testLabelSpacing() {
        // Act: Calculate spacing
        let spacing = scene.scoreLabel.position.y - scene.missedLabel.position.y

        // Assert: Should have 60 points spacing (120 - 60 = 60)
        XCTAssertEqual(spacing, 60, accuracy: 1.0,
                      "Labels should have 60 points vertical spacing")
    }

    // MARK: - Integration Tests

    /// Test that both labels are set up during scene initialization
    ///
    /// **What we're testing**: Complete UI setup
    /// **Why it matters**: Both labels must be ready at game start
    func testBothLabelsSetupDuringInitialization() {
        // Assert: Both labels should exist and be configured
        XCTAssertNotNil(scene.scoreLabel, "Score label should be initialized")
        XCTAssertNotNil(scene.missedLabel, "Missed label should be initialized")
        XCTAssertTrue(scene.children.contains(scene.scoreLabel),
                     "Score label should be in scene")
        XCTAssertTrue(scene.children.contains(scene.missedLabel),
                     "Missed label should be in scene")
    }

    /// Test that labels update correctly during gameplay simulation
    ///
    /// **What we're testing**: Real-world update scenario
    /// **Why it matters**: Integration test for typical gameplay
    func testLabelsUpdateDuringGameplay() {
        // Arrange: Start game
        scene.score = 0
        scene.missedBalloons = 0

        // Act: Simulate gameplay
        // Pop 3 balloons
        scene.score = 3
        scene.updateScoreLabel()

        // Miss 2 balloons
        scene.missedBalloons = 2
        scene.updateMissedLabel()

        // Assert: Labels should reflect gameplay
        XCTAssertEqual(scene.scoreLabel.text, "Score: 3",
                      "Score label should show 3 after 3 pops")
        XCTAssertEqual(scene.missedLabel.text, "Missed: 2/\(scene.maxMissedBalloons)",
                      "Missed label should show 2 after 2 misses")
    }

    /// Test that labels reset correctly on restart
    ///
    /// **What we're testing**: UI reset on game restart
    /// **Why it matters**: Fresh game should show fresh UI
    func testLabelsResetOnRestart() {
        // Arrange: Set non-initial values
        scene.score = 100
        scene.missedBalloons = 4
        scene.updateScoreLabel()
        scene.updateMissedLabel()

        // Act: Restart game
        scene.restartGame()

        // Assert: Labels should show reset values
        XCTAssertEqual(scene.scoreLabel.text, "Score: 0",
                      "Score label should reset to 0")
        XCTAssertEqual(scene.missedLabel.text, "Missed: 0/\(scene.maxMissedBalloons)",
                      "Missed label should reset to 0")
    }

    /// Test that label count matches expected label count
    ///
    /// **What we're testing**: No duplicate labels
    /// **Why it matters**: Prevents visual bugs
    func testNoDuplicateLabels() {
        // Act: Count SKLabelNode children
        let labelNodes = scene.children.filter { $0 is SKLabelNode }

        // Assert: Should have exactly 2 labels initially (score + missed)
        XCTAssertEqual(labelNodes.count, 2,
                      "Scene should have exactly 2 label nodes initially (score and missed)")
    }

    // MARK: - Edge Cases

    /// Test score label with negative number (shouldn't happen, but test anyway)
    ///
    /// **What we're testing**: Unexpected input handling
    /// **Why it matters**: Robustness
    func testScoreLabelWithNegativeNumber() {
        // Arrange: Set negative score (shouldn't happen in real game)
        scene.score = -5

        // Act: Update label
        scene.updateScoreLabel()

        // Assert: Should still format correctly
        XCTAssertEqual(scene.scoreLabel.text, "Score: -5",
                      "Score label should handle negative numbers")
    }

    /// Test missed label beyond maximum (shouldn't happen, but test anyway)
    ///
    /// **What we're testing**: Overflow handling
    /// **Why it matters**: Defensive programming
    func testMissedLabelBeyondMaximum() {
        // Arrange: Set count beyond max (game over should prevent this)
        scene.missedBalloons = scene.maxMissedBalloons + 10

        // Act: Update label
        scene.updateMissedLabel()

        // Assert: Should still format correctly
        let expectedText = "Missed: \(scene.maxMissedBalloons + 10)/\(scene.maxMissedBalloons)"
        XCTAssertEqual(scene.missedLabel.text, expectedText,
                      "Missed label should handle counts beyond maximum")
    }
}
