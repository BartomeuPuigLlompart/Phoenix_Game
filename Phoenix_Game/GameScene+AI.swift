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
    func setNewAttackers(sender: Timer) {
        guard var idx = sender.userInfo as? Int else { return}
        if gameState == .LEVEL3 { return }
        if self.enemies[idx].node.parent != nil {
            var range: Int
            switch gameState {
            case .LEVEL1:
                range = 70
            case .LEVEL2:
                range = 90
            case .LEVEL5:
                range = 10
            default:
                return
            }
            if greenFlag && self.attackingEnemiesCounter < self.attackingEnemiesLimit && self.enemies[idx].state == .STANDBY && Int.random(in: 0..<101) < (range) {
                self.enemies[idx].state = EnemyState.ATTACKING
                self.enemies[idx].node.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
                self.enemies[idx].node.run(enemyAnims[1])
                self.greenFlag = false
                var interval = TimeInterval.random(in: 10..<16)
                self.enemies[idx].timers[1] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(setNewAttackers(sender:)), userInfo: idx, repeats: false)
                Timer.scheduledTimer(timeInterval: TimeInterval(self.deltaTime * 20), target: self, selector: #selector(setGreenFlag), userInfo: nil, repeats: false)
            }
            Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 1..<4), target: self, selector: #selector(setNewAttackers(sender:)), userInfo: idx, repeats: false)
        }
    }

    @objc
    func setNewPhoenixAnim(sender: Timer) {
        guard var idx = sender.userInfo as? Int else { return}
        if self.enemies[idx].node.parent != nil {
            guard let enemyNum = (enemies[idx].node.name?[(enemies[idx].node.name?.index(enemies[idx].node.name!.startIndex, offsetBy: 8))!]) else {return}
            guard let bounce = enemies[idx].node.physicsBody?.restitution else {return}
            switch CGFloat(round(10*bounce)/10) {
            case 0.1:
                enemies[idx].state = .BOTHHURT
            case 0.2:
                enemies[idx].state = .LEFTHURT
            case 0.3:
                enemies[idx].state = .RIGHTHURT
            default:
                break
            }
            print("Bounce: \(bounce)")
            print("State: \(enemies[idx].state)")
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(setNewPhoenixAnim(sender:)), userInfo: idx, repeats: false)
            switch self.enemies[idx].state {
            case .EGGSPAWN:
                enemies[idx].node.texture = SKTexture(imageNamed: "enemy_2_\(enemyNum)_spawn_8")
                enemies[idx].node.physicsBody = SKPhysicsBody(texture: enemies[idx].node.texture!, size: enemies[idx].node.size)
                self.enemies[idx].node.run(enemyAnims[6])
                self.enemies[idx].state = .EGGINCUBATION
            case .EGGINCUBATION:
                enemies[idx].node.texture = SKTexture(imageNamed: "enemy_2_\(enemyNum)_short_1")
                enemies[idx].node.physicsBody = SKPhysicsBody(texture: enemies[idx].node.texture!, size: enemies[idx].node.size)
                self.enemies[idx].node.run(SKAction.sequence([enemyAnims[7], SKAction.repeatForever(enemyAnims[4])]))
                self.enemies[idx].state = .EGGHATCH
            case .EGGHATCH:
                enemies[idx].node.texture = SKTexture(imageNamed: "enemy_2_\(enemyNum)_short_1")
                enemies[idx].node.physicsBody = SKPhysicsBody(texture: enemies[idx].node.texture!, size: enemies[idx].node.size)
                self.enemies[idx].node.run(SKAction.repeatForever(enemyAnims[4]))
                self.enemies[idx].state = .SHORT
            case .SHORT, .LARGE:
                var randValue = Int.random(in: 0..<2)

                if randValue == 0 {
                    if self.enemies[idx].state == .SHORT { return }
                    self.enemies[idx].node.size = self.shortSize
                self.enemies[idx].node.run(SKAction.sequence([enemyAnims[8].reversed(), SKAction.repeatForever(enemyAnims[4])]))
                self.enemies[idx].state = .SHORT
                    print(self.enemies[idx].node.size)
                } else if randValue == 1 {
                    if self.enemies[idx].state == .LARGE { return }
                    self.enemies[idx].node.size = self.largeSize
                    self.enemies[idx].node.run(SKAction.sequence([enemyAnims[8], SKAction.repeatForever(enemyAnims[1])]))
                    self.enemies[idx].state = .LARGE
                    print(self.enemies[idx].node.size)
                }
                enemies[idx].node.physicsBody = SKPhysicsBody(texture: enemies[idx].node.texture!, size: enemies[idx].node.size)
            case .BOTHHURT:
                var position = enemies[idx].node.position
                enemies[idx].node.removeFromParent()
                enemies[idx].node = SKSpriteNode(texture: SKTexture(imageNamed: "enemy_2_\(enemyNum)_spawn_5"))
                enemies[idx].node.size = CGSize(width: enemies[idx].node.size.width * 4, height: enemies[idx].node.size.height * 4)
                enemies[idx].node.physicsBody = SKPhysicsBody(texture: enemies[idx].node.texture!, size: enemies[idx].node.size)
                enemies[idx].node.name = "enemy_2_\(enemyNum)"
                enemies[idx].state = .EGGSPAWN
                enemies[idx].node.run(enemyAnims[5])
                enemies[idx].node.position = position
                self.addChild(self.enemies[idx].node)
                Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 9..<12), target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemies[idx].node, repeats: false)
            default:
                print("Default")
                return
            }
            enemies[idx].node.physicsBody?.restitution = 0
            enemies[idx].node.physicsBody?.categoryBitMask = enemyCategory
            enemies[idx].node.physicsBody?.contactTestBitMask = shootCategory | shieldCategory
            enemies[idx].node.physicsBody?.collisionBitMask = 0
            enemies[idx].node.physicsBody?.affectedByGravity = false
        }
    }

    func updatePhoenix() {
        var stillAlive = false
        var hatch = false
        for idx in 0 ... enemies.count - 1 {
            guard enemies[idx].node.parent != nil else { continue }
            stillAlive = true
            hatch = ((CGFloat.pi * 7) < enemies[idx].flipAngle)
            var newPos = enemies[idx].flipCenter.x + cos(enemies[idx].flipAngle) * enemies[idx].flipRad
            if !hatch {enemies[idx].node.position.x = newPos} else {
                enemies[idx].node.position.x += (newPos - enemies[idx].node.position.x) * self.deltaTime
            }
            enemies[idx].node.position.y =  enemies[idx].initialPos.y + self.globalY
            if hatch && abs(enemies[idx].node.position.x) < 10 {
                // print("now")
                enemies[idx].flipRad = CGFloat.random(in: 300 ..< 1000)
            }
            enemies[idx].flipAngle += (self.deltaTime * (2.5 + ((hatch ? 1 : 0))))
        }
        if hatch {
            self.globalY += ((self.nextGlobalY - self.globalY) * self.deltaTime * 0.25)
            if abs(self.nextGlobalY - self.globalY) < 75 {
                self.nextGlobalY = CGFloat.random(in: 0 ..< 500) * (self.nextGlobalY * -1 / abs(self.nextGlobalY))
            }
        }
        if !stillAlive && self.changeLevelTimer == nil {
            // self.scoreLabel.text = "You Win"
            gameState = gameState == .LEVEL3 ? .LEVEL4 : .LEVEL5

            self.loadScene(scene: gameState)
        }
    }

    func updateBird() {
        var stillAlive = false
        self.attackingEnemiesCounter = 0
        for idx in 0 ... enemies.count - 1 {
            guard enemies[idx].node.parent != nil else { continue }
            stillAlive = true
            self.attackingEnemiesCounter += 1
            switch enemies[idx].state {
            case EnemyState.ATTACKING:
                let xDiff = self.ship.position.x - enemies[idx].node.position.x
                let xAim = xDiff / abs(xDiff) * 200
                enemies[idx].node.physicsBody?.velocity = CGVector(dx: xAim, dy: -500)
                if enemies[idx].node.position.y < ((enemies[idx].initialPos.y + self.ship.position.y) / 2) {
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
                        guard let enemyNum = (enemies[idx].node.name?[(enemies[idx].node.name?.index(enemies[idx].node.name!.startIndex, offsetBy: 8))!]) else {continue}
                        enemies[idx].node.texture = SKTexture(imageNamed: "enemy_1_\(enemyNum)_flip_1")
                    } else {
                        enemies[idx].state = EnemyState.KAMIKAZE
                    }
                }
            case .KAMIKAZE:
                let xDiff = self.ship.position.x - enemies[idx].node.position.x
                let xAim = xDiff / abs(xDiff) * 200
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
                enemies[idx].flipAngle += (self.deltaTime * 3.5)
                enemies[idx].node.zRotation = enemies[idx].flipAngle + CGFloat.pi
                if enemies[idx].flipAngle > (CGFloat.pi * 3) {
                    enemies[idx].node.zRotation = 0.0
                    enemies[idx].node.position = CGPoint(x: enemies[idx].flipCenter.x - enemies[idx].flipRad, y: enemies[idx].flipCenter.y)
                    if Int.random(in: 0..<2) == 1 {
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
                        enemies[idx].state = EnemyState.FLEE
                        self.enemies[idx].node.run(enemyAnims[0])
                    } else {
                        enemies[idx].state = EnemyState.KAMIKAZE
                        enemies[idx].node.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
                        enemies[idx].node.run(enemyAnims[1])
                    }
                }
            case EnemyState.FLEE, .RETURN:
                let diagonalSpeed: Double = 600
                let enemySpeed = (simd_length(_: simd_double2(x: Double(enemies[idx].node.physicsBody?.velocity.dx ?? 0), y: Double(enemies[idx].node.physicsBody?.velocity.dy ?? 0))))
                if enemies[idx].state == .FLEE && enemies[idx].node.position.x < (enemies[idx].initialPos.x - (self.size.width / 3)) {
                    var rDir = CGVector(dx: (enemies[idx].initialPos.x + (self.size.width / 3)) - enemies[idx].node.position.x, dy: (enemies[idx].initialPos.y - enemies[idx].node.position.y) / 2.0)
                    rDir = CGVector(dx: simd_normalize(simd_double2(x: Double(rDir.dx), y: Double(rDir.dy))).x * 750.0,
                                               dy: simd_normalize(simd_double2(x: Double(rDir.dx), y: Double(rDir.dy))).y * 750.0)
                    enemies[idx].node.physicsBody?.velocity = rDir
                    self.enemies[idx].node.run(enemyAnims[4])
                } else if enemies[idx].state == .FLEE && enemies[idx].node.position.x > (enemies[idx].initialPos.x + (self.size.width / 3)) && enemySpeed > diagonalSpeed {
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
                self.attackingEnemiesCounter -= 1
            }
        }
        if gameState != .LEVEL5 && !stillAlive && self.changeLevelTimer == nil {
            gameState = gameState == .LEVEL1 ? .LEVEL2 : .LEVEL3
            self.loadScene(scene: gameState)
        }
    }
    func updateBoss(_ currentTime: TimeInterval) {
        if !boss.deployed || self.changeLevelTimer != nil {return}
        if boss.node.parent == nil {
            gameState = .LEVEL1
            self.lives += 1
            self.livesLabel.text = "Lives: \(self.lives)"
            self.loadScene(scene: gameState)
            return
        }

        if currentTime > (boss.frameRef + 0.15) {
            boss.frameRef = currentTime
        for tile in boss.plateGrid {
            tile.position.x += tile.size.width
            if tile.position.x >= 290.0 {
                tile.position.x = -280.0
            }
        }
        }
        if currentTime > (boss.yGlobalRef + 0.5) {
            boss.yGlobalRef = currentTime
            boss.node.position.y -= 2
        }

        self.updateBird()
    }
}
