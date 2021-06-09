import GameplayKit
import SpriteKit

extension GameScene {
    func shoot() {
        let sprite = SKSpriteNode(imageNamed: "Shoot")
        sprite.position = self.ship.position
        sprite.name = "shoot"
        sprite.size = CGSize(width: sprite.size.width, height: sprite.size.height * 3)
        sprite.zPosition = 1
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.contactTestBitMask = 0x0000_0101
        sprite.physicsBody?.collisionBitMask = 0
    }
    
    @objc
    func enemyShoot(sender: Timer) {
        guard let enemyStruct = sender.userInfo as? Enemy else { return}
        if enemyStruct.node.parent != nil {
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
            var nextInterval: TimeInterval
            switch enemyStruct.node.name {
            case "enemy_1_1":
                nextInterval = TimeInterval.random(in: 2..<16)
                Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            case "enemy_1_2":
                nextInterval = TimeInterval.random(in: 2..<10)
                Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            case "enemy_2_1":
                nextInterval = TimeInterval.random(in: TimeInterval(deltaTime) ..< 4)
                Timer.scheduledTimer(timeInterval: nextInterval , target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            case "enemy_2_2":
                nextInterval = TimeInterval.random(in: TimeInterval(deltaTime) ..< 3)
                Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(enemyShoot(sender:)), userInfo: enemyStruct, repeats: false)
            default:
                return
            }
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
        
        //enemies = [Enemy(initialPos: CGPoint(x: -75, y: self.size.height / 2.5 - 150))]
    }
    
    @objc
    func addBirds() {
        self.changeLevelTimer = nil
        var sceneNum: Int
        if gameState == .LEVEL1 {
            loadL1Enemies()
            sceneNum = 1
            self.attackingEnemiesLimit = 8
        }
        else {
            loadL2Enemies()
            sceneNum = 2
            self.attackingEnemiesLimit = 12
        }
        let animationCount = 6
        let enemyAnimatedAtlas = SKTextureAtlas(named: "enemy_1_\(sceneNum)")
        let animationsAtr: [(texName: String, texNum: Int, timePerFrame: Double)] =
            [("enemy_1_\(sceneNum)_static_", 3, 0.3),
             ("enemy_1_\(sceneNum)_attacking_", 2, 0.3),
             ("enemy_1_\(sceneNum)_returning_", 1, 0.3),
             ("enemy_1_\(sceneNum)_spawn_", 4, 0.3)]
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
            enemy.physicsBody?.categoryBitMask = 0x0000_0001
            enemy.physicsBody?.contactTestBitMask = 0x0000_0111
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
                Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 3..<6), target: self, selector: #selector(enemyShoot(sender:)), userInfo: self.enemies[index], repeats: false)
                Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 3..<7), target: self, selector: #selector(setNewAttackers(sender:)), userInfo: index, repeats: false)
            }

    }
    
    @objc
    func addPhoenixes() {
        self.changeLevelTimer = nil
        var sceneNum: Int
        if gameState == .LEVEL3 {
            loadL3Enemies()
            sceneNum = 3
            //self.attackingEnemiesLimit = 8
        }
        else {
            //loadL4Enemies()
            sceneNum = 4
            //self.attackingEnemiesLimit = 12
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
            enemy.physicsBody?.categoryBitMask = 0x0000_0001
            enemy.physicsBody?.contactTestBitMask = 0x0000_0111
            enemy.physicsBody?.collisionBitMask = 0
            enemy.physicsBody?.restitution = 0
            enemy.name = "enemy_2_\(sceneNum-2)"
            enemy.physicsBody?.affectedByGravity = false
            for index in 0 ... enemies.count - 1 {
                guard let enemyNode = enemy.copy() as? SKSpriteNode else { continue}
                self.enemies[index].node = enemyNode
                self.enemies[index].node.position = self.enemies[index].initialPos
                self.enemies[index].flipRad = 300
                self.enemies[index].flipAngle = (0 - (CGFloat(index) * CGFloat.pi / 10.0))
                self.enemies[index].state = .EGGSPAWN
                self.addChild(self.enemies[index].node)
                self.enemies[index].node.run(enemyAnims[5])
                Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 9..<12), target: self, selector: #selector(enemyShoot(sender:)), userInfo: self.enemies[index], repeats: false)
                /*Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 3..<7), target: self, selector: #selector(setNewAttackers(sender:)), userInfo: index, repeats: false)*/
                Timer.scheduledTimer(timeInterval: TimeInterval((3 + (index / 5))), target: self, selector: #selector(setNewPhoenixAnim(sender:)), userInfo: index, repeats: false)
            }

    }
}
