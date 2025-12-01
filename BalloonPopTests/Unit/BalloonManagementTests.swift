// Created for BalloonPop Testing
// Unit tests for balloon management
// Testing GameScene+BalloonManagement.swift functionality

import XCTest
import SpriteKit
@testable import BalloonPop

/// Unit tests for balloon management and lifecycle
///
/// This test suite covers balloon-related functionality including:
/// - Balloon spawning logic
/// - Random balloon selection
/// - Difficulty progression
/// - Balloon escape handling
/// - Balloon popping mechanics
/// - Balloon positioning and bounds checking
///
/// **Testing Pattern**: Uses AAA pattern and focuses on observable behavior
/// rather than implementation details.
class BalloonManagementTests: XCTestCase {

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

    /// Clean up test environment after each test
    override func tearDown() {
        // Stop timers to prevent interference
        scene.balloonTimer?.invalidate()
        scene.difficultyTimer?.invalidate()

        // Remove all balloons
        scene.removeAllChildren()

        scene = nil
        view = nil

        super.tearDown()
    }

    // MARK: - Balloon Spawning Tests

    /// Test that spawnBalloon creates a balloon node
    ///
    /// **What we're testing**: Basic balloon creation
    /// **Why it matters**: Core game mechanic - balloons must appear
    func testSpawnBalloonCreatesNode() {
        // Arrange: Start with clean scene (no balloons)
        let initialChildCount = scene.children.count

        // Act: Spawn a balloon
        scene.spawnBalloon()

        // Assert: One more child should exist
        XCTAssertEqual(scene.children.count, initialChildCount + 1,
                      "Spawning should add one child node")
    }

    /// Test that spawned balloon has the correct name
    ///
    /// **What we're testing**: Balloon identification
    /// **Why it matters**: Touch handling relies on node names
    func testSpawnedBalloonHasCorrectName() {
        // Act: Spawn a balloon
        scene.spawnBalloon()

        // Assert: Should have a node named "balloon"
        let balloon = scene.children.first { $0.name == "balloon" }
        XCTAssertNotNil(balloon, "Spawned balloon should have name 'balloon'")
    }

    /// Test that spawned balloon is a sprite node
    ///
    /// **What we're testing**: Correct node type
    /// **Why it matters**: SKSpriteNode has specific rendering capabilities
    func testSpawnedBalloonIsSpriteNode() {
        // Act: Spawn a balloon
        scene.spawnBalloon()

        // Assert: Should be SKSpriteNode
        let balloon = scene.children.first { $0.name == "balloon" }
        XCTAssertTrue(balloon is SKSpriteNode, "Balloon should be an SKSpriteNode")
    }

    /// Test that spawned balloon has a physics body
    ///
    /// **What we're testing**: Physics setup
    /// **Why it matters**: Enables future collision detection
    func testSpawnedBalloonHasPhysicsBody() {
        // Act: Spawn a balloon
        scene.spawnBalloon()

        // Assert: Should have physics body
        let balloon = scene.children.first { $0.name == "balloon" }
        XCTAssertNotNil(balloon?.physicsBody, "Balloon should have a physics body")
    }

    /// Test that balloon physics body is configured correctly
    ///
    /// **What we're testing**: Physics properties
    /// **Why it matters**: Controls how balloon interacts with physics world
    func testBalloonPhysicsBodyConfiguration() {
        // Act: Spawn a balloon
        scene.spawnBalloon()

        // Assert: Verify physics body properties
        let balloon = scene.children.first { $0.name == "balloon" }
        guard let physicsBody = balloon?.physicsBody else {
            XCTFail("Balloon should have physics body")
            return
        }

        XCTAssertTrue(physicsBody.isDynamic, "Physics body should be dynamic")
        XCTAssertFalse(physicsBody.affectedByGravity, "Balloon should not be affected by gravity")
        XCTAssertEqual(physicsBody.categoryBitMask, 1, "Category bitmask should be 1")
        XCTAssertEqual(physicsBody.contactTestBitMask, 0, "Should not test for contacts")
        XCTAssertEqual(physicsBody.collisionBitMask, 0, "Should not collide with anything")
    }

