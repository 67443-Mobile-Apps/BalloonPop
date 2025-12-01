// Created for BalloonPop Testing
// Unit tests for game state management
// Testing GameScene+GameState.swift functionality

import XCTest
import SpriteKit
@testable import BalloonPop

/// Unit tests for game state management
///
/// This test suite covers the core game state logic including:
/// - Initial state verification
/// - Game over transition
/// - Restart functionality
/// - Score tracking
/// - Missed balloons tracking
///
/// **Testing Pattern**: These tests follow the AAA (Arrange-Act-Assert) pattern
/// and use descriptive test names that document expected behavior.
class GameStateTests: XCTestCase {

    // MARK: - Properties

    /// The game scene being tested
    var scene: GameScene!

    /// Mock view for presenting the scene
    var view: SKView!

    // MARK: - Test Lifecycle

    /// Set up test environment before each test
    ///
    /// Creates a fresh GameScene and SKView for each test to ensure isolation.
    /// Uses standard iPhone screen size for consistent testing.
    override func setUp() {
        super.setUp()

        // Create test scene with iPhone 15 Pro dimensions
        scene = GameScene(size: CGSize(width: 393, height: 852))

        // Create test view
        view = SKView(frame: CGRect(x: 0, y: 0, width: 393, height: 852))

        // Present scene (triggers didMove(to:))
        view.presentScene(scene)

        // Allow scene to complete setup
        // Note: In real tests, you might need to wait for async operations
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
    }

    /// Clean up test environment after each test
    ///
    /// Releases scene and view to prevent memory leaks between tests.
    override func tearDown() {
        // Clean up timers to prevent them from firing during other tests
        scene.balloonTimer?.invalidate()
        scene.difficultyTimer?.invalidate()

        scene = nil
        view = nil

        super.tearDown()
    }

    // MARK: - Initial State Tests

    /// Test that the game starts in the correct initial state
    ///
    /// **What we're testing**: Verifies all game state properties are initialized correctly
    /// **Why it matters**: Wrong initial state causes bugs from the very start
    func testInitialGameState() {
        // Assert: Verify initial state
        XCTAssertEqual(scene.score, 0, "Initial score should be 0")
        XCTAssertEqual(scene.missedBalloons, 0, "Initial missed balloons count should be 0")
        XCTAssertTrue(scene.isGameActive, "Game should be active when first loaded")
        XCTAssertEqual(scene.balloonSpawnInterval, 1.0, "Initial spawn interval should be 1.0 seconds")
    }

    /// Test that UI labels are properly initialized
    ///
    /// **What we're testing**: Score and missed labels exist and have correct initial values
    /// **Why it matters**: UI must reflect game state from the start
    func testInitialUIState() {
        // Assert: Verify UI labels are set up
        XCTAssertNotNil(scene.scoreLabel, "Score label should be initialized")
        XCTAssertNotNil(scene.missedLabel, "Missed balloons label should be initialized")
        XCTAssertEqual(scene.scoreLabel.text, "Score: 0", "Score label should show initial score")
        XCTAssertEqual(scene.missedLabel.text, "Missed: 0/\(scene.maxMissedBalloons)",
                      "Missed label should show initial count")
    }

    /// Test that timers are started on scene load
    ///
    /// **What we're testing**: Balloon spawning and difficulty timers are active
    /// **Why it matters**: Without timers, the game doesn't progress
    func testTimersStarted() {
        // Assert: Verify timers exist and are valid
        XCTAssertNotNil(scene.balloonTimer, "Balloon timer should be initialized")
        XCTAssertNotNil(scene.difficultyTimer, "Difficulty timer should be initialized")
        XCTAssertTrue(scene.balloonTimer?.isValid ?? false, "Balloon timer should be active")
        XCTAssertTrue(scene.difficultyTimer?.isValid ?? false, "Difficulty timer should be active")
    }

    // MARK: - Game Over Tests

    /// Test that gameOver() properly transitions to game over state
    ///
    /// **What we're testing**: Game over sets isGameActive to false
    /// **Why it matters**: isGameActive controls gameplay - must be set correctly
    func testGameOverSetsIsGameActiveToFalse() {
        // Arrange: Start with active game
        scene.isGameActive = true

        // Act: Trigger game over
        scene.gameOver()

        // Assert: Game should be inactive
        XCTAssertFalse(scene.isGameActive, "Game should be inactive after game over")
    }

