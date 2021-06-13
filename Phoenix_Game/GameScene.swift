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
    
    public struct Boss {
        let node: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "boss"))
        var baseGrid = Array(repeating: Array(repeating: SKSpriteNode(), count: 18), count: 4)
        var plateGrid = Array(repeating: SKSpriteNode(), count: 36)
        let alien: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "boss_alien_1"))
        let bossTop: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "boss_top_1"))
        var frameRef: TimeInterval = 0.0
        var yGlobalRef: TimeInterval = 0.0
        var deployed = false
        var shootTimer: Timer!
    }

    public struct Enemy {
        var node: SKSpriteNode = SKSpriteNode()
        var initialPos: CGPoint = CGPoint(x: 0, y: 0)
        var state: EnemyState = EnemyState.STANDBY
        var flipRad: CGFloat = 0.0
        var flipCenter = CGPoint(x: 0.0, y: 0.0)
        var flipAngle: CGFloat = 0.0
        var timers: [Timer] = []
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
    var shield: SKSpriteNode!
    var enemies: [Enemy] = [Enemy()]
    var boss: Boss = Boss()
    var enemyAnims: [SKAction]!
    let largeSize: CGSize = CGSize(width: 48*4, height: 16*4)
    let shortSize: CGSize = CGSize(width: 25*4, height: 16*4)
    var globalY: CGFloat = 0.0
    var nextGlobalY: CGFloat = -300.0
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var spaceshipTouch: UITouch?
    var gameState: GameState!
    var enemiesAttackTimer: Timer?
    var changeLevelTimer: Timer?
    var firstTouchShip: CGPoint = CGPoint(x: 0, y: 0)
    var firstTouchRef: CGFloat = 0.0
    var firstTouchDist: CGFloat = 0.0
    let enemyCategory  : UInt32 = 0x1 << 1
    let shootCategory: UInt32 = 0x1 << 2
    let enemyBombCategory : UInt32 = 0x1 << 3
    let shieldCategory : UInt32 = 0x1 << 4

    override func didMove(to view: SKView) {

        gameState = GameState.LEVEL5

        let spaceshipYPositon = -(self.size.height / 2) + 150

        self.backgroundColor = .black
        self.ship = SKSpriteNode(imageNamed: "ship_sprite")
        self.ship.name = "spaceship"
        self.ship.size = CGSize(width: 50, height: 55)
        self.ship.position = CGPoint(x: 0, y: spaceshipYPositon)
        self.ship.physicsBody = SKPhysicsBody(texture: self.ship.texture!, size: CGSize(width: self.ship.size.width * 0.75, height: self.ship.size.height * 0.75))
        self.ship.physicsBody?.categoryBitMask = shieldCategory
        self.ship.physicsBody?.contactTestBitMask = enemyBombCategory | enemyCategory
        self.ship.physicsBody?.collisionBitMask = 0
        self.ship.physicsBody?.affectedByGravity = false
        self.addChild(self.ship)
        
        self.scoreLabel = SKLabelNode(text: "SCORE: 0")
        self.scoreLabel.position = CGPoint(x: 0, y: (self.size.height / 2) - 130)
        self.addChild(self.scoreLabel)
        self.physicsWorld.contactDelegate = self
        loadScene(scene: gameState)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if self.ship.childNode(withName: "shield") != nil { return }
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
            self.firstTouchShip = touch.location(in: self.view)
            let newPosition = touch.location(in: self)
            let action = SKAction.moveTo(x: newPosition.x, duration: 0.5)
            action.timingMode = .easeInEaseOut
            self.ship.run(action)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard let touchIndex = touches.firstIndex(of: spaceshipTouch) else { return }
        if self.ship.childNode(withName: "shield") != nil { return }
        
        let touch = touches[touchIndex]
        //print(touch)
        let newPosition = touch.location(in: self)
        let action = SKAction.moveTo(x: newPosition.x, duration: 0.05)
        action.timingMode = .easeInEaseOut
        self.ship.run(action)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard touches.firstIndex(of: spaceshipTouch) != nil else { return }
        let xfirst = self.firstTouchShip.x
        let yfirst = self.firstTouchShip.y
        let xlast = touches.first?.location(in: self.view).x
        let ylast = touches.first?.location(in: self.view).y
        self.firstTouchDist = sqrt(pow(xlast! - xfirst, 2) + pow(ylast! - yfirst, 2))
        print(self.firstTouchDist)
        self.spaceshipTouch = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard touches.firstIndex(of: spaceshipTouch) != nil else { return }

        self.spaceshipTouch = nil
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if self.spaceshipTouch != nil && self.firstTouchRef == 0.0
        {
            firstTouchRef = CGFloat(currentTime)
        }
        else if self.spaceshipTouch == nil && self.firstTouchRef > 0.0
        {
            if CGFloat(currentTime) - self.firstTouchRef < self.deltaTime * 20 && self.firstTouchDist < 20.0
            {
                self.ship.removeAllActions()
                self.ship.texture = SKTexture(imageNamed: "ship_sprite")
                self.loadShield()
            }
            self.firstTouchRef = 0.0
            
        }
        switch gameState {
        case .LEVEL1, .LEVEL2:
            self.updateBird()
        case .LEVEL3, .LEVEL4:
            self.updatePhoenix()
        default:
            self.updateBoss(currentTime)
        }
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
            greenFlag = self.changeLevelTimer == nil
        }
        @objc func setShipGreenFlag()
        {
            shipRateOfFire = true
        }
}