    /// Test that balloon spawns with correct z-position
    ///
    /// **What we're testing**: Layering
    /// **Why it matters**: Balloons must appear above background, below UI
    func testBalloonZPosition() {
        // Act: Spawn a balloon
        scene.spawnBalloon()

        // Assert: Should have z-position of 10
        let balloon = scene.children.first { $0.name == "balloon" }
        XCTAssertEqual(balloon?.zPosition, 10, "Balloon should have z-position of 10")
    }

    /// Test that balloon spawns within horizontal bounds
    ///
    /// **What we're testing**: Position validation
    /// **Why it matters**: Balloons must be fully visible on screen
    func testBalloonSpawnsWithinBounds() {
        // Act: Spawn multiple balloons to test randomness
        var positions: [CGFloat] = []
        for _ in 0..<20 {
            scene.spawnBalloon()
            if let balloon = scene.children.last as? SKSpriteNode {
                positions.append(balloon.position.x)
            }
        }

        // Assert: All positions should be within valid range
        let balloonRadius = scene.balloonRadius
        let minX = balloonRadius + 15  // Base padding
        let maxX = scene.frame.width - (balloonRadius + 15)

        for position in positions {
            XCTAssertGreaterThanOrEqual(position, minX,
                                       "Balloon X position should be >= \(minX)")
            XCTAssertLessThanOrEqual(position, maxX,
                                    "Balloon X position should be <= \(maxX)")
        }
    }

    /// Test that balloon spawns at bottom of screen
    ///
    /// **What we're testing**: Vertical positioning
    /// **Why it matters**: Balloons should rise from bottom
    func testBalloonSpawnsAtBottom() {
        // Act: Spawn a balloon
        scene.spawnBalloon()

        // Assert: Should start below visible screen
        let balloon = scene.children.first { $0.name == "balloon" }
        XCTAssertEqual(balloon?.position.y, -50, "Balloon should spawn at y: -50")
    }

    /// Test that balloons don't spawn when game is inactive
    ///
    /// **What we're testing**: Guard clause for game state
    /// **Why it matters**: Prevents balloon spawning during game over
    func testSpawnBalloonIgnoredWhenGameInactive() {
        // Arrange: Set game to inactive
        scene.isGameActive = false
        let initialChildCount = scene.children.count

        // Act: Try to spawn a balloon
        scene.spawnBalloon()

        // Assert: No balloon should be added
        XCTAssertEqual(scene.children.count, initialChildCount,
                      "No balloon should spawn when game is inactive")
    }

    /// Test that multiple balloons can be spawned
    ///
    /// **What we're testing**: Repeated spawning
    /// **Why it matters**: Game loop spawns many balloons
    func testMultipleBalloonSpawning() {
        // Act: Spawn 5 balloons
        for _ in 0..<5 {
            scene.spawnBalloon()
        }

        // Assert: Should have 5 balloons
        let balloons = scene.children.filter { $0.name == "balloon" }
        XCTAssertEqual(balloons.count, 5, "Should have spawned 5 balloons")
    }

    // MARK: - Random Balloon Selection Tests

    /// Test that randomBalloonImageName returns a valid balloon color
    ///
    /// **What we're testing**: Random selection logic
    /// **Why it matters**: Must return valid image names
    func testRandomBalloonImageNameReturnsValidColor() {
        // Act: Get a random balloon name
        let balloonName = scene.randomBalloonImageName()

        // Assert: Should be one of the valid colors
        let validColors = ["red_balloon", "blue_balloon", "yellow_balloon", "green_balloon"]
        XCTAssertTrue(validColors.contains(balloonName),
                     "Should return a valid balloon color name")
    }

    /// Test that random balloon selection produces variety
    ///
    /// **What we're testing**: Randomness distribution
    /// **Why it matters**: Game should show different colored balloons
    func testRandomBalloonSelectionProducesVariety() {
        // Act: Get 100 random balloon names
        var colorCounts: [String: Int] = [:]
        for _ in 0..<100 {
            let color = scene.randomBalloonImageName()
            colorCounts[color, default: 0] += 1
        }

        // Assert: Should have at least 3 different colors (allowing for randomness)
        XCTAssertGreaterThanOrEqual(colorCounts.keys.count, 3,
                                   "Should produce at least 3 different colors in 100 attempts")
    }

