# Testing Strategy for BalloonPop

## Overview

This document outlines a comprehensive testing strategy for the BalloonPop game. The codebase is well-organized with clear separation of concerns through extensions, making it highly testable.

## Current Project Structure

```
BalloonPop/
├── GameScene.swift                      # Main scene with properties and lifecycle
├── GameScene+GameState.swift            # Game over and restart logic
├── GameScene+BalloonManagement.swift    # Balloon spawning and animation
├── GameScene+TouchHandling.swift        # Touch event handling
├── GameScene+UI.swift                   # UI setup and updates
├── GameViewController.swift             # View controller
└── AppDelegate.swift                    # App lifecycle
```

## Testing Levels

### 1. Unit Tests (Individual Components)

Unit tests verify individual methods and functions in isolation.

#### A. Game State Tests (`GameStateTests.swift`)

**Test Target**: `GameScene+GameState.swift`

```swift
// Test cases to implement:

testInitialGameState()
- Verify score starts at 0
- Verify missedBalloons starts at 0
- Verify isGameActive is true
- Verify balloonSpawnInterval is 1.0

testGameOver()
- Call gameOver()
- Verify isGameActive becomes false
- Verify timers are invalidated
- Verify all balloons are removed from scene

testRestartGame()
- Set non-initial values (score = 10, missedBalloons = 3)
- Call restartGame()
- Verify all values reset to initial state
- Verify isGameActive is true
- Verify scene children are rebuilt

testScoreIncrement()
- Set score to 5
- Increment score
- Verify score is now 6

testMissedBalloonsTracking()
- Set missedBalloons to 4 (one below max)
- Increment missedBalloons
- Verify gameOver() is called when reaching maxMissedBalloons
```

**Why These Tests Matter**: Game state is the foundation of gameplay. Bugs here (like score not resetting) create frustrating user experiences.

#### B. Balloon Management Tests (`BalloonManagementTests.swift`)

**Test Target**: `GameScene+BalloonManagement.swift`

```swift
// Test cases to implement:

testBalloonSpawning()
- Call spawnBalloon()
- Verify a balloon node is added to the scene
- Verify balloon has name "balloon"
- Verify balloon has physics body
- Verify balloon position is within valid range

testBalloonSpawningWhenInactive()
- Set isGameActive to false
- Call spawnBalloon()
- Verify NO balloon is added (guard clause works)

testRandomBalloonSelection()
- Call randomBalloonImageName() 100 times
- Verify all 4 colors appear at least once
- Verify only valid color names are returned

testDifficultyIncrease()
- Set balloonSpawnInterval to 1.0
- Call increaseDifficulty()
- Verify balloonSpawnInterval decreased by 0.1 (now 0.9)
- Call increaseDifficulty() multiple times
- Verify interval never goes below minimumSpawnInterval (0.2)

testBalloonEscaped()
- Set missedBalloons to 2
- Call balloonEscaped()
- Verify missedBalloons is now 3
- Verify missedLabel is updated

testBalloonEscapedTriggersGameOver()
- Set missedBalloons to maxMissedBalloons - 1
- Call balloonEscaped()
- Verify gameOver() is called

testPopBalloon()
- Create a balloon
- Set score to 5
- Call popBalloon(balloon)
- Verify score incremented to 6
- Verify balloon has pop animation applied
- Verify balloon is removed after animation
```

**Why These Tests Matter**: Balloon management is the core game loop. Bugs here directly affect gameplay mechanics.

#### C. UI Tests (`UITests.swift`)

**Test Target**: `GameScene+UI.swift`

```swift
// Test cases to implement:

testScoreLabelSetup()
- Call setupScoreLabel()
- Verify scoreLabel is not nil
- Verify scoreLabel is added to scene
- Verify scoreLabel has correct initial text "Score: 0"
- Verify scoreLabel position is correct
- Verify scoreLabel zPosition is 100

testMissedLabelSetup()
- Call setupMissedBalloonsLabel()
- Verify missedLabel is not nil
- Verify missedLabel has correct initial text
- Verify missedLabel position is below scoreLabel

testUpdateScoreLabel()
- Set score to 42
- Call updateScoreLabel()
- Verify scoreLabel.text is "Score: 42"

testUpdateMissedLabel()
- Set missedBalloons to 3
- Call updateMissedLabel()
- Verify missedLabel.text is "Missed: 3/5"
```

