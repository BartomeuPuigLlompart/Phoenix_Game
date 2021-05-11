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
                    enemies[index].node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }//random state atacking, flee or looping
                
            case EnemyState.LOOPING:
                continue
            case EnemyState.FLEE:
                continue
            default:
                continue
            }
        }
    }
}
