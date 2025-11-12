// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0 and SpriteKit
// Qapla'

import SpriteKit

// MARK: - Touch Handling
/* This extension contains all touch event handling logic
  
   **Note**: Touch handling is fundamental to iOS games. SpriteKit provides several
   touch methods inherited from UIResponder:
   - touchesBegan: When finger touches down
   - touchesMoved: When finger drags
   - touchesEnded: When finger lifts up
   - touchesCancelled: When touch is interrupted (e.g., phone call)
  
   This game uses began for gameplay and ended for menu interactions.
*/
extension GameScene {

    // MARK: - Touch Began

    /* Handle touch-down events during active gameplay
      
       **Note**: This demonstrates several key concepts:
       1. Converting touch coordinates between different coordinate systems
       2. Hit-testing to find which nodes were touched
       3. Filtering nodes by their 'name' property
       4. Early exit patterns with guard statements
      
       - Parameters:
         - touches: Set of UITouch objects (usually just one for single tap)
         - event: The event containing all touches (can be nil)
    */
    func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Exit early if game is not active (prevents touches during game over screen)
        guard isGameActive else { return }

        // Get the first touch from the set
        // **Note**: iOS supports multi-touch, so touches is a Set.
        // For this game, we only care about single touches, so we get .first
        guard let touch = touches.first else { return }

        // Convert touch location from view coordinates to scene coordinates
        // **Note**: Critical concept! Touches come in UIView coordinates,
        // but SpriteKit nodes use scene coordinates. Always convert with location(in:)
        let location = touch.location(in: self)

        // Get all nodes at the touch location
        // **Note**: nodes(at:) returns an array of ALL nodes at that point,
        // from top to bottom (highest zPosition first). This is called "hit testing"
        let touchedNodes = nodes(at: location)

        // Search through touched nodes to find a balloon
        // **Note**: We iterate through nodes checking the 'name' property
        // This is why we set balloon.name = "balloon" when creating balloons
        for node in touchedNodes {
            if node.name == "balloon" {
                // Found a balloon! Pop it
                popBalloon(node)
                break  // Only pop one balloon per touch (prevents scoring multiple times)
            }
        }
    }

  
    // MARK: - Touch Ended

    /* Handle touch-up events for menu interactions (restart button)
      
       **Note**: We use touchesEnded instead of touchesBegan for buttons
       because it feels more natural - the action happens when you lift your finger,
       just like standard iOS buttons. This also allows users to cancel by dragging away.
      
       - Parameters:
         - touches: Set of UITouch objects
         - event: The event containing all touches
    */
    func handleTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Only handle touches when game is NOT active (game over screen)
        // **Note**: Different UI states respond to touches differently.
        // During gameplay: tap balloons. During game over: tap to restart.
        if !isGameActive {
            guard let touch = touches.first else { return }

            // Same coordinate conversion as above
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)

            // Look for the restart button (a label node with name "restart")
            for node in touchedNodes {
                if node.name == "restart" {
                    restartGame()
                    break  // Only need to find one restart button
                }
            }
        }
    }
}