    /// Test that all balloon colors appear eventually
    ///
    /// **What we're testing**: Complete color coverage
    /// **Why it matters**: All assets should be used
    func testAllBalloonColorsAppearEventually() {
        // Act: Get many random balloon names
        var observedColors = Set<String>()
        for _ in 0..<200 {
            let color = scene.randomBalloonImageName()
            observedColors.insert(color)
        }

        // Assert: Should eventually see all 4 colors
        let expectedColors: Set<String> = ["red_balloon", "blue_balloon", "yellow_balloon", "green_balloon"]
        XCTAssertEqual(observedColors, expectedColors,
                      "All 4 balloon colors should appear over many selections")
    }

    // MARK: - Difficulty Progression Tests

    /// Test that difficulty increases reduce spawn interval
    ///
    /// **What we're testing**: Difficulty mechanic
    /// **Why it matters**: Game should get progressively harder
    func testDifficultyIncreaseReducesSpawnInterval() {
        // Arrange: Set known spawn interval
        scene.balloonSpawnInterval = 1.0

        // Act: Increase difficulty
        scene.increaseDifficulty()

        // Assert: Interval should decrease
        XCTAssertLessThan(scene.balloonSpawnInterval, 1.0,
                         "Difficulty increase should reduce spawn interval")
        XCTAssertEqual(scene.balloonSpawnInterval, 0.9, accuracy: 0.01,
                      "Should decrease by 0.1 seconds")
    }

    /// Test that spawn interval never goes below minimum
    ///
    /// **What we're testing**: Difficulty cap
    /// **Why it matters**: Prevents impossibly fast spawning
    func testSpawnIntervalRespectsMinimum() {
        // Arrange: Set spawn interval near minimum
        scene.balloonSpawnInterval = 0.25

        // Act: Increase difficulty multiple times
        for _ in 0..<10 {
            scene.increaseDifficulty()
        }

        // Assert: Should not go below minimum (0.2)
        XCTAssertGreaterThanOrEqual(scene.balloonSpawnInterval, scene.minimumSpawnInterval,
                                   "Spawn interval should not go below minimum")
        XCTAssertEqual(scene.balloonSpawnInterval, 0.2, accuracy: 0.01,
                      "Should cap at minimum of 0.2 seconds")
    }

