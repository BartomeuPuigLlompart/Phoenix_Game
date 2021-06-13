import GameplayKit
import SpriteKit

extension GameScene {
    func loadScene(scene: GameState) {
        gameState = scene
        for enemy in self.enemies {
            for timer in enemy.timers {
                timer.invalidate()
            }
        }

        for node in children {
            if node != self.ship && node != self.scoreLabel && node != self.livesLabel && node != self.highScoreLabel {
                node.removeFromParent()
            }
        }

        self.ship.physicsBody = SKPhysicsBody(texture: self.ship.texture!, size: CGSize(width: self.ship.size.width * 0.75, height: self.ship.size.height * 0.75))
        self.ship.physicsBody?.categoryBitMask = shieldCategory
        self.ship.physicsBody?.contactTestBitMask = enemyBombCategory | enemyCategory
        self.ship.physicsBody?.collisionBitMask = 0
        self.ship.physicsBody?.affectedByGravity = false

        self.attackingEnemiesCounter = 0
        self.greenFlag = false

        switch scene {
        case .LEVEL1, .LEVEL2:
            self.changeLevelTimer = Timer.scheduledTimer(timeInterval: 2,
                                                         target: self,
                                                         selector: #selector(addBirds),
                                                         userInfo: nil,
                                                         repeats: false)
        case .LEVEL3, .LEVEL4:
            globalY = 0.0
            nextGlobalY = -300.0
            self.changeLevelTimer = Timer.scheduledTimer(timeInterval: 2,
                                                         target: self,
                                                         selector: #selector(addPhoenixes),
                                                         userInfo: nil,
                                                         repeats: false)
        case .LEVEL5:
            self.boss.node.removeFromParent()
            if self.boss.shootTimer != nil { self.boss.shootTimer.invalidate() }
            self.changeLevelTimer = Timer.scheduledTimer(timeInterval: 2,
                                                         target: self,
                                                         selector: #selector(addBoss),
                                                         userInfo: nil,
                                                         repeats: false)
        case .MENU:
            self.physicsWorld.contactDelegate = self
            self.titleSprite.size.width = self.size.width
            self.titleSprite.position.y = self.size.height / 2 - self.titleSprite.size.height
            self.addChild(self.titleSprite)
            self.scoreTable.size.width = self.size.width
            self.scoreTable.size.height = self.size.height / 3
            self.scoreTable.position.y = 300
            self.titleSprite.run(SKAction.fadeIn(withDuration: 0.5))
            self.playButton.position = CGPoint(x: 0, y: -100)
            self.playButton.fontName = "ARCADECLASSIC"
            self.playButton.fontSize = 100
            self.playButton.fontColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
            self.addChild(self.playButton)
            self.playButton.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: -300, duration: 4), SKAction.moveTo(x: 300, duration: 4)])))
            self.scoresButton.position = CGPoint(x: 0, y: -200)
            self.scoresButton.fontName = "ARCADECLASSIC"
            self.scoresButton.fontSize = 100
            self.scoresButton.fontColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
            self.addChild(self.scoresButton)
            self.scoresButton.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: -400, duration: 5), SKAction.moveTo(x: 400, duration: 5)])))
            self.optionsButton.position = CGPoint(x: 0, y: -300)
            self.optionsButton.fontName = "ARCADECLASSIC"
            self.optionsButton.fontSize = 100
            self.optionsButton.fontColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
            self.addChild(self.optionsButton)
            self.optionsButton.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: -500, duration: 6), SKAction.moveTo(x: 500, duration: 6)])))
            self.backButton.position = CGPoint(x: 0, y: -200)
            self.backButton.fontName = "ARCADECLASSIC"
            self.backButton.fontSize = 100
            self.backButton.fontColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
            self.addChild(self.backButton)
            self.shootMenuText.position = CGPoint(x: 0, y: self.ship.position.y + 100)
            self.shootMenuText.fontName = "ARCADECLASSIC"
            self.shootMenuText.fontColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
            self.addChild(self.shootMenuText)
            for idx in 0 ..< 3 {
                self.livesOptions[idx].position = CGPoint(x: -250 + idx * 250, y: 0)
                self.livesOptions[idx].fontName = "ARCADECLASSIC"
                self.livesOptions[idx].fontSize = 50
                self.livesOptions[idx].fontColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
                self.addChild(self.livesOptions[idx])
                self.livesOptions[idx].run(SKAction.fadeOut(withDuration: 0.0))
            }
            self.addChild(self.scoreTable)
            self.scoreTable.run(SKAction.fadeOut(withDuration: 0.0))
            self.backButton.run(SKAction.fadeOut(withDuration: 0.0))
            self.backButton.zPosition = -1
        default:
            return
        }
    }

    func shoot() {
        let sprite = SKSpriteNode(imageNamed: "Shoot")
        sprite.position = self.ship.position
        sprite.name = "shoot"
        sprite.size = CGSize(width: sprite.size.width, height: sprite.size.height * 3)
        sprite.zPosition = 1
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.categoryBitMask = shootCategory
        sprite.physicsBody?.contactTestBitMask = 0x1 << 5
        sprite.physicsBody?.collisionBitMask = 0
    }

    @objc
    func enemyShoot(sender: Timer) {
        guard let enemyStruct = sender.userInfo as? SKSpriteNode else { return}
        if enemyStruct.parent != nil {
            let sprite = SKSpriteNode(imageNamed: "Shoot")
            sprite.position = enemyStruct.position
            sprite.name = "bomb"
            sprite.zPosition = 1
            sprite.size = CGSize(width: sprite.size.width, height: sprite.size.height * 3)
            addChild(sprite)
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.affectedByGravity = false
            sprite.physicsBody?.linearDamping = 0
            sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
            sprite.physicsBody?.categoryBitMask = enemyBombCategory
            sprite.physicsBody?.contactTestBitMask = 0x1 << 5
            sprite.physicsBody?.collisionBitMask = 0
            var nextInterval: TimeInterval
            switch enemyStruct.name {
            case "enemy_1_1":
                nextInterval = TimeInterval.random(in: 10..<20)
                Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            case "enemy_1_2":
                nextInterval = TimeInterval.random(in: 8..<16)
                Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            case "enemy_2_1":
                nextInterval = TimeInterval.random(in: TimeInterval(deltaTime) ..< 4)
                Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            case "enemy_2_2":
                nextInterval = TimeInterval.random(in: TimeInterval(deltaTime) ..< 3)
                Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            default:
                sprite.position.x = self.ship.position.x + CGFloat.random(in: -self.ship.size.width * 3 ..< self.ship.size.width * 3 + 1)
                nextInterval = TimeInterval.random(in: TimeInterval(deltaTime) ..< 6)
                self.boss.shootTimer = Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            }
        }
    }

    func loadKillAnim(pos: CGPoint, bonus: Bool, type2: Bool, wingCut: Bool) {
        let sprite = SKSpriteNode(imageNamed: !bonus ? "enemy_rip_1" : (type2 ? "enemy_bonus_2" : "enemy_bonus"))
        sprite.position = pos
        sprite.name = "killAnim"
        sprite.size = CGSize(width: sprite.size.width * 4, height: sprite.size.height * 4)
        sprite.zPosition = 1
        addChild(sprite)
        if !bonus {
        let enemyAnimatedAtlas = SKTextureAtlas(named: "FX")
        var moveFrames: [SKTexture] = []
        var animation: SKAction
        for index in 1 ... 4 {
            let enemyTextureName = "enemy_rip_" + "\(type2 ? index + 4 : index)"
            moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
        }
        if wingCut { moveFrames.removeFirst() }
        animation = SKAction.animate(
            with: moveFrames,
            timePerFrame: 0.1,
            resize: false,
            restore: true)
        sprite.run(SKAction.sequence([animation, SKAction.removeFromParent()]))
        } else {
            guard let reversedCopy = sprite.copy() as? SKSpriteNode else { return}
            reversedCopy.xScale *= -1
            sprite.position.x -= 100
            sprite.run(SKAction.sequence([SKAction.moveTo(x: sprite.position.x - 200, duration: 0.35), SKAction.removeFromParent()]))
            reversedCopy.position.x += 100
            reversedCopy.run(SKAction.sequence([SKAction.moveTo(x: reversedCopy.position.x + 200, duration: 0.35), SKAction.removeFromParent()]))
            addChild(reversedCopy)
        }
    }

    func loadL1Enemies() {
        enemies = [Enemy(initialPos: CGPoint(x: -150, y: self.size.height / 2.5 - 150)),
                   Enemy(initialPos: CGPoint(x: 150, y: self.size.height / 2.5 - 150)),
                   Enemy(initialPos: CGPoint(x: -225, y: self.size.height / 2.5 - 190)),
                   Enemy(initialPos: CGPoint(x: 225, y: self.size.height / 2.5 - 190)),
                   Enemy(initialPos: CGPoint(x: -300, y: self.size.height / 2.5 - 230)),
                   Enemy(initialPos: CGPoint(x: 300, y: self.size.height / 2.5 - 230)),
                   Enemy(initialPos: CGPoint(x: -300, y: self.size.height / 2.5 - 310)),
                   Enemy(initialPos: CGPoint(x: 300, y: self.size.height / 2.5 - 310)),
                   Enemy(initialPos: CGPoint(x: -225, y: self.size.height / 2.5 - 350)),
                   Enemy(initialPos: CGPoint(x: 225, y: self.size.height / 2.5 - 350)),
                   Enemy(initialPos: CGPoint(x: -150, y: self.size.height / 2.5 - 390)),
                   Enemy(initialPos: CGPoint(x: 150, y: self.size.height / 2.5 - 390)),
                   Enemy(initialPos: CGPoint(x: -75, y: self.size.height / 2.5 - 430)),
                   Enemy(initialPos: CGPoint(x: 75, y: self.size.height / 2.5 - 430)),
                   Enemy(initialPos: CGPoint(x: 0, y: self.size.height / 2.5 - 430)),
                   Enemy(initialPos: CGPoint(x: 0, y: self.size.height / 2.5 - 350))]
    }

    func loadL2Enemies() {
        enemies = [Enemy(initialPos: CGPoint(x: -75, y: self.size.height / 2.5 - 150)),
                   Enemy(initialPos: CGPoint(x: 75, y: self.size.height / 2.5 - 150)),
                   Enemy(initialPos: CGPoint(x: -225, y: self.size.height / 2.5 - 230)),
                   Enemy(initialPos: CGPoint(x: 225, y: self.size.height / 2.5 - 230)),
                   Enemy(initialPos: CGPoint(x: -300, y: self.size.height / 2.5 - 270)),
                   Enemy(initialPos: CGPoint(x: 300, y: self.size.height / 2.5 - 270)),
                   Enemy(initialPos: CGPoint(x: -337.5, y: self.size.height / 2.5 - 350)),
                   Enemy(initialPos: CGPoint(x: 337.5, y: self.size.height / 2.5 - 350)),
                   Enemy(initialPos: CGPoint(x: -150, y: self.size.height / 2.5 - 270)),
                   Enemy(initialPos: CGPoint(x: 150, y: self.size.height / 2.5 - 270)),
                   Enemy(initialPos: CGPoint(x: 75, y: self.size.height / 2.5 - 310)),
                   Enemy(initialPos: CGPoint(x: 0, y: self.size.height / 2.5 - 190)),
                   Enemy(initialPos: CGPoint(x: -75, y: self.size.height / 2.5 - 310)),
                   Enemy(initialPos: CGPoint(x: 0, y: self.size.height / 2.5 - 270)),
                   Enemy(initialPos: CGPoint(x: 0, y: self.size.height / 2.5 - 430)),
                   Enemy(initialPos: CGPoint(x: 0, y: self.size.height / 2.5 - 350))]
    }

    func loadL3Enemies() {
        enemies = [Enemy(initialPos: CGPoint(x: -75, y: self.size.height / 2.5 - 150)),
                   Enemy(initialPos: CGPoint(x: 75, y: self.size.height / 2.5 - 225)),
                   Enemy(initialPos: CGPoint(x: -225, y: self.size.height / 2.5 - 300)),
                   Enemy(initialPos: CGPoint(x: 225, y: self.size.height / 2.5 - 375)),
                   Enemy(initialPos: CGPoint(x: -300, y: self.size.height / 2.5 - 450)),
                   Enemy(initialPos: CGPoint(x: 300, y: self.size.height / 2.5 - 525)),
                   Enemy(initialPos: CGPoint(x: -337.5, y: self.size.height / 2.5 - 600)),
                   Enemy(initialPos: CGPoint(x: 337.5, y: self.size.height / 2.5 - 675))]
    }

    func loadL4Enemies() {
        enemies = [Enemy(initialPos: CGPoint(x: -75, y: self.size.height / 2.5 - 150), flipAngle: 0.0),
                   Enemy(initialPos: CGPoint(x: 75, y: self.size.height / 2.5 - 225), flipAngle: CGFloat.pi),
                   Enemy(initialPos: CGPoint(x: -225, y: self.size.height / 2.5 - 300), flipAngle: 0.0),
                   Enemy(initialPos: CGPoint(x: 225, y: self.size.height / 2.5 - 375), flipAngle: CGFloat.pi),
                   Enemy(initialPos: CGPoint(x: -300, y: self.size.height / 2.5 - 450), flipAngle: 0.0),
                   Enemy(initialPos: CGPoint(x: 300, y: self.size.height / 2.5 - 525), flipAngle: CGFloat.pi),
                   Enemy(initialPos: CGPoint(x: -337.5, y: self.size.height / 2.5 - 600), flipAngle: 0.0),
                   Enemy(initialPos: CGPoint(x: 337.5, y: self.size.height / 2.5 - 675), flipAngle: CGFloat.pi)]
    }

    func loadL5Enemies() {
        enemies = [Enemy(initialPos: CGPoint(x: 0, y: 60)),
                   Enemy(initialPos: CGPoint(x: 150.0, y: 60)),
                   Enemy(initialPos: CGPoint(x: -150.0, y: 60)),
                   Enemy(initialPos: CGPoint(x: 75.0, y: 60)),
                   Enemy(initialPos: CGPoint(x: -75.0, y: 60)),
                   Enemy(initialPos: CGPoint(x: 225.0, y: 60)),
                   Enemy(initialPos: CGPoint(x: -225.0, y: 60)),
                   Enemy(initialPos: CGPoint(x: -300, y: 110)),
                   Enemy(initialPos: CGPoint(x: 300, y: 110)),
                   Enemy(initialPos: CGPoint(x: -225, y: 150)),
                   Enemy(initialPos: CGPoint(x: 225, y: 150)),
                   Enemy(initialPos: CGPoint(x: -150, y: 190)),
                   Enemy(initialPos: CGPoint(x: 150, y: 190)),
                   Enemy(initialPos: CGPoint(x: -75, y: 230)),
                   Enemy(initialPos: CGPoint(x: 75, y: 230)),
                   Enemy(initialPos: CGPoint(x: 0, y: 230))]
    }

    func loadShield() {
        self.shield = SKSpriteNode(imageNamed: "shield_1")
        self.shield.name = "shield"
        self.shield.size = CGSize(width: 50 * 2, height: 55 * 2)
        self.shield.position = CGPoint(x: 0, y: 0)
        self.shield.physicsBody = SKPhysicsBody(texture: self.shield.texture!, size: CGSize(width: self.shield.size.width * 2, height: self.shield.size.height * 2))
        self.shield.physicsBody?.categoryBitMask = shieldCategory
        self.shield.physicsBody?.contactTestBitMask = enemyBombCategory | enemyCategory
        self.shield.physicsBody?.collisionBitMask = 0
        self.shield.physicsBody?.affectedByGravity = false
        self.ship.addChild(self.shield)

        let action = SKAction.repeat(SKAction.animate(
                                    with: [SKTexture(imageNamed: "shield_1"), SKTexture(imageNamed: "shield_2")],
                                    timePerFrame: 0.1,
                                    resize: false,
                                    restore: true), count: 5)
        self.shield.run(SKAction.sequence([action, SKAction.removeFromParent()]))
    }

    @objc
    func addBirds() {
        self.changeLevelTimer = nil
        var sceneNum: Int
        if gameState == .LEVEL1 {
            loadL1Enemies()
            sceneNum = 1
            self.attackingEnemiesLimit = 8
        } else {
            if gameState == .LEVEL2 {
                loadL2Enemies()
            } else {
                loadL5Enemies()
            }
            sceneNum = 2
            self.attackingEnemiesLimit = 12
        }
        let animationCount = 6
        let enemyAnimatedAtlas = SKTextureAtlas(named: "enemy_1_\(sceneNum)")
        let animationsAtr: [(texName: String, texNum: Int, timePerFrame: Double)] =
            [("enemy_1_\(sceneNum)_static_", 3, 0.3),
             ("enemy_1_\(sceneNum)_attacking_", 2, 0.3),
             ("enemy_1_\(sceneNum)_returning_", 1, 0.3),
             ("enemy_1_\(sceneNum)_spawn_", 4, 0.1)]
        enemyAnims = Array(repeating: SKAction(), count: animationCount)
        var fleeFrames = Array(repeating: SKTexture(), count: 7)
        for anim in 0 ... animationsAtr.count-1 {
            var moveFrames: [SKTexture] = []
            for index in 1 ... animationsAtr[anim].texNum {
                let enemyTextureName = animationsAtr[anim].texName + "\(index)"
                moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
            }
            if anim != 3 {enemyAnims[anim] = SKAction.repeatForever(SKAction.animate(
                                                                        with: moveFrames,
                                                                        timePerFrame: animationsAtr[anim].timePerFrame,
                                                                        resize: false,
                                                                        restore: true))
                fleeFrames[anim] = SKTexture(imageNamed: "enemy_1_\(sceneNum)_flee_\(anim+1)")
                fleeFrames[anim+3] = SKTexture(imageNamed: "enemy_1_\(sceneNum)_flee_\(anim+4)")
            } else {
                enemyAnims[anim] = SKAction.sequence([SKAction.animate(
                                                        with: moveFrames,
                                                        timePerFrame: animationsAtr[anim].timePerFrame,
                                                        resize: false,
                                                        restore: true),
                                                      enemyAnims[0]])
                enemyAnims[4] = SKAction.repeatForever(SKAction.animate(
                                                        with: fleeFrames[0...3].dropLast(),
                                                        timePerFrame: 0.1,
                                                                            resize: false,
                                                                            restore: true))
                enemyAnims[5] = SKAction.repeatForever(SKAction.animate(
                                                        with: fleeFrames[3...6].dropLast(),
                                                        timePerFrame: 0.1,
                                                                            resize: false,
                                                                            restore: true))
            }
        }
            let enemy = SKSpriteNode(texture: SKTexture(imageNamed: "enemy_1_\(sceneNum)_static_1"))
            enemy.size = CGSize(width: enemy.size.width * 4, height: enemy.size.height * 4)
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.physicsBody?.categoryBitMask = enemyCategory
            enemy.physicsBody?.contactTestBitMask = shootCategory | shieldCategory
            enemy.physicsBody?.collisionBitMask = 0
            enemy.name = "enemy_1_\(sceneNum)"
            enemy.physicsBody?.affectedByGravity = false
            for index in 0 ... enemies.count - 1 {
                guard let enemyNode = enemy.copy() as? SKSpriteNode else { continue}
                self.enemies[index].node = enemyNode
                self.enemies[index].node.position = self.enemies[index].initialPos
                self.enemies[index].flipRad = 200
                self.addChild(self.enemies[index].node)
                self.enemies[index].node.run(enemyAnims[3])
                self.enemies[index].timers = [Timer(), Timer()]
                var interval = TimeInterval.random(in: 3..<20)
                self.enemies[index].timers[0] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: self.enemies[index].node, repeats: false)
                interval = TimeInterval.random(in: 3..<7)
                self.enemies[index].timers[1] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(setNewAttackers(sender:)), userInfo: index, repeats: false)
            }
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(setGreenFlag), userInfo: nil, repeats: false)
    }

    @objc
    func addPhoenixes() {
        self.changeLevelTimer = nil
        var sceneNum: Int
        if gameState == .LEVEL3 {
            loadL3Enemies()
            sceneNum = 3
        } else {
            loadL4Enemies()
            sceneNum = 4
        }
        let animationCount = 7
        let enemyAnimatedAtlas = SKTextureAtlas(named: "enemy_2_\(sceneNum-2)")
        let animationsAtr: [(texName: String, texNum: Int, timePerFrame: Double)] =
            [("enemy_2_\(sceneNum-2)_bothhurt_", 4, 0.3),
             ("enemy_2_\(sceneNum-2)_large_", 4, 0.3),
             ("enemy_2_\(sceneNum-2)_lefthurt_", 4, 0.3),
             ("enemy_2_\(sceneNum-2)_righthurt_", 4, 0.3),
             ("enemy_2_\(sceneNum-2)_short_", 4, 0.3),
             ("enemy_2_\(sceneNum-2)_transition_", 2, 0.1),
             ("enemy_2_\(sceneNum-2)_spawn_", 13, 0.3)]
        enemyAnims = Array(repeating: SKAction(), count: animationCount)
        var moveFrames: [SKTexture] = []
        for anim in 0 ... animationsAtr.count-1 {
            moveFrames = []
            for index in 1 ... animationsAtr[anim].texNum {
                let enemyTextureName = animationsAtr[anim].texName + "\(index)"
                moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
            }
            enemyAnims[anim] = SKAction.animate(
                with: moveFrames,
                timePerFrame: animationsAtr[anim].timePerFrame,
                resize: false,
                restore: true)
        }
        enemyAnims.insert(SKAction.animate(with: moveFrames[0...5].dropLast(), timePerFrame: 0.3, resize: false, restore: true),
                          at: enemyAnims.count - 2)
        let spawnIncubation = SKAction.animate(with: moveFrames[5...8].dropLast(), timePerFrame: 0.3, resize: false, restore: true)
        let spawnHatch = SKAction.repeatForever(SKAction.animate(with: moveFrames[6...8].dropLast(), timePerFrame: 0.1, resize: false, restore: true))
        enemyAnims.insert(SKAction.sequence([spawnIncubation, spawnHatch]) ,
                          at: enemyAnims.count - 2)
        enemyAnims.insert(SKAction.animate(with: moveFrames[8...12].dropLast(), timePerFrame: 0.3, resize: false, restore: true),
                          at: enemyAnims.count - 2)
        enemyAnims.popLast()

            let enemy = SKSpriteNode(texture: SKTexture(imageNamed: "enemy_2_\(sceneNum-2)_spawn_5"))
            enemy.size = CGSize(width: enemy.size.width * 4, height: enemy.size.height * 4)
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.physicsBody?.categoryBitMask = enemyCategory
            enemy.physicsBody?.contactTestBitMask = shootCategory | shieldCategory
            enemy.physicsBody?.collisionBitMask = 0
            enemy.physicsBody?.restitution = 0
            enemy.name = "enemy_2_\(sceneNum-2)"
            enemy.physicsBody?.affectedByGravity = false
            for index in 0 ... enemies.count - 1 {
                guard let enemyNode = enemy.copy() as? SKSpriteNode else { continue}
                self.enemies[index].node = enemyNode
                self.enemies[index].node.position = self.enemies[index].initialPos
                self.enemies[index].flipRad = 300
                self.enemies[index].flipAngle += (0 - (CGFloat(index) * CGFloat.pi / 10.0))
                self.enemies[index].state = .EGGSPAWN
                self.addChild(self.enemies[index].node)
                self.enemies[index].node.run(enemyAnims[5])
                self.enemies[index].timers = [Timer(), Timer()]
                var interval = TimeInterval.random(in: 9..<12)
                self.enemies[index].timers[0] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: self.enemies[index].node, repeats: false)
                interval = TimeInterval((3 + (index / 5)))
                self.enemies[index].timers[1] = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(setNewPhoenixAnim(sender:)), userInfo: index, repeats: false)
            }

    }

    @objc
    func addBoss() {
        self.boss = Boss()
        self.boss.deployed = true
        self.boss.node.texture?.filteringMode = .linear
        self.boss.node.name = "boss"
        self.boss.node.zPosition = -1
        self.addChild(boss.node)
        let enemyAnimatedAtlas = SKTextureAtlas(named: "boss")
        var moveFrames: [SKTexture] = []
        var animation: SKAction
        for index in 1 ... 4 {
            let enemyTextureName = "boss_alien_" + "\(index)"
            moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
        }
        animation = SKAction.animate(
            with: moveFrames,
            timePerFrame: 0.05,
            resize: false,
            restore: true)
        boss.alien.run(SKAction.repeatForever(SKAction.sequence([animation, animation.reversed()])) )
        boss.alien.position.y += 6
        boss.alien.physicsBody = SKPhysicsBody(texture: boss.alien.texture!, size: boss.alien.size)
        boss.alien.physicsBody?.categoryBitMask = enemyCategory
        boss.alien.physicsBody?.contactTestBitMask = shootCategory | shieldCategory
        boss.alien.physicsBody?.collisionBitMask = 0
        boss.alien.physicsBody?.affectedByGravity = false
        boss.alien.name = "alien"
        self.boss.node.addChild(boss.alien)

        moveFrames = []
        for index in 1 ... 5 {
            let enemyTextureName = "boss_top_" + "\(index)"
            moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
        }
        animation = SKAction.animate(
            with: moveFrames,
            timePerFrame: 0.07,
            resize: false,
            restore: true)

        self.boss.bossTop.run(SKAction.repeatForever(animation))
        self.boss.bossTop.position.y += 70
        self.boss.node.addChild(self.boss.bossTop)

        let gridTextNum: [[Int]] = [
            [4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4],
            [0, 5, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 5, 0],
            [0, 0, 0, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 4, 0, 0, 0],
            [0, 0, 0, 0, 0, 5, 4, 3, 2, 2, 3, 4, 5, 0, 0, 0, 0, 0]]
        for yGrid in 0 ... self.boss.baseGrid.count - 1 {
            for xGrid in 0 ... self.boss.baseGrid[0].count - 1 {
                self.boss.baseGrid[yGrid][xGrid] = SKSpriteNode()
                self.boss.baseGrid[yGrid][xGrid].position = CGPoint(x: -68 * 4 + xGrid * 8 * 4, y: -72 - yGrid * 8 * 4)
                self.boss.baseGrid[yGrid][xGrid].size = CGSize(width: 8 * 4, height: 8 * 4)
                if gridTextNum[yGrid][xGrid] > 0 {
                    self.boss.baseGrid[yGrid][xGrid].texture = SKTexture(imageNamed: "base_tile_\(gridTextNum[yGrid][xGrid])")
                    self.boss.baseGrid[yGrid][xGrid].texture?.filteringMode = .linear
                    self.boss.baseGrid[yGrid][xGrid].physicsBody = SKPhysicsBody(texture: self.boss.baseGrid[yGrid][xGrid].texture!, size: self.boss.baseGrid[yGrid][xGrid].size)
                    self.boss.baseGrid[yGrid][xGrid].physicsBody?.categoryBitMask = enemyCategory
                    self.boss.baseGrid[yGrid][xGrid].physicsBody?.contactTestBitMask = shootCategory | shieldCategory
                    self.boss.baseGrid[yGrid][xGrid].physicsBody?.collisionBitMask = 0
                    self.boss.baseGrid[yGrid][xGrid].physicsBody?.affectedByGravity = false
                }
                self.boss.baseGrid[yGrid][xGrid].name = "base_tile_\(gridTextNum[yGrid][xGrid])"
                boss.node.addChild(self.boss.baseGrid[yGrid][xGrid])
                if yGrid < 2 {
                    let nSize = CGSize(width: 4 * 4, height: 8 * 4)
                    let idx = (yGrid * (self.boss.plateGrid.count / 2)) + xGrid
                    self.boss.plateGrid[idx] = SKSpriteNode(texture: SKTexture(imageNamed: "plate_tile_\(Float(xGrid).remainder(dividingBy: 2) == 0 ? 2 : 1)"), size: nSize)
                   self.boss.plateGrid[idx].position = CGPoint(x: (16 * yGrid) - 70 * 4 + xGrid * 8 * 4, y: (-40))
                    self.boss.plateGrid[idx].texture?.filteringMode = .linear
                    self.boss.plateGrid[idx].name = "plate_tile_\(Float(xGrid).remainder(dividingBy: 2) == 0 ? 2 : 1)"
                    self.boss.plateGrid[idx].physicsBody = SKPhysicsBody(texture: self.boss.plateGrid[idx].texture!, size: nSize)
                    self.boss.plateGrid[idx].physicsBody?.categoryBitMask = enemyCategory
                    self.boss.plateGrid[idx].physicsBody?.contactTestBitMask = shootCategory | shieldCategory
                    self.boss.plateGrid[idx].physicsBody?.collisionBitMask = 0
                    self.boss.plateGrid[idx].physicsBody?.affectedByGravity = false
                    boss.node.addChild(self.boss.plateGrid[idx])
                }
            }
        }
        self.boss.node.position.y += 100
        let nextInterval = TimeInterval.random(in: TimeInterval(deltaTime) ..< 2.5)
        boss.self.shootTimer = Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: self.boss.node, repeats: false)
        self.addBirds()
    }
}