    /// Test that gameOver() invalidates the balloon spawning timer
    ///
    /// **What we're testing**: Timer cleanup on game over
    /// **Why it matters**: Invalid timers prevent new balloons from spawning after game ends
    func testGameOverInvalidatesBalloonTimer() {
        // Arrange: Ensure timer is running
        XCTAssertTrue(scene.balloonTimer?.isValid ?? false, "Timer should be valid before game over")

        // Act: Trigger game over
        scene.gameOver()

        // Assert: Timer should be invalidated and nil
        XCTAssertNil(scene.balloonTimer, "Balloon timer should be nil after game over")
    }

    /// Test that gameOver() invalidates the difficulty timer
    ///
    /// **What we're testing**: Difficulty timer cleanup on game over
    /// **Why it matters**: Prevents difficulty from increasing after game ends
    func testGameOverInvalidatesDifficultyTimer() {
        // Arrange: Ensure timer is running
        XCTAssertTrue(scene.difficultyTimer?.isValid ?? false, "Timer should be valid before game over")

        // Act: Trigger game over
        scene.gameOver()

        // Assert: Timer should be invalidated and nil
        XCTAssertNil(scene.difficultyTimer, "Difficulty timer should be nil after game over")
    }

    /// Test that gameOver() removes all active balloons from the scene
    ///
    /// **What we're testing**: Balloon cleanup on game over
    /// **Why it matters**: Ensures clean slate for game over UI
    func testGameOverRemovesAllBalloons() {
        // Arrange: Add some test balloons
        for i in 0..<5 {
            let balloon = SKSpriteNode(imageNamed: "red_balloon")
            balloon.name = "balloon"
            balloon.position = CGPoint(x: 100 + CGFloat(i * 50), y: 200)
            scene.addChild(balloon)
        }

        // Verify balloons were added
        let balloonsBeforeGameOver = scene.children.filter { $0.name == "balloon" }
        XCTAssertEqual(balloonsBeforeGameOver.count, 5, "Should have 5 balloons before game over")

        // Act: Trigger game over
        scene.gameOver()

        // Assert: All balloons should be removed
        let balloonsAfterGameOver = scene.children.filter { $0.name == "balloon" }
        XCTAssertEqual(balloonsAfterGameOver.count, 0, "All balloons should be removed after game over")
    }

    /// Test that gameOver() displays the game over UI
    ///
    /// **What we're testing**: Game over labels are added to scene
    /// **Why it matters**: User needs to see game over message and final score
    func testGameOverDisplaysGameOverUI() {
        // Act: Trigger game over
        scene.gameOver()

        // Assert: Verify game over UI elements exist
        // Note: We check for any labels added after initial setup
        let labelCount = scene.children.filter { $0 is SKLabelNode }.count

        // Initial UI has 2 labels (score, missed), game over adds 3 more (game over, final score, restart)
        XCTAssertGreaterThanOrEqual(labelCount, 5,
                                   "Should have at least 5 labels after game over (2 initial + 3 game over)")
    }

    // MARK: - Restart Game Tests

    /// Test that restartGame() resets score to zero
    ///
    /// **What we're testing**: Score reset on restart
    /// **Why it matters**: Players expect fresh start with zero score
    func testRestartGameResetsScore() {
        // Arrange: Set non-zero score
        scene.score = 42
        scene.updateScoreLabel()

        // Act: Restart game
        scene.restartGame()

        // Assert: Score should be reset
        XCTAssertEqual(scene.score, 0, "Score should be reset to 0 after restart")
    }

    /// Test that restartGame() resets missed balloons count
    ///
    /// **What we're testing**: Missed balloons reset on restart
    /// **Why it matters**: Players start fresh without penalty from previous game
    func testRestartGameResetsMissedBalloons() {
        // Arrange: Set non-zero missed balloons
        scene.missedBalloons = 3
        scene.updateMissedLabel()

        // Act: Restart game
        scene.restartGame()

        // Assert: Missed balloons should be reset
        XCTAssertEqual(scene.missedBalloons, 0, "Missed balloons should be reset to 0 after restart")
    }

