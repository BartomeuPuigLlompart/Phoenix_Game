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
        let shieldEnabled = nameA == "shield" || nameB == "shield"
        let oneBossSurface = nodeA.parent?.name == "boss" || nodeB.parent?.name == "boss"

        if oneNodeIsEnemy, oneNodeIsShoot {
            guard let enemy = (nameA.hasPrefix("enemy") ? nodeA : nodeB) as? SKSpriteNode else {return}
            let shoot = nameA == "shoot" ? nodeA : nodeB
            self.enemyContact(enemy: enemy, shoot: shoot)
        }
        if oneBossSurface, oneNodeIsShoot {
            guard let surface = (nameA.hasPrefix("shoot") ? nodeB : nodeA) as? SKSpriteNode else {return}
            let shoot = nameA == "shoot" ? nodeA : nodeB

            self.bossContact(surface: surface, shoot: shoot)
        }
        if oneNodeIsBomb || oneBossSurface || oneNodeIsEnemy, oneNodeIsShip || shieldEnabled {
            /*nodeA.removeFromParent()
            nodeB.removeFromParent()
            self.scoreLabel.text = "GAME OVER"*/
            self.checkImpact(nodeA: nodeA, nodeB: nodeB, shield: shieldEnabled)
        }
    }

    func checkImpact(nodeA: SKNode, nodeB: SKNode, shield: Bool) {
        guard let nameA = nodeA.name, let nameB = nodeB.name else { return }
        if nameA == "spaceship" || nameA == "shield" {
            nodeB.removeFromParent()
        } else {
            nodeA.removeFromParent()
        }
        if !shield {
            self.ship.physicsBody = nil
            self.lives -= 1
            self.livesLabel.text = "Lives: \(self.lives)"
            self.deadAnim = true
            self.ship.run(SKAction.sequence([SKAction.repeat(SKAction.animate(
                                            with: [SKTexture(imageNamed: "ship_rip_1"), SKTexture(imageNamed: "ship_rip_2")],
                                            timePerFrame: 0.1,
                                            resize: false,
                                                                restore: true), count: 5), SKAction.setTexture(SKTexture(imageNamed: "ship_sprite")), SKAction.run {
                                                                    self.deadAnim = false
                                                                    if self.lives > 0 {
                                                                        self.loadScene(scene: self.gameState)

                                                                    } else {
                                                                        self.lives = 6
                                                                        self.livesLabel.text = "Lives: \(self.lives)"
                                                                        if self.score > self.highScore {
                                                                            self.highScore = self.score
                                                                        }
                                                                        self.highScoreLabel.text = "HIGH SCORE: \(self.highScore)"
                                                                        self.score = 0
                                                                        self.scoreLabel.text = "SCORE: \(self.score)"
                                                                        self.loadScene(scene: .MENU)
                                                                    }
                                                                }]))
        }
    }

    func bossContact(surface: SKSpriteNode, shoot: SKNode) {
        switch surface.name?.prefix(5) {
        case "plate":
            if surface.name?.last == "3" {
                surface.texture = nil
                surface.physicsBody = nil
                surface.name = "plate_tile_0"
            } else {
                surface.texture = SKTexture(imageNamed: "plate_tile_3")
                surface.name = "plate_tile_3"
            }
        case "base_":
            guard let str = String((surface.name?.last)!) as? String else {return}
            guard let num = Int(str) as? Int else {return}
            if (1 + num) <= 5 {
            surface.texture = SKTexture(imageNamed: "base_tile_\(num + 1)")
           surface.name = "base_tile_\(num + 1)"
            } else {
                surface.texture = nil
                surface.physicsBody = nil
                surface.name = "base_tile_0"
                print(self.boss.node.position.y)
                for tile in 0 ... 2 {
                    if boss.baseGrid[tile + 1][Int((surface.position.x + 272) / 32)].texture != nil {
                boss.baseGrid[tile][Int((surface.position.x + 272) / 32)].texture = SKTexture(imageNamed: "base_tile_1")
                boss.baseGrid[tile][Int((surface.position.x + 272) / 32)].name = "base_tile_1"
                    } else if boss.baseGrid[tile][Int((surface.position.x + 272) / 32)].name?.last == "1" {
                        boss.baseGrid[tile][Int((surface.position.x + 272) / 32)].texture = SKTexture(imageNamed: "base_tile_2")
                        boss.baseGrid[tile][Int((surface.position.x + 272) / 32)].name = "base_tile_2"
                    }
                }
            }
        case "alien":
            for child in self.boss.node.children {
                if child.name != "bomb" {
                    self.loadKillAnim(pos: child.position, bonus: false, type2: false, wingCut: false)
                }
            }
            let bossKillPos = self.boss.node.position
            surface.parent?.removeFromParent()
            for enemy in self.enemies {
                enemy.node.removeFromParent()
            }
            let addedScore = Int.random(in: 10..<91) * 100
            self.score += addedScore
            self.scoreLabel.text = "SCORE: \(self.score)"
            let addedScoreLabel = SKLabelNode(text: "\(addedScore)")
            addedScoreLabel.position = bossKillPos
            addedScoreLabel.fontName = "ARCADECLASSIC"
            addedScoreLabel.fontColor = UIColor(red: 1, green: 0, blue: 211 / 2550, alpha: 1)
            addedScoreLabel.run(SKAction.sequence([SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
            self.addChild(addedScoreLabel)
        default:
            return
        }
        shoot.removeFromParent()
    }

    func enemyContact(enemy: SKSpriteNode, shoot: SKNode) {
        let addedScoreLabel = SKLabelNode()
        var addedScore = 0
        guard let enemyNum = (enemy.name?[(enemy.name?.index(enemy.name!.startIndex, offsetBy: 6))!]) else {return}
        switch enemyNum {
        case "1":
            let diagonalSpeed: Double = 600
            let enemySpeed = (simd_length(_: simd_double2(x: Double(enemy.physicsBody?.velocity.dx ?? 0), y: Double(enemy.physicsBody?.velocity.dy ?? 0))))
            let normalScore = [20, 40, 80]
            let isBonus = (enemySpeed > diagonalSpeed)
            addedScore = isBonus ? 200 : normalScore[(Int.random(in: 0..<3))]
            self.loadKillAnim(pos: enemy.position, bonus: isBonus, type2: self.gameState == .LEVEL2 || self.gameState == .LEVEL5, wingCut: false)
            addedScoreLabel.position = enemy.position
            addedScoreLabel.fontName = "ARCADECLASSIC"
            addedScoreLabel.fontColor = UIColor(red: 1, green: 0, blue: 211 / 2550, alpha: 1)
            addedScoreLabel.text = "\(addedScore)"
            addedScoreLabel.run(SKAction.sequence([SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
            enemy.removeFromParent()
        case "2":
            let offsetHit: CGFloat = 16
            guard var bounce = enemy.physicsBody?.restitution else {return}
            if abs(enemy.position.x - shoot.position.x) < offsetHit || enemy.texture?.size().width ?? 25.0 < 23.0 {
                let isBonus = !(enemy.texture?.size().width ?? 25.0 < 23.0)
                addedScore = isBonus ? Int.random(in: 10..<81) * 10 : Int.random(in: 1..<3) * 50
                self.loadKillAnim(pos: enemy.position, bonus: isBonus, type2: self.gameState == .LEVEL4, wingCut: false)
                addedScoreLabel.position = enemy.position
                addedScoreLabel.fontName = "ARCADECLASSIC"
                addedScoreLabel.fontColor = UIColor(red: 1, green: 0, blue: 211 / 2550, alpha: 1)
                addedScoreLabel.text = "\(addedScore)"
                addedScoreLabel.run(SKAction.sequence([SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
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
                self.loadKillAnim(pos: CGPoint(x: shoot.position.x, y: enemy.position.y), bonus: false, type2: self.gameState == .LEVEL4, wingCut: true)
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
                self.loadKillAnim(pos: CGPoint(x: shoot.position.x, y: enemy.position.y), bonus: false, type2: self.gameState == .LEVEL4, wingCut: true)
                }
            if addedScore == 0 {
            enemy.size = self.largeSize
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.physicsBody?.restitution = bounce
            enemy.physicsBody?.categoryBitMask = enemyCategory
            enemy.physicsBody?.contactTestBitMask =  shootCategory | shieldCategory
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
        self.addChild(addedScoreLabel)
        return
    }
}
