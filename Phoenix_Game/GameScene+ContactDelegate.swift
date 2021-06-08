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
            let enemy = nameA.hasPrefix("enemy") ? nodeA : nodeB
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
                var offsetHit: CGFloat = 16
                
                if abs(enemy.position.x - shoot.position.x) < offsetHit
                {
                    addedScore = 20
                    //enemy.removeFromParent()
                    print("middle")
                }
                else if enemy.physicsBody?.restitution != 0.2 && shoot.position.x < enemy.position.x
                    {
                    if enemy.physicsBody?.restitution == 0
                    {
                        print("left")
                        enemy.run(enemyAnims[2])
                        enemy.physicsBody?.restitution = 0.2
                    }
                    else if enemy.physicsBody?.restitution == 0.2
                    {
                        print("both")
                        enemy.run(enemyAnims[0])
                        enemy.physicsBody?.restitution = 0.1
                    }
                    }
                else if enemy.physicsBody?.restitution != 0.3{
                    if enemy.physicsBody?.restitution == 0
                    {
                        print("right")
                        enemy.run(enemyAnims[3])
                        enemy.physicsBody?.restitution = 0.3
                    }
                    else if enemy.physicsBody?.restitution == 0.3{
                        print("both")
                        enemy.run(enemyAnims[0])
                        enemy.physicsBody?.restitution = 0.1
                    }
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