    /// Test that restartGame() reactivates the game
    ///
    /// **What we're testing**: isGameActive is set to true on restart
    /// **Why it matters**: Game must be playable after restart
    func testRestartGameSetsIsGameActiveToTrue() {
        // Arrange: Set game to inactive (simulating game over)
        scene.isGameActive = false

        // Act: Restart game
        scene.restartGame()

        // Assert: Game should be active again
        XCTAssertTrue(scene.isGameActive, "Game should be active after restart")
    }

    /// Test that restartGame() resets spawn interval to initial value
    ///
    /// **What we're testing**: Difficulty reset on restart
    /// **Why it matters**: Game should start at original difficulty, not harder
    func testRestartGameResetsSpawnInterval() {
        // Arrange: Reduce spawn interval (simulate difficulty increase)
        scene.balloonSpawnInterval = 0.5

        // Act: Restart game
        scene.restartGame()

        // Assert: Spawn interval should be reset
        XCTAssertEqual(scene.balloonSpawnInterval, 1.0,
                      "Spawn interval should be reset to initial value (1.0) after restart")
    }

    /// Test that restartGame() clears all child nodes
    ///
    /// **What we're testing**: Scene cleanup on restart
    /// **Why it matters**: Prevents leftover UI from previous game
    func testRestartGameClearsAllNodes() {
        // Arrange: Add some test nodes
        scene.gameOver()  // This adds game over UI
        let childCountBeforeRestart = scene.children.count

        XCTAssertGreaterThan(childCountBeforeRestart, 0, "Should have nodes before restart")

        // Act: Restart game
        scene.restartGame()

        // Assert: Should have fresh UI (only initial labels)
        // After restart, we should have: scoreLabel + missedLabel = 2 labels minimum
        let labelCount = scene.children.filter { $0 is SKLabelNode }.count
        XCTAssertEqual(labelCount, 2, "Should have exactly 2 labels after restart (score and missed)")
    }

