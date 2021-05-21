import GameplayKit
import SpriteKit

extension GameScene {
    func shoot() {
        let sprite = SKSpriteNode(imageNamed: "Shoot")
        sprite.position = self.ship.position
        sprite.name = "shoot"
        sprite.zPosition = 1
        addChild(sprite)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.contactTestBitMask = 0x0000_0101
    }

    func loadL1Enemies() {
        enemies = [Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: -150, y: self.size.height / 2 - 150), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 150, y: self.size.height / 2 - 150), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: -225, y: self.size.height / 2 - 190), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 225, y: self.size.height / 2 - 190), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: -300, y: self.size.height / 2 - 230), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 300, y: self.size.height / 2 - 230), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: -300, y: self.size.height / 2 - 310), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 300, y: self.size.height / 2 - 310), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: -225, y: self.size.height / 2 - 350), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 225, y: self.size.height / 2 - 350), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: -150, y: self.size.height / 2 - 390), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 150, y: self.size.height / 2 - 390), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: -75, y: self.size.height / 2 - 430), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 75, y: self.size.height / 2 - 430), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 0, y: self.size.height / 2 - 430), state: EnemyState.STANDBY),
                   Enemy(node: SKSpriteNode(), initialPos: CGPoint(x: 0, y: self.size.height / 2 - 350), state: EnemyState.STANDBY)]
        let animationCount = 6
        let enemyAnimatedAtlas = SKTextureAtlas(named: "enemy_\(1)")
        var animationsAtr: [(texName: String, texNum: Int, timePerFrame: Double)] =
            [("enemy_1_1_static_", 3, 0.3),
             ("enemy_1_1_attacking_", 2, 0.3),
             ("enemy_1_1_returning_", 1, 0.3),
             ("enemy_1_1_spawn_", 4, 0.3)]
        enemyAnims = Array(repeating: SKAction(), count: animationCount)
        var fleeFrames = Array(repeating: SKTexture(), count: 7)
        for anim in 0 ... animationsAtr.count-1{
            var moveFrames: [SKTexture] = []
            
            //var moveFrames: [SKTexture] = []
            for index in 1 ... animationsAtr[anim].texNum {
                let enemyTextureName = animationsAtr[anim].texName + "\(index)"// enemy_1_1_static_1
                moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
            }
            if anim != 3 {enemyAnims[anim] = SKAction.repeatForever(SKAction.animate(
                                                                        with: moveFrames,
                                                                        timePerFrame: animationsAtr[anim].timePerFrame,
                                                                        resize: false,
                                                                        restore: true))
                fleeFrames[anim] = SKTexture(imageNamed: "enemy_1_1_flee_\(anim+1)")
                fleeFrames[anim+3] = SKTexture(imageNamed: "enemy_1_1_flee_\(anim+4)")
            }
            else {
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
    }

    func addBirds() {
        switch self.gameState {
        case GameState.LEVEL1?:
            self.loadL1Enemies()

            let enemy = SKSpriteNode(texture: SKTexture(imageNamed: "enemy_1_1_static_1"))
            enemy.size = CGSize(width: enemy.size.width * 4, height: enemy.size.height * 4)
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.physicsBody?.categoryBitMask = 0x0000_0001
            enemy.physicsBody?.contactTestBitMask = 0x0000_0111
            enemy.physicsBody?.collisionBitMask = 0
            enemy.name = "enemy_\(1)_\(1)"
            enemy.physicsBody?.affectedByGravity = false
            //STATIC
            
            for index in 0 ... enemies.count - 1 {
                guard let enemyNode = enemy.copy() as? SKSpriteNode else { continue}
                self.enemies[index].node = enemyNode
                self.enemies[index].node.position = self.enemies[index].initialPos
                self.addChild(self.enemies[index].node)
                self.enemies[index].node.run(enemyAnims[3])
            }
        default:
            return
        }
        // case scene 1
        // addBird(type, position)

    }
}
