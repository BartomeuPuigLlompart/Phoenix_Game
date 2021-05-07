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
    
    func addBirds() {
        switch self.gameState
        {
        case GameState.LEVEL1?:
            let enemyAnimatedAtlas = SKTextureAtlas(named: "enemy_\(1)")
            var moveFrames: [SKTexture] = []

            //let numImages = enemyAnimatedAtlas.textureNames.count
            for index in 1 ... 3/*numimages*/ {
                let enemyTextureName = "enemy_1_1_static_\(index)"//enemy_1_1_static_1
                moveFrames.append(enemyAnimatedAtlas.textureNamed(enemyTextureName))
            }

            let firstFrameTexture = moveFrames[0]
            let enemy = SKSpriteNode(texture: firstFrameTexture)
            enemy.size = CGSize(width: enemy.size.width * 4, height: enemy.size.height * 4)
            enemy.position = CGPoint(x: 0, y: self.size.height / 2 - 150)
            enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
            enemy.physicsBody?.categoryBitMask = 0x0000_0001
            enemy.physicsBody?.contactTestBitMask = 0x0000_0111
            enemy.name = "enemy_\(1)_\(1)"
            enemy.physicsBody?.affectedByGravity = false
            enemy.physicsBody?.isDynamic = false
            self.addChild(enemy)

            enemy.run(SKAction.repeatForever(SKAction.animate(with: moveFrames,
                                                              timePerFrame: 0.3,
                                                              resize: false,
                                                              restore: true)))
        default:
            return
        }
        //case scene 1
        //addBird(type, position)
        
    }
}