    /// Test that restartGame() restarts timers
    ///
    /// **What we're testing**: Timer reactivation on restart
    /// **Why it matters**: Game loop must continue after restart
    func testRestartGameRestartsTimers() {
        // Arrange: Stop timers (simulate game over)
        scene.balloonTimer?.invalidate()
        scene.difficultyTimer?.invalidate()
        scene.balloonTimer = nil
        scene.difficultyTimer = nil

        // Act: Restart game
        scene.restartGame()

        // Allow timers to be created
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))

        // Assert: Timers should be running again
        XCTAssertNotNil(scene.balloonTimer, "Balloon timer should be restarted")
        XCTAssertNotNil(scene.difficultyTimer, "Difficulty timer should be restarted")
        XCTAssertTrue(scene.balloonTimer?.isValid ?? false, "Balloon timer should be valid")
        XCTAssertTrue(scene.difficultyTimer?.isValid ?? false, "Difficulty timer should be valid")
    }

    // MARK: - Score Tracking Tests

    /// Test that score can be incremented
    ///
    /// **What we're testing**: Basic score increment
    /// **Why it matters**: Core game mechanic - score must track correctly
    func testScoreIncrement() {
        // Arrange: Set initial score
        scene.score = 5

        // Act: Increment score
        scene.score += 1

        // Assert: Score should increase
        XCTAssertEqual(scene.score, 6, "Score should increment by 1")
    }

    /// Test score increment from zero
    ///
    /// **What we're testing**: First score point works correctly
    /// **Why it matters**: Edge case that's easy to miss
    func testScoreIncrementFromZero() {
        // Arrange: Ensure score is zero
        scene.score = 0

        // Act: Increment score
        scene.score += 1

        // Assert: Score should be 1
        XCTAssertEqual(scene.score, 1, "Score should be 1 after first increment")
    }

    /// Test that score label updates when score changes
    ///
    /// **What we're testing**: UI reflects score changes
    /// **Why it matters**: User must see their score update
    func testScoreLabelUpdatesWithScore() {
        // Arrange: Set score and update label
        scene.score = 10

        // Act: Update label
        scene.updateScoreLabel()

        // Assert: Label should reflect new score
        XCTAssertEqual(scene.scoreLabel.text, "Score: 10", "Score label should show current score")
    }

    // MARK: - Missed Balloons Tracking Tests

    /// Test that missed balloons count increments
    ///
    /// **What we're testing**: Basic missed balloons tracking
    /// **Why it matters**: Determines when game ends
    func testMissedBalloonsIncrement() {
        // Arrange: Set initial count
        scene.missedBalloons = 2

        // Act: Increment count
        scene.missedBalloons += 1

        // Assert: Count should increase
        XCTAssertEqual(scene.missedBalloons, 3, "Missed balloons should increment by 1")
    }

    /// Test that missed label updates when count changes
    ///
    /// **What we're testing**: UI reflects missed balloon changes
    /// **Why it matters**: User needs to know how close they are to game over
    func testMissedLabelUpdatesWithCount() {
        // Arrange: Set count and update label
        scene.missedBalloons = 3

        // Act: Update label
        scene.updateMissedLabel()

        // Assert: Label should reflect current count
        XCTAssertEqual(scene.missedLabel.text, "Missed: 3/\(scene.maxMissedBalloons)",
                      "Missed label should show current count")
    }

    /// Test that balloonEscaped increments missed count
    ///
    /// **What we're testing**: balloonEscaped() updates state correctly
    /// **Why it matters**: Core game mechanic when balloons get away
    func testBalloonEscapedIncrementsMissedCount() {
        // Arrange: Start with zero misses
        scene.missedBalloons = 0

        // Act: A balloon escapes
        scene.balloonEscaped()

        // Assert: Missed count should increase
        XCTAssertEqual(scene.missedBalloons, 1, "Missed balloons should increment when balloon escapes")
    }

    /// Test that game ends when max missed balloons is reached
    ///
    /// **What we're testing**: Game over trigger at miss threshold
    /// **Why it matters**: Game must end when player misses too many
    func testBalloonEscapedTriggersGameOver() {
        // Arrange: Set to one below maximum
        scene.missedBalloons = scene.maxMissedBalloons - 1
        scene.isGameActive = true

        // Act: One more balloon escapes
        scene.balloonEscaped()

        // Assert: Game should be over
        XCTAssertFalse(scene.isGameActive, "Game should be over when max missed balloons is reached")
        XCTAssertEqual(scene.missedBalloons, scene.maxMissedBalloons,
                      "Should have reached max missed balloons")
    }

    /// Test that game continues when below max missed balloons
    ///
    /// **What we're testing**: Game doesn't end prematurely
    /// **Why it matters**: Players should get all their allowed misses
    func testBalloonEscapedDoesNotTriggerGameOverWhenBelowMax() {
        // Arrange: Set to two below maximum
        scene.missedBalloons = scene.maxMissedBalloons - 2
        scene.isGameActive = true

        // Act: A balloon escapes
        scene.balloonEscaped()

        // Assert: Game should still be active
        XCTAssertTrue(scene.isGameActive, "Game should continue when below max missed balloons")
        XCTAssertEqual(scene.missedBalloons, scene.maxMissedBalloons - 1)
    }

    // MARK: - Edge Cases Tests

    /// Test multiple restarts in succession
    ///
    /// **What we're testing**: Restart works multiple times
    /// **Why it matters**: Players may restart repeatedly
    func testMultipleRestarts() {
        // Act & Assert: Restart multiple times
        for i in 1...3 {
            scene.score = i * 10
            scene.missedBalloons = i
            scene.restartGame()

            XCTAssertEqual(scene.score, 0, "Score should be reset on restart #\(i)")
            XCTAssertEqual(scene.missedBalloons, 0, "Missed balloons should be reset on restart #\(i)")
            XCTAssertTrue(scene.isGameActive, "Game should be active on restart #\(i)")
        }
    }

    /// Test that game state is consistent after restart
    ///
    /// **What we're testing**: Complete state reset
    /// **Why it matters**: Every restart should be identical to initial state
    func testRestartMatchesInitialState() {
        // Arrange: Change state
        scene.score = 100
        scene.missedBalloons = 4
        scene.balloonSpawnInterval = 0.3
        scene.isGameActive = false

        // Act: Restart
        scene.restartGame()

        // Assert: Should match initial state exactly
        XCTAssertEqual(scene.score, 0, "Score should match initial state")
        XCTAssertEqual(scene.missedBalloons, 0, "Missed balloons should match initial state")
        XCTAssertEqual(scene.balloonSpawnInterval, 1.0, "Spawn interval should match initial state")
        XCTAssertTrue(scene.isGameActive, "isGameActive should match initial state")
    }
}
