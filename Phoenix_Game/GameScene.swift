import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    public enum GameState {
        case LEVEL1
        case LEVEL2
        case LEVEL3
    }
    
    public enum EnemyState {
        case STANDBY
        case ATTACKING
        case LOOPING
    }
    
    public struct Enemy
    {
        var node: SKSpriteNode = SKSpriteNode()
        var initialPos: CGPoint = CGPoint(x: 0, y: 0)
        var state: EnemyState = EnemyState.STANDBY
    }
    
    var ship: SKSpriteNode!
    var enemies: [Enemy]!
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var spaceshipTouch: UITouch?
    var gameState : GameState?
    var enemiesAttackTimer : Timer?
    
    
    
    override func didMove(to view: SKView) {
        
        gameState = GameState.LEVEL1
        
        let spaceshipYPositon = -(self.size.height / 2) + 150

        self.backgroundColor = .black
        self.ship = SKSpriteNode(imageNamed: "ship_sprite")
        self.ship.name = "spaceship"
        self.ship.size = CGSize(width: 50, height: 55)
        self.ship.position = CGPoint(x: 0, y: spaceshipYPositon)
        self.addChild(self.ship)
        
        self.enemiesAttackTimer = Timer.scheduledTimer(timeInterval: 7,
                                                     target: self,
                                                     selector: #selector(setNewAttackers),
                                                     userInfo: nil,
                                                     repeats: true)
        
        self.addBirds()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard self.spaceshipTouch == nil
        else {
            self.shoot()
            return
        }

        if let touch = touches.first {
            self.spaceshipTouch = touch
            let newPosition = touch.location(in: self)
            let action = SKAction.moveTo(x: newPosition.x, duration: 0.5)
            action.timingMode = .easeInEaseOut
            self.ship.run(action)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard let touchIndex = touches.firstIndex(of: spaceshipTouch) else { return }

        let touch = touches[touchIndex]

        let newPosition = touch.location(in: self)
        let action = SKAction.moveTo(x: newPosition.x, duration: 0.05)
        action.timingMode = .easeInEaseOut
        self.ship.run(action)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard touches.firstIndex(of: spaceshipTouch) != nil else { return }

        self.spaceshipTouch = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard touches.firstIndex(of: spaceshipTouch) != nil else { return }

        self.spaceshipTouch = nil
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        self.cleanPastShoots()
    }
}
    
    extension GameScene {
    
    func cleanPastShoots() {
        for node in children {
            guard node.name == "shoot" else { continue }
            if node.position.y > (self.size.height / 2) || node.position.y < -(self.size.height / 2) {
                node.removeFromParent()
            }
        }
    }
        @objc
        func setNewAttackers()
        {
            for enemy in enemies {
                
                }
            }
}