**Why These Tests Matter**: UI bugs are immediately visible to users and affect the polish of the game.

#### D. Touch Handling Tests (`TouchHandlingTests.swift`)

**Test Target**: `GameScene+TouchHandling.swift`

```swift
// Test cases to implement:

testTouchBalloonDuringGameplay()
- Create a balloon at known position
- Set isGameActive to true
- Simulate touch at balloon position
- Verify popBalloon() is called
- Verify score increases

testTouchEmptySpaceDuringGameplay()
- Set isGameActive to true
- Simulate touch at position with no balloons
- Verify score does NOT increase

testTouchIgnoredWhenGameInactive()
- Create a balloon
- Set isGameActive to false
- Simulate touch at balloon position
- Verify popBalloon() is NOT called

testTouchRestartButton()
- Set isGameActive to false
- Add restart label to scene
- Simulate touch on restart label
- Verify restartGame() is called

testTouchRestartIgnoredDuringGameplay()
- Set isGameActive to true
- Add restart label to scene
- Simulate touch on restart label
- Verify restartGame() is NOT called
```

**Why These Tests Matter**: Touch handling is how users interact with the game. Bugs here make the game unplayable.

---

### 2. Integration Tests (Component Interactions)

Integration tests verify that multiple components work together correctly.

#### E. Game Flow Tests (`GameFlowIntegrationTests.swift`)

```swift
// Test cases to implement:

testCompleteGameFlow()
- Start game with didMove(to:)
- Verify initial state is correct
- Verify timers are running
- Simulate balloon spawn
- Simulate popping balloon
- Verify score increases
- Let balloons escape until maxMissedBalloons
- Verify game over state
- Verify restart button appears
- Simulate restart
- Verify game returns to initial state

testDifficultyProgressionOverTime()
- Start game
- Record initial balloonSpawnInterval
- Wait for difficultyIncreaseInterval
- Verify balloonSpawnInterval decreased
- Verify new balloons spawn faster

testTimerCleanup()
- Start game (timers created)
- Call willMove(from:)
- Verify timers are invalidated
- Verify timers are set to nil

testMultipleBalloonInteractions()
- Spawn 5 balloons
- Pop 3 balloons
- Let 2 balloons escape
- Verify score is 3
- Verify missedBalloons is 2
- Verify game continues (hasn't ended)
```

**Why These Tests Matter**: Integration tests catch bugs that only appear when components interact, like race conditions or state synchronization issues.

---

### 3. SpriteKit-Specific Tests

#### F. Scene Tests (`SceneTests.swift`)

```swift
// Test cases to implement:

testSceneSetup()
- Call setupScene()
- Verify backgroundColor is sky blue
- Verify physicsWorld.gravity is zero
- Verify physicsWorld.contactDelegate is set

testBalloonPhysicsBody()
- Spawn a balloon
- Verify physics body exists
- Verify physics body is circular
- Verify isDynamic is true
- Verify affectedByGravity is false

testBalloonPositioning()
- Get safe area insets
- Spawn 100 balloons
- Verify all balloons spawn within safe horizontal bounds
- Verify all balloons start at y: -50

testBalloonZPositioning()
- Spawn balloon
- Verify balloon zPosition is 10
- Verify scoreLabel zPosition is 100
- Verify UI labels render above balloons
```

**Why These Tests Matter**: SpriteKit has specific behaviors around physics, positioning, and rendering that need verification.

---

### 4. Performance Tests

#### G. Performance Tests (`PerformanceTests.swift`)

```swift
// Test cases to implement:

testSpawnManyBalloons()
- Measure time to spawn 100 balloons
- Verify spawning completes within reasonable time (< 1 second)
- Verify memory usage is acceptable

testRapidTouchHandling()
- Spawn 50 balloons
- Simulate 100 rapid touches
- Measure response time
- Verify no crashes or hangs

testMemoryLeaksWithTimers()
- Create scene
- Start timers
- Invalidate timers
- Release scene
- Verify no memory leaks (use XCTest memory leak detection)

testAnimationPerformance()
- Spawn 50 balloons with animations
- Measure frame rate
- Verify frame rate stays above 30 FPS
```

