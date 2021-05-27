//
//  GameScene+AI.swift
//  Phoenix_Game
//
//  Created by Bartomeu on 10/5/21.
//

import Foundation
import SpriteKit

extension GameScene {
    @objc
    func enemyShoot(sender: Timer) {
        guard let enemyStruct = sender.userInfo as? Enemy else { return}
        if enemyStruct.node != nil
        {
            let sprite = SKSpriteNode(imageNamed: "Shoot")
            sprite.position = enemyStruct.node.position
            sprite.name = "bomb"
            sprite.zPosition = 1
            sprite.size = CGSize(width: sprite.size.width, height: sprite.size.height * 3)
            addChild(sprite)
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.linearDamping = 0
            sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
            sprite.physicsBody?.contactTestBitMask = 0x0000_0100
            sprite.physicsBody?.collisionBitMask = 0
            Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 5..<20), target: self, selector:#selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats:false)
        }
    }
    
    func updateBird() {
        for idx in 0 ... enemies.count - 1 {
            guard enemies[idx].node.parent != nil else { continue }
            switch enemies[idx].state {
            case EnemyState.ATTACKING:
                let xDiff = self.ship.position.x - enemies[idx].node.position.x
                let xAim = xDiff / abs(xDiff) * 100
                enemies[idx].node.physicsBody?.velocity = CGVector(dx: xAim, dy: -500)
                if enemies[idx].node.position.y < (enemies[idx].initialPos.y - (self.size.height / 2)) {
                    if Int.random(in: 0..<3) == 1 {
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
                        enemies[idx].state = EnemyState.FLEE
                        self.enemies[idx].node.run(enemyAnims[0])
                    } else if Int.random(in: 0..<2) == 1 {
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        enemies[idx].state = EnemyState.LOOPING
                        enemies[idx].flipCenter = CGPoint(x: enemies[idx].flipRad, y: enemies[idx].node.position.y)
                        enemies[idx].flipAngle = CGFloat.pi
                        enemies[idx].node.removeAllActions()
                        enemies[idx].node.texture = SKTexture(imageNamed: "enemy_1_1_flip_1")
                    }
                    else {
                        enemies[idx].state = EnemyState.KAMIKAZE
                    }
                }
            case .KAMIKAZE:
                let xDiff = self.ship.position.x - enemies[idx].node.position.x
                let xAim = xDiff / abs(xDiff) * 100
                enemies[idx].node.physicsBody?.velocity = CGVector(dx: xAim, dy: -500)
                if enemies[idx].node.position.y < self.ship.position.y {
                    if Int.random(in: 0..<2) == 1 {
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
                        enemies[idx].state = EnemyState.FLEE
                        self.enemies[idx].node.run(enemyAnims[0])
                    } else {
                        enemies[idx].state = EnemyState.RETURN
                        var returnDirection = CGVector(dx: enemies[idx].initialPos.x - enemies[idx].node.position.x, dy: enemies[idx].initialPos.y - enemies[idx].node.position.y)
                        returnDirection = CGVector(dx: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).x * 500.0,
                                                   dy: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).y * 500.0)
                        enemies[idx].node.physicsBody?.velocity = returnDirection
                        self.enemies[idx].node.run(enemyAnims[2])
                    }
                }
            case EnemyState.LOOPING:
                enemies[idx].node.position.x = enemies[idx].flipCenter.x + cos(enemies[idx].flipAngle) * enemies[idx].flipRad
                enemies[idx].node.position.y = enemies[idx].flipCenter.y + sin(enemies[idx].flipAngle) * enemies[idx].flipRad
                enemies[idx].flipAngle += (self.dt * 3.5)
                enemies[idx].node.zRotation = enemies[idx].flipAngle + CGFloat.pi
                if enemies[idx].flipAngle > (CGFloat.pi * 3)
                {
                    enemies[idx].node.zRotation = 0.0
                    enemies[idx].node.position = CGPoint(x: enemies[idx].flipCenter.x - enemies[idx].flipRad, y: enemies[idx].flipCenter.y)
                    if Int.random(in: 0..<2) == 1 {
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
                        enemies[idx].state = EnemyState.FLEE
                        self.enemies[idx].node.run(enemyAnims[0])
                    }
                    else {
                        enemies[idx].state = EnemyState.KAMIKAZE
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
                        enemies[idx].node.run(enemyAnims[1])
                    }
                }
            case EnemyState.FLEE, .RETURN:
                if enemies[idx].node.position.x < (enemies[idx].initialPos.x - (self.size.width / 3)) {
                    var rDir = CGVector(dx: (enemies[idx].initialPos.x + (self.size.width / 3)) - enemies[idx].node.position.x, dy: (enemies[idx].initialPos.y - enemies[idx].node.position.y) / 2.0)
                    rDir = CGVector(dx: simd_normalize(simd_double2(x: Double(rDir.dx), y: Double(rDir.dy))).x * 750.0,
                                               dy: simd_normalize(simd_double2(x: Double(rDir.dx), y: Double(rDir.dy))).y * 750.0)
                    enemies[idx].node.physicsBody?.velocity = rDir
                    self.enemies[idx].node.run(enemyAnims[4])
                } else if enemies[idx].node.position.x > (enemies[idx].initialPos.x + (self.size.width / 3)) {
                    var returnDirection = CGVector(dx: enemies[idx].initialPos.x - enemies[idx].node.position.x, dy: enemies[idx].initialPos.y - enemies[idx].node.position.y)
                    returnDirection = CGVector(dx: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).x * 750.0,
                                               dy: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).y * 750.0)
                    enemies[idx].node.physicsBody?.velocity = returnDirection
                    self.enemies[idx].node.run(enemyAnims[5])
                } else if enemies[idx].node.position.y > enemies[idx].initialPos.y {
                    enemies[idx].node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    enemies[idx].node.position = enemies[idx].initialPos
                    enemies[idx].state = EnemyState.STANDBY
                    self.enemies[idx].node.run(enemyAnims[0])
                }

            default:
                continue
            }
        }
    }
}
