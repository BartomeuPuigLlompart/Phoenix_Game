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
        for index in 0 ... enemies.count - 1
        {
            guard enemies[index].node.parent != nil else { continue }
            switch enemies[index].state
            {
            case EnemyState.ATTACKING:
                if enemies[index].node.position.y < (enemies[index].initialPos.y - (self.size.height / 2))
                {
                    if(Int.random(in: 0..<2) == 1){
                    enemies[index].node.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
                    enemies[index].state = EnemyState.FLEE
                    }
                    else {
                        enemies[index].state = EnemyState.KAMIKAZE
                    }
                }
            case .KAMIKAZE:
                if enemies[index].node.position.y < self.ship.position.y
                {
                    if(Int.random(in: 0..<2) == 1){
                    enemies[index].node.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
                    enemies[index].state = EnemyState.FLEE
                    }
                    else {
                        enemies[index].state = EnemyState.RETURN
                        enemies[index].node.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
                    }
                }
            case EnemyState.LOOPING:
                continue
            case EnemyState.FLEE, .RETURN:
                if enemies[index].node.position.x < (enemies[index].initialPos.x - (self.size.width / 3))
                {
                    var returnDirection = CGVector(dx: (enemies[index].initialPos.x + (self.size.width / 3)) - enemies[index].node.position.x, dy: (enemies[index].initialPos.y - enemies[index].node.position.y) / 2.0)
                    returnDirection = CGVector(dx: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).x * 750.0,
                                               dy: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).y * 750.0)
                    enemies[index].node.physicsBody?.velocity = returnDirection
                    
                }
                else if enemies[index].node.position.x > (enemies[index].initialPos.x + (self.size.width / 3))
                {
                    var returnDirection = CGVector(dx: enemies[index].initialPos.x - enemies[index].node.position.x, dy: enemies[index].initialPos.y - enemies[index].node.position.y)
                    returnDirection = CGVector(dx: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).x * 750.0,
                                               dy: simd_normalize(simd_double2(x: Double(returnDirection.dx), y: Double(returnDirection.dy))).y * 750.0)
                    enemies[index].node.physicsBody?.velocity = returnDirection
                }
                else if enemies[index].node.position.y > enemies[index].initialPos.y
                {
                    enemies[index].node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    enemies[index].node.position = enemies[index].initialPos
                    enemies[index].state = EnemyState.STANDBY
                }
                
            default:
                continue
            }
        }
    }
}