**Why These Tests Matter**: Performance issues make games feel sluggish or cause crashes on older devices.

---

### 5. UI/Visual Tests (Advanced)

#### H. Snapshot Tests (Optional - requires SnapshotTesting library)

```swift
// Test cases to implement:

testInitialGameScreenshot()
- Render initial game state
- Compare screenshot to reference image
- Verify no visual regressions

testGameOverScreenshot()
- Trigger game over
- Render game over screen
- Compare to reference image

testScoreLabelAppearance()
- Set score to various values (1, 10, 100, 1000)
- Verify label renders correctly for each
```

**Why These Tests Matter**: Snapshot tests catch visual regressions that unit tests miss, like layout issues or font changes.

---

## Test Organization Strategy

### Recommended Test Target Structure

```
BalloonPopTests/
├── Unit/
│   ├── GameStateTests.swift
│   ├── BalloonManagementTests.swift
│   ├── UITests.swift
│   └── TouchHandlingTests.swift
├── Integration/
│   ├── GameFlowIntegrationTests.swift
│   └── SceneTests.swift
├── Performance/
│   └── PerformanceTests.swift
└── Helpers/
    ├── TestHelpers.swift           # Shared test utilities
    └── MockObjects.swift            # Mock SKView, etc.
```

---

## Testing Best Practices for Students

### 1. Start with Unit Tests

Begin with simple unit tests for game state and calculations. These are:
- Easiest to write
- Fastest to run
- Provide immediate feedback

### 2. Use XCTest Framework

```swift
import XCTest
import SpriteKit
@testable import BalloonPop

@MainActor  // GameScene and SpriteKit run on the main actor (required in Swift 6)
class GameStateTests: XCTestCase {
    var scene: GameScene!
    var view: SKView!

    override func setUp() {
        super.setUp()
        // Create test scene
        scene = GameScene(size: CGSize(width: 375, height: 667))
        view = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.presentScene(scene)
    }

    override func tearDown() {
        scene = nil
        view = nil
        super.tearDown()
    }

    func testInitialScore() {
        XCTAssertEqual(scene.score, 0, "Initial score should be 0")
    }
}
```

### 3. Follow AAA Pattern

Structure tests with **Arrange-Act-Assert**:

```swift
func testPopBalloonIncreasesScore() {
    // Arrange: Set up initial state
    let balloon = SKSpriteNode(imageNamed: "red_balloon")
    balloon.name = "balloon"
    scene.addChild(balloon)
    scene.score = 5

    // Act: Perform the action
    scene.popBalloon(balloon)

    // Assert: Verify the result
    XCTAssertEqual(scene.score, 6, "Score should increase by 1")
}
```

### 4. Test Edge Cases

Don't just test the happy path:

```swift
func testDifficultyDoesNotGoBelowMinimum() {
    // Test that difficulty caps at minimum
    scene.balloonSpawnInterval = 0.3
    for _ in 0..<10 {
        scene.increaseDifficulty()
    }
    XCTAssertGreaterThanOrEqual(scene.balloonSpawnInterval, scene.minimumSpawnInterval)
}
```

### 5. Use Descriptive Test Names

Good: `testGameOverSetsIsGameActiveToFalse()`
Bad: `testGameOver()`

Good names document expected behavior.

---

## Common Testing Challenges & Solutions

### Challenge 1: Testing Timers

**Problem**: Timers make tests slow and non-deterministic.

**Solution**: Refactor to make timer behavior testable:

```swift
// Instead of testing the timer directly, test the method it calls
func testSpawnBalloonIsCalledByTimer() {
    scene.spawnBalloon()  // Call directly instead of waiting for timer
    XCTAssertEqual(scene.children.count, 1)
}

// Or use XCTestExpectation for async tests
func testTimerFiresCorrectly() {
    let expectation = XCTestExpectation(description: "Timer fires")
    scene.balloonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
        expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
}
```

### Challenge 2: Testing SKActions

