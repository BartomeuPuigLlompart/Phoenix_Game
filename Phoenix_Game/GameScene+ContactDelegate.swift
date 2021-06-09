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
            guard let enemy = (nameA.hasPrefix("enemy") ? nodeA : nodeB) as? SKSpriteNode else {return}
            let shoot = nameA == "shoot" ? nodeA : nodeB
            var addedScore = 0
            guard let enemyNum = (enemy.name?[(enemy.name?.index(enemy.name!.startIndex, offsetBy: 6))!]) else {return}
            switch enemyNum {
            case "1":
                let diagonalSpeed: Double = 600
                let enemySpeed = (simd_length(_: simd_double2(x: Double(enemy.physicsBody?.velocity.dx ?? 0), y: Double(enemy.physicsBody?.velocity.dy ?? 0))))
                addedScore = enemySpeed > diagonalSpeed ? (Int.random(in: 1..<25) * 10) : 20
                enemy.removeFromParent()
            case "2":
                let offsetHit: CGFloat = 16
                guard var bounce = enemy.physicsBody?.restitution else {return}
                if abs(enemy.position.x - shoot.position.x) < offsetHit || enemy.texture?.size().width ?? 25.0 < 23.0 {
                    addedScore = 20
                    enemy.removeFromParent()
                    print("middle")
                } else if CGFloat(round(10*bounce)/10) != 0.2 && shoot.position.x < enemy.position.x {
                    if CGFloat(round(10*bounce)/10) == 0 {
                        print("left")
                        enemy.run(SKAction.repeatForever(enemyAnims[2]))
                        bounce = 0.2
                    } else if CGFloat(round(10*bounce)/10) == 0.3 {
                        print("both")
                        enemy.run(SKAction.repeatForever(enemyAnims[0]))
                        bounce = 0.1 }
                } else if CGFloat(round(10*bounce)/10) != 0.3 {
                    if CGFloat(round(10*bounce)/10) == 0 {
                        print("right")
                        enemy.run(SKAction.repeatForever(enemyAnims[3]))
                        bounce = 0.3
                    } else if CGFloat(round(10*bounce)/10) == 0.2 {
                        print("both")
                        enemy.run(SKAction.repeatForever(enemyAnims[0]))
                        bounce = 0.1
                    }
                    }
                if addedScore == 0 {
                enemy.size = self.largeSize
                enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
                enemy.physicsBody?.restitution = bounce
                enemy.physicsBody?.categoryBitMask = 0x0000_0001
                enemy.physicsBody?.contactTestBitMask = 0x0000_0111
                enemy.physicsBody?.collisionBitMask = 0
                enemy.physicsBody?.affectedByGravity = false
                }
            default:
                return
            }
            print(addedScore)
            shoot.removeFromParent()
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