    /// Test that difficulty increase recreates timer
    ///
    /// **What we're testing**: Timer management
    /// **Why it matters**: New interval requires new timer
    func testDifficultyIncreaseRecreatesTimer() {
        // Arrange: Get reference to original timer
        let originalTimer = scene.balloonTimer

        // Act: Increase difficulty
        scene.increaseDifficulty()

        // Allow timer to be recreated
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))

        // Assert: Should have a new timer
        XCTAssertNotNil(scene.balloonTimer, "Should have new timer after difficulty increase")
        XCTAssertNotEqual(scene.balloonTimer, originalTimer,
                         "Timer should be recreated (not the same instance)")
    }

    /// Test progressive difficulty over multiple increases
    ///
    /// **What we're testing**: Cumulative difficulty changes
    /// **Why it matters**: Game should get progressively harder over time
    func testProgressiveDifficulty() {
        // Arrange: Start at initial interval
        scene.balloonSpawnInterval = 1.0

        // Act & Assert: Each increase should make it harder
        scene.increaseDifficulty()
        XCTAssertEqual(scene.balloonSpawnInterval, 0.9, accuracy: 0.01)

        scene.increaseDifficulty()
        XCTAssertEqual(scene.balloonSpawnInterval, 0.8, accuracy: 0.01)

        scene.increaseDifficulty()
        XCTAssertEqual(scene.balloonSpawnInterval, 0.7, accuracy: 0.01)
    }

    // MARK: - Balloon Escaped Tests

    /// Test that balloonEscaped increments missed count
    ///
    /// **What we're testing**: Basic escape tracking
    /// **Why it matters**: Core game mechanic for tracking misses
    func testBalloonEscapedIncrementsMissedCount() {
        // Arrange: Set initial missed count
        scene.missedBalloons = 2

        // Act: A balloon escapes
        scene.balloonEscaped()

        // Assert: Count should increase
        XCTAssertEqual(scene.missedBalloons, 3,
                      "Missed balloons should increment when balloon escapes")
    }

    /// Test that balloonEscaped updates the UI label
    ///
    /// **What we're testing**: UI update on escape
    /// **Why it matters**: User needs to see updated miss count
    func testBalloonEscapedUpdatesLabel() {
        // Arrange: Set count and get initial label text
        scene.missedBalloons = 1
        scene.updateMissedLabel()

        // Act: A balloon escapes
        scene.balloonEscaped()

        // Assert: Label should reflect new count
        XCTAssertEqual(scene.missedLabel.text, "Missed: 2/\(scene.maxMissedBalloons)",
                      "Missed label should update when balloon escapes")
    }

    /// Test that balloonEscaped triggers game over at threshold
    ///
    /// **What we're testing**: Game over trigger
    /// **Why it matters**: Game must end when too many balloons escape
    func testBalloonEscapedTriggersGameOverAtMax() {
        // Arrange: Set to one below max
        scene.missedBalloons = scene.maxMissedBalloons - 1
        scene.isGameActive = true

        // Act: One more balloon escapes
        scene.balloonEscaped()

        // Assert: Game should be over
        XCTAssertFalse(scene.isGameActive, "Game should end when max missed is reached")
    }

    /// Test that balloonEscaped doesn't trigger game over below threshold
    ///
    /// **What we're testing**: Premature game over prevention
    /// **Why it matters**: Players get all their allowed misses
    func testBalloonEscapedContinuesGameBelowMax() {
        // Arrange: Set below max
        scene.missedBalloons = 2
        scene.isGameActive = true

        // Act: A balloon escapes
        scene.balloonEscaped()

        // Assert: Game should continue
        XCTAssertTrue(scene.isGameActive, "Game should continue below max missed")
    }

    // MARK: - Balloon Popping Tests

    /// Test that popBalloon increments score
    ///
    /// **What we're testing**: Score increase on pop
    /// **Why it matters**: Core scoring mechanic
    func testPopBalloonIncrementsScore() {
        // Arrange: Create a balloon and set initial score
        let balloon = SKSpriteNode(imageNamed: "red_balloon")
        balloon.name = "balloon"
        scene.addChild(balloon)
        scene.score = 5

        // Act: Pop the balloon
        scene.popBalloon(balloon)

        // Assert: Score should increase
        XCTAssertEqual(scene.score, 6, "Score should increment by 1 when balloon is popped")
    }

    /// Test that popBalloon updates score label
    ///
    /// **What we're testing**: UI update on pop
    /// **Why it matters**: User needs to see score increase
    func testPopBalloonUpdatesScoreLabel() {
        // Arrange: Create a balloon and set score
        let balloon = SKSpriteNode(imageNamed: "red_balloon")
        balloon.name = "balloon"
        scene.addChild(balloon)
        scene.score = 9

        // Act: Pop the balloon
        scene.popBalloon(balloon)

        // Assert: Label should show new score
        XCTAssertEqual(scene.scoreLabel.text, "Score: 10",
                      "Score label should update when balloon is popped")
    }

    /// Test that popBalloon applies animation
    ///
    /// **What we're testing**: Visual feedback
    /// **Why it matters**: Provides satisfying pop effect
    func testPopBalloonAppliesAnimation() {
        // Arrange: Create a balloon
        let balloon = SKSpriteNode(imageNamed: "red_balloon")
        balloon.name = "balloon"
        scene.addChild(balloon)

        // Act: Pop the balloon
        scene.popBalloon(balloon)

        // Assert: Balloon should have actions running
        XCTAssertTrue(balloon.hasActions(), "Popped balloon should have animation actions")
    }

    /// Test that popped balloon is eventually removed
    ///
    /// **What we're testing**: Balloon cleanup after pop
    /// **Why it matters**: Prevents memory leaks and visual clutter
    func testPopBalloonEventuallyRemovesNode() {
        // Arrange: Create a balloon
        let balloon = SKSpriteNode(imageNamed: "red_balloon")
        balloon.name = "balloon"
        scene.addChild(balloon)

        // Act: Pop the balloon
        scene.popBalloon(balloon)

        // Wait for animation to complete (0.1 second pop animation)
        let expectation = XCTestExpectation(description: "Balloon removed after animation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)

        // Assert: Balloon should be removed from scene
        XCTAssertNil(balloon.parent, "Balloon should be removed from parent after pop animation")
    }

    /// Test popping multiple balloons
    ///
    /// **What we're testing**: Multiple pops work correctly
    /// **Why it matters**: Players pop many balloons per game
    func testPoppingMultipleBalloons() {
        // Arrange: Create 5 balloons
        var balloons: [SKSpriteNode] = []
        for i in 0..<5 {
            let balloon = SKSpriteNode(imageNamed: "red_balloon")
            balloon.name = "balloon"
            balloon.position = CGPoint(x: 100 + CGFloat(i * 50), y: 200)
            scene.addChild(balloon)
            balloons.append(balloon)
        }

        scene.score = 0

        // Act: Pop all balloons
        for balloon in balloons {
            scene.popBalloon(balloon)
        }

        // Assert: Score should reflect all pops
        XCTAssertEqual(scene.score, 5, "Score should increase for each popped balloon")
    }

    // MARK: - Timer Management Tests

    /// Test that balloon timer starts on scene load
    ///
    /// **What we're testing**: Automatic timer initialization
    /// **Why it matters**: Game must start spawning balloons
    func testBalloonTimerStartsAutomatically() {
        // Assert: Timer should be running after scene setup
        XCTAssertNotNil(scene.balloonTimer, "Balloon timer should be created on scene load")
        XCTAssertTrue(scene.balloonTimer?.isValid ?? false,
                     "Balloon timer should be valid and running")
    }

    /// Test that difficulty timer starts on scene load
    ///
    /// **What we're testing**: Difficulty timer initialization
    /// **Why it matters**: Game difficulty must progress over time
    func testDifficultyTimerStartsAutomatically() {
        // Assert: Timer should be running after scene setup
        XCTAssertNotNil(scene.difficultyTimer, "Difficulty timer should be created on scene load")
        XCTAssertTrue(scene.difficultyTimer?.isValid ?? false,
                     "Difficulty timer should be valid and running")
    }

    // MARK: - Edge Cases and Integration Tests

    /// Test spawning balloon with zero-width frame (edge case)
    ///
    /// **What we're testing**: Guard clause for invalid dimensions
    /// **Why it matters**: Prevents crashes during scene initialization
    func testSpawnBalloonWithInvalidFrame() {
        // Arrange: Create scene with zero dimensions
        let invalidScene = GameScene(size: .zero)
        invalidScene.isGameActive = true

        let initialChildCount = invalidScene.children.count

        // Act: Try to spawn balloon
        invalidScene.spawnBalloon()

        // Assert: Should not crash, should not spawn
        XCTAssertEqual(invalidScene.children.count, initialChildCount,
                      "Should not spawn balloon with invalid frame dimensions")
    }

    /// Test balloon lifecycle from spawn to escape
    ///
    /// **What we're testing**: Complete balloon flow without popping
    /// **Why it matters**: Integration test for normal gameplay
    func testBalloonLifecycleSpawnToEscape() {
        // Arrange: Set initial state
        scene.missedBalloons = 0
        let initialBalloonCount = scene.children.filter { $0.name == "balloon" }.count

        // Act: Spawn a balloon
        scene.spawnBalloon()

        let balloonCount = scene.children.filter { $0.name == "balloon" }.count
        XCTAssertEqual(balloonCount, initialBalloonCount + 1, "Balloon should be spawned")

        // Act: Simulate balloon escape
        scene.balloonEscaped()

        // Assert: Missed count should increase
        XCTAssertEqual(scene.missedBalloons, 1, "Missed count should increase after escape")
    }

    /// Test balloon lifecycle from spawn to pop
    ///
    /// **What we're testing**: Complete balloon flow with popping
    /// **Why it matters**: Integration test for successful gameplay
    func testBalloonLifecycleSpawnToPop() {
        // Arrange: Set initial state
        scene.score = 0

        // Act: Spawn and immediately pop balloon
        scene.spawnBalloon()
        let balloon = scene.children.first { $0.name == "balloon" }
        XCTAssertNotNil(balloon, "Balloon should be spawned")

        scene.popBalloon(balloon!)

        // Assert: Score should increase
        XCTAssertEqual(scene.score, 1, "Score should increase after popping balloon")
    }
}
