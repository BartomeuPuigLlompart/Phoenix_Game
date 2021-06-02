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
            let enemy = nameA.hasPrefix("enemy") ? nodeA : nodeB
            var addedScore = 0
            guard let enemyNum = (enemy.name?[(enemy.name?.index(enemy.name!.startIndex, offsetBy: 6))!]) else {return}
            switch enemyNum {
            case "1":
                let diagonalSpeed: Double = 600
                let enemySpeed = (simd_length(_: simd_double2(x: Double(enemy.physicsBody?.velocity.dx ?? 0), y: Double(enemy.physicsBody?.velocity.dy ?? 0))))
                addedScore = enemySpeed > diagonalSpeed ? (Int.random(in: 1..<25) * 10) : 20
            default:
                return
            }
            print(addedScore)
            self.score += addedScore
            self.scoreLabel.text = "SCORE: \(self.score)"
            return
        }
        
        if oneNodeIsBomb, oneNodeIsShip {
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            self.scoreLabel.text = "GAME OVER"
            return
        }
    }
}
