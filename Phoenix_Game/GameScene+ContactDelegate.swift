//
//  GameScene+ContactDelegate.swift
//  Phoenix_Game
//
//  Created by Alumne on 1/6/21.
//

import GameplayKit
import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        guard let nameA = nodeA.name, let nameB = nodeB.name else { return }

        let oneNodeIsEnemy = nameA.hasPrefix("enemy") || nameB.hasPrefix("enemy")
        let oneNodeIsShoot = nameA == "shoot" || nameB == "shoot"
        let oneNodeIsBomb = nameA == "bomb" || nameB == "bomb"
        let oneNodeIsShip = nameA == "spaceship" || nameB == "spaceship"
        

        if oneNodeIsEnemy, oneNodeIsShoot {
            nodeA.removeFromParent()
            nodeB.removeFromParent()

            self.score += 1
            self.scoreLabel.text = "SCORE: \(self.score)"
            return
        }
        
        if oneNodeIsBomb, oneNodeIsShip {
            nodeA.removeFromParent()
            nodeB.removeFromParent()

            self.score += 1
            self.scoreLabel.text = "GAME OVER"
            return
        }
    }
}