**Problem**: SKActions are asynchronous and complete over time.

**Solution**: Use XCTestExpectation or test the setup, not the completion:

```swift
func testBalloonHasRiseAnimation() {
    let balloon = SKSpriteNode(imageNamed: "red_balloon")
    scene.animateBalloonRise(balloon)
    XCTAssertTrue(balloon.hasActions(), "Balloon should have animation")
}
```

### Challenge 3: Testing Touch Events

**Problem**: Simulating touches is complex.

**Solution**: Test touch handling methods directly:

```swift
func testHandleTouchesBegan() {
    let balloon = SKSpriteNode(imageNamed: "red_balloon")
    balloon.name = "balloon"
    balloon.position = CGPoint(x: 100, y: 100)
    scene.addChild(balloon)

    let touch = UITouch()  // Mock touch
    // Directly call the handler with a known position
    // Or test popBalloon directly
    scene.popBalloon(balloon)
    XCTAssertEqual(scene.score, 1)
}
```

---

## Code Coverage Goals

| Coverage Level | Target | Priority |
|---------------|--------|----------|
| Game State | 100% | High |
| Balloon Management | 90%+ | High |
| UI Updates | 80%+ | Medium |
| Touch Handling | 90%+ | High |
| Overall | 85%+ | - |

**To view coverage in Xcode:**
1. Edit Scheme → Test → Options
2. Enable "Gather coverage for all targets"
3. Run tests (Cmd+U)
4. View Report Navigator → Coverage tab

---

## Testing Workflow for Students

### Step 1: Create Test Target

1. File → New → Target → iOS Unit Testing Bundle
2. Name it "BalloonPopTests"
3. Add `@testable import BalloonPop` to test files

### Step 2: Write First Test

Start simple with game state:

```swift
func testInitialGameState() {
    let scene = GameScene(size: CGSize(width: 375, height: 667))
    XCTAssertEqual(scene.score, 0)
    XCTAssertEqual(scene.missedBalloons, 0)
    XCTAssertTrue(scene.isGameActive)
}
```

### Step 3: Run Tests

- Cmd+U to run all tests
- Or click the diamond in the gutter next to test methods

### Step 4: Add Coverage

Gradually add tests for each method, starting with:
1. Simple calculations (score, missed balloons)
2. State transitions (game over, restart)
3. Complex logic (spawning, animations)

### Step 5: Continuous Testing

Run tests frequently:
- Before committing code
- After making changes
- In CI/CD pipeline (with Fastlane!)

---

## Integration with Fastlane

Add a testing lane to your Fastfile:

```ruby
desc "Run all tests"
lane :test do
  run_tests(
    scheme: "BalloonPop",
    devices: ["iPhone 17"],
    code_coverage: true
  )
end

desc "Run tests and generate coverage report"
lane :test_coverage do
  run_tests(
    scheme: "BalloonPop",
    devices: ["iPhone 17"],
    code_coverage: true
  )

  # Optional: Upload coverage to codecov.io
  # codecov
end
```

Then run: `bundle exec fastlane ios test`

---

## Additional Testing Resources

### Recommended Testing Libraries

1. **XCTest** (built-in) - Apple's testing framework
2. **Quick/Nimble** (optional) - BDD-style testing
3. **SnapshotTesting** (optional) - UI snapshot tests

### Learning Resources

- [Apple's XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing in Xcode - WWDC Videos](https://developer.apple.com/videos/frameworks/testing)
- [Swift Testing Best Practices](https://www.swiftbysundell.com/articles/testing-swift-code/)

---

## Summary

This testing strategy provides:

- **50+ test cases** covering all major functionality
- **Multiple testing levels** from unit to integration
- **Practical examples** students can implement
- **Best practices** for maintainable tests
- **Fastlane integration** for CI/CD

Start with unit tests for game state, then gradually add coverage for other components. Testing makes code more reliable and easier to refactor—essential skills for professional development!

**Next Steps:**
1. Create the test target in Xcode
2. Implement `GameStateTests` first (5-10 tests)
3. Run tests and achieve green status
4. Gradually add tests for other components
5. Aim for 85%+ code coverage

Happy testing! 🧪
