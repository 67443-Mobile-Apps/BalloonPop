# Setting Up BalloonPop Tests

## Quick Setup (5 minutes)

### Step 1: Add Test Target to Xcode

1. Open `BalloonPop.xcodeproj` in Xcode
2. Click on the project in the navigator (top-level "BalloonPop")
3. At the bottom of the targets list, click the `+` button
4. Select `iOS` → `Unit Testing Bundle`
5. Configure the test bundle:
   - **Product Name**: `BalloonPopTests`
   - **Team**: Your development team
   - **Organization Identifier**: Same as main app
   - **Project**: BalloonPop
   - **Target to be Tested**: BalloonPop
6. Click `Finish`

### Step 2: Add Test Files to the Target

1. In Xcode's Project Navigator, right-click on the `BalloonPopTests` group
2. Select `Add Files to "BalloonPop"...`
3. Navigate to and select the `BalloonPopTests` folder in Finder
4. **Important**: Make sure these options are checked:
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: BalloonPopTests
5. Click `Add`

### Step 3: Configure Test Target Settings

1. Select the `BalloonPopTests` target
2. Go to `Build Settings`
3. Search for "Test Host"
4. Verify it's set to: `$(BUILT_PRODUCTS_DIR)/BalloonPop.app/BalloonPop`

### Step 4: Run the Tests

**Option A: Run All Tests**
- Press `Cmd+U` (or Product → Test)

**Option B: Run Specific Test**
- Click the diamond icon next to any test method in `GameStateTests.swift`

**Option C: Run Test Class**
- Click the diamond icon next to the class name

### Step 5: View Test Results

- Open the Test Navigator (`Cmd+6`)
- See all tests with pass/fail status
- Click any test to see details or jump to code

## Understanding the Test Output

### Green Checkmark ✅
Test passed! The behavior matches expectations.

### Red X ❌
Test failed. Look at the failure message to see what went wrong.

Example:
```
XCTAssertEqual failed: ("5") is not equal to ("0") - Score should be reset to 0 after restart
```

This tells you exactly what value was expected vs. what was received.

## Viewing Code Coverage

### Enable Coverage Collection

1. Edit the scheme: Product → Scheme → Edit Scheme (or `Cmd+<`)
2. Select `Test` in the left sidebar
3. Go to the `Options` tab
4. Check ✅ `Gather coverage for some targets`
5. Click `+` and add `BalloonPop`
6. Click `Close`

### View Coverage Report

1. Run tests (`Cmd+U`)
2. Open Report Navigator (`Cmd+9`)
3. Select the latest test run
4. Click the `Coverage` tab
5. You'll see coverage percentage for each file

**Target**: Aim for 85%+ coverage on game logic files.

## Troubleshooting

### "No such module 'BalloonPop'"

**Fix**: Make sure the main app target builds successfully first:
```
Product → Build (Cmd+B)
```

### Tests Build but Don't Run

**Fix**: Check the Test Host setting:
1. Select `BalloonPopTests` target
2. Build Settings → Test Host
3. Should be: `$(BUILT_PRODUCTS_DIR)/BalloonPop.app/BalloonPop`

### "Cannot find 'GameScene' in scope"

**Fix**: Make sure the import statement is correct:
```swift
@testable import BalloonPop
```

The `@testable` keyword gives tests access to internal types.

### Timers Interfering with Tests

**Fix**: The `tearDown()` method invalidates timers. If issues persist:
```swift
override func tearDown() {
    scene.balloonTimer?.invalidate()
    scene.difficultyTimer?.invalidate()
    scene = nil
    view = nil
    super.tearDown()
}
```

## Test Organization Best Practices

### Current Structure
```
BalloonPopTests/
├── Unit/
│   └── GameStateTests.swift     ✅ Created
└── SETUP_INSTRUCTIONS.md        ✅ You are here
```

### Future Structure (as you add more tests)
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
    ├── TestHelpers.swift
    └── MockObjects.swift
```

## Running Tests in Fastlane

Once tests are set up, you can run them via Fastlane:

```bash
bundle exec fastlane ios test
```

This will:
- Build the app
- Run all tests
- Generate coverage report
- Display results

## Next Steps

1. ✅ Run `GameStateTests` and verify all 24 tests pass
2. Review test failures (if any) and fix issues
3. Check code coverage for `GameScene+GameState.swift`
4. Add tests for other components (BalloonManagement, UI, etc.)
5. Integrate tests into your CI/CD pipeline

## Understanding the Tests

### Test Structure (AAA Pattern)

Each test follows this pattern:

```swift
func testSomeBehavior() {
    // Arrange: Set up the test conditions
    scene.score = 5

    // Act: Perform the action being tested
    scene.score += 1

    // Assert: Verify the expected result
    XCTAssertEqual(scene.score, 6, "Score should increment by 1")
}
```

### Test Categories in GameStateTests

1. **Initial State Tests** (3 tests)
   - Verify game starts correctly

2. **Game Over Tests** (5 tests)
   - Verify game over transition works

3. **Restart Tests** (6 tests)
   - Verify restart resets everything

4. **Score Tracking Tests** (3 tests)
   - Verify score mechanics work

5. **Missed Balloons Tests** (5 tests)
   - Verify miss tracking and game over trigger

6. **Edge Cases Tests** (2 tests)
   - Verify unusual scenarios work

**Total: 24 comprehensive tests**

## Quick Reference: XCTest Assertions

```swift
XCTAssertEqual(a, b)              // a equals b
XCTAssertNotEqual(a, b)           // a not equal to b
XCTAssertTrue(condition)          // condition is true
XCTAssertFalse(condition)         // condition is false
XCTAssertNil(value)               // value is nil
XCTAssertNotNil(value)            // value is not nil
XCTAssertGreaterThan(a, b)        // a > b
XCTAssertLessThan(a, b)           // a < b
XCTAssertGreaterThanOrEqual(a, b) // a >= b
XCTAssertLessThanOrEqual(a, b)    // a <= b
```

Each assertion can have an optional message:
```swift
XCTAssertEqual(score, 10, "Score should be 10 after 10 pops")
```

---

**Need Help?** Check the [Testing Strategy](../TESTING_STRATEGY.md) for detailed explanations and more test examples.
