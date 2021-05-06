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
        //Switch scene
        //case scene 1
        //addBird(type, position)
        
    }
}
