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
    }

    func addBirds() {
        switch self.gameState {
        case GameState.LEVEL1?:
            self.loadL1Enemies()
            let enemyAnimatedAtlas = SKTextureAtlas(named: "enemy_\(1)")
            var moveFrames: [SKTexture] = []

            // let numImages = enemyAnimatedAtlas.textureNames.count
            for index in 1 ... 3/*numimages*/ {
                let enemyTextureName = "enemy_1_1_static_\(index)"// enemy_1_1_static_1
                moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
            }

            let firstFrameTexture = moveFrames[0]
            let enemy = SKSpriteNode(texture: firstFrameTexture)
            enemy.size = CGSize(width: enemy.size.width * 4, height: enemy.size.height * 4)
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.physicsBody?.categoryBitMask = 0x0000_0001
            enemy.physicsBody?.contactTestBitMask = 0x0000_0111
            enemy.name = "enemy_\(1)_\(1)"
            enemy.physicsBody?.affectedByGravity = false

            for index in 0 ... enemies.count - 1 {
                guard let enemyNode = enemy.copy() as? SKSpriteNode else { continue}
                self.enemies[index].node = enemyNode
                //self.enemies[index].initialPos = CGPoint(x: CGFloat(index * 100) - self.size.width / 2 + enemy.size.width, y: enemy.position.y)
                self.enemies[index].node.position = self.enemies[index].initialPos
                self.addChild(self.enemies[index].node)
                self.enemies[index].node.run(SKAction.repeatForever(SKAction.animate(with: moveFrames,
                                                                                     timePerFrame: 0.3,
                                                                                     resize: false,
                                                                                     restore: true)))
            }
        default:
            return
        }
        // case scene 1
        // addBird(type, position)

    }
}
