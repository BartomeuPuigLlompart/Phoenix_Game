//
//  GameScene+AI.swift
//  Phoenix_Game
//
//  Created by Bartomeu on 10/5/21.
//

import Foundation
import SpriteKit

extension GameScene {
    func updateBird() {
        for idx in 0 ... enemies.count - 1 {
            guard enemies[idx].node.parent != nil else { continue }
            switch enemies[idx].state {
            case EnemyState.ATTACKING:
                let xDiff = self.ship.position.x - enemies[idx].node.position.x
                let xAim = xDiff / abs(xDiff) * 100
                enemies[idx].node.physicsBody?.velocity = CGVector(dx: xAim, dy: -500)
                if enemies[idx].node.position.y < (enemies[idx].initialPos.y - (self.size.height / 2)) {
                    if Int.random(in: 0..<2) == 1 {
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
                        enemies[idx].state = EnemyState.FLEE
                        self.enemies[idx].node.run(enemyAnims[0])
                    } else {
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
                continue
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
