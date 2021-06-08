import SpriteKit
import GameplayKit

class GameScene: SKScene {

    public enum GameState {
        case LEVEL1
        case LEVEL2
        case LEVEL3
        case LEVEL4
        case LEVEL5
    }

    public enum EnemyState {
        case STANDBY
        case ATTACKING
        case KAMIKAZE
        case LOOPING
        case FLEE
        case RETURN
        
        case EGGSPAWN
        case EGGINCUBATION
        case EGGHATCH
        case SHORT
        case LARGE
        case LEFTHURT
        case RIGHTHURT
        case BOTHHURT
    }

    public struct Enemy {
        var node: SKSpriteNode = SKSpriteNode()
        var initialPos: CGPoint = CGPoint(x: 0, y: 0)
        var state: EnemyState = EnemyState.STANDBY
        var flipRad: CGFloat = 0.0
        var flipCenter = CGPoint(x: 0.0, y: 0.0)
        var flipAngle: CGFloat = 0.0
    }

    var pastTime = 0.0
    var deltaTime: CGFloat = 0.03
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    var attackingEnemiesCounter: Int = 0
    var attackingEnemiesLimit: Int = 0
    var greenFlag: Bool = false
    var shipRateOfFire: Bool = true
    var ship: SKSpriteNode!
    var enemies: [Enemy]!
    var enemyAnims: [SKAction]!
    let largeSize: CGSize = CGSize(width: 48*4, height: 16*4)
    let shortSize: CGSize = CGSize(width: 25*4, height: 16*4)
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var spaceshipTouch: UITouch?
    var gameState: GameState?
    var enemiesAttackTimer: Timer?
    var changeLevelTimer: Timer?

    override func didMove(to view: SKView) {

        gameState = GameState.LEVEL3

        let spaceshipYPositon = -(self.size.height / 2) + 150

        self.backgroundColor = .black
        self.ship = SKSpriteNode(imageNamed: "ship_sprite")
        self.ship.name = "spaceship"
        self.ship.size = CGSize(width: 50, height: 55)
        self.ship.position = CGPoint(x: 0, y: spaceshipYPositon)
        self.addChild(self.ship)
        self.scoreLabel = SKLabelNode(text: "SCORE: 0")
        self.scoreLabel.position = CGPoint(x: 0, y: (self.size.height / 2) - 130)
        self.addChild(self.scoreLabel)
        self.addPhoenixes()//self.addBirds()
        self.physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(setGreenFlag), userInfo: nil, repeats: false)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard self.spaceshipTouch == nil
        else {
            if !self.shipRateOfFire {return}
            self.shoot()
            self.shipRateOfFire = false
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(setShipGreenFlag), userInfo: nil, repeats: false)
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
        //self.updateBird()
        if pastTime != 0.0 {
            deltaTime = CGFloat(currentTime - pastTime)
        }
        pastTime = currentTime
        self.cleanPastShoots()
    }
}

    extension GameScene {

    func cleanPastShoots() {
        for node in children {
            guard node.name == "shoot" || node.name == "bomb"  else { continue }
            if node.position.y > (self.size.height / 2) || node.position.y < -(self.size.height / 2) {
                node.removeFromParent()
            }
        }
    }
        
        @objc func setGreenFlag()
        {
            greenFlag = true
        }
        @objc func setShipGreenFlag()
        {
            shipRateOfFire = true
        }
}
