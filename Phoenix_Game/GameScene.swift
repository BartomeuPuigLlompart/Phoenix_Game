import SpriteKit
import GameplayKit

class GameScene: SKScene {

    public enum GameState {
        case LEVEL1
        case LEVEL2
        case LEVEL3
        case LEVEL4
        case LEVEL5
        case MENU
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
    var highScore: Int = 0
    var highScoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var attackingEnemiesCounter: Int = 0
    var attackingEnemiesLimit: Int = 0
    var greenFlag: Bool = false
    var shipRateOfFire: Bool = true
    var lives: Int = 0
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
    let enemyCategory: UInt32 = 0x1 << 1
    let shootCategory: UInt32 = 0x1 << 2
    let enemyBombCategory: UInt32 = 0x1 << 3
    let shieldCategory: UInt32 = 0x1 << 4
    var titleSprite = SKSpriteNode(imageNamed: "title")
    var scoreTable = SKSpriteNode(imageNamed: "score table")
    var playButton = SKLabelNode(text: "PLAY")
    var backButton = SKLabelNode(text: "BACK")
    var shootMenuText = SKLabelNode(text: "SHOOT   AN    OPTION!!")
    var scoresButton = SKLabelNode(text: "SCORES")
    var optionsButton = SKLabelNode(text: "OPTIONS")
    var livesOptions: [SKLabelNode] = [SKLabelNode(text: "1 LIVE"), SKLabelNode(text: "6 LIVES"), SKLabelNode(text: "10 LIVES")]
    var deadAnim = false

    override func didMove(to view: SKView) {

        gameState = GameState.MENU

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
        self.lives = 6
        self.highScoreLabel = SKLabelNode(text: "HIGH SCORE: \(self.highScore)")
        self.highScoreLabel.position = CGPoint(x: 130, y: (self.size.height / 2) - 130)
        self.highScoreLabel.fontName = "ARCADECLASSIC"
        self.highScoreLabel.fontColor = UIColor(red: 65 / 255, green: 180 / 255, blue: 211 / 255, alpha: 1)
        self.addChild(self.highScoreLabel)
        self.scoreLabel = SKLabelNode(fontNamed: "ARCADECLASSIC")
        self.scoreLabel.fontColor = UIColor(red: 65 / 255, green: 180 / 255, blue: 211 / 255, alpha: 1)
        self.scoreLabel.text = "SCORE: \(self.score)"
        self.scoreLabel.position = CGPoint(x: -130, y: (self.size.height / 2) - 130)
        self.addChild(self.scoreLabel)
        self.livesLabel = SKLabelNode(text: "Lives: \(self.lives)")
        self.livesLabel.position = CGPoint(x: -(self.size.width / 2) + 75, y: (self.size.height / 2) - 130)
        self.livesLabel.fontName = "ARCADECLASSIC"
        self.livesLabel.fontColor = UIColor(red: 65 / 255, green: 180 / 255, blue: 211 / 255, alpha: 1)
        self.addChild(self.livesLabel)
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
        // print(touch)
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
        if self.spaceshipTouch != nil && self.firstTouchRef == 0.0 {
            firstTouchRef = CGFloat(currentTime)
        } else if self.spaceshipTouch == nil && self.firstTouchRef > 0.0 {
            if !self.deadAnim && CGFloat(currentTime) - self.firstTouchRef < self.deltaTime * 20 && self.firstTouchDist < 20.0 {
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
        case .LEVEL5:
            self.updateBoss(currentTime)
        default:
            self.checkMenuShoots()
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

        func checkMenuShoots() {
            for node in children {
                guard node.name == "shoot" else { continue }
                if self.playButton.contains(node.position) && self.playButton.zPosition == 0 {
                    gameState = .LEVEL1
                    loadScene(scene: gameState)
                    self.titleSprite.removeFromParent()
                    self.scoreTable.removeFromParent()
                    self.playButton.removeFromParent()
                    self.optionsButton.removeFromParent()
                    self.backButton.removeFromParent()
                    self.titleSprite.removeFromParent()
                    self.shootMenuText.removeFromParent()
                    self.scoresButton.removeFromParent()
                    for idx in 0 ..< 3 {
                        self.livesOptions[idx].removeFromParent()
                    }

                    node.removeFromParent()
                    return
                } else if self.scoresButton.contains(node.position) && self.scoresButton.zPosition == 0 {
                    self.titleSprite.run(SKAction.fadeOut(withDuration: 0.5))
                    self.playButton.run(SKAction.fadeOut(withDuration: 0.5))
                    self.playButton.zPosition = -1
                    self.scoresButton.run(SKAction.fadeOut(withDuration: 0.5))
                    self.scoresButton.zPosition = -1
                    self.optionsButton.run(SKAction.fadeOut(withDuration: 0.5))
                    self.optionsButton.zPosition = -1
                    self.scoreTable.run(SKAction.fadeIn(withDuration: 0.5))
                    self.backButton.run(SKAction.fadeIn(withDuration: 0.5))
                    self.backButton.zPosition = 0
                    self.backButton.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: -400, duration: 4), SKAction.moveTo(x: 400, duration: 4)])))
                    node.removeFromParent()
                    return
                } else if self.optionsButton.contains(node.position) && self.optionsButton.zPosition == 0 {
                    self.titleSprite.run(SKAction.fadeOut(withDuration: 0.5))
                    self.playButton.run(SKAction.fadeOut(withDuration: 0.5))
                    self.playButton.zPosition = -1
                    self.scoresButton.run(SKAction.fadeOut(withDuration: 0.5))
                    self.scoresButton.zPosition = -1
                    self.optionsButton.run(SKAction.fadeOut(withDuration: 0.5))
                    self.optionsButton.zPosition = -1
                    self.backButton.run(SKAction.fadeIn(withDuration: 0.5))
                    self.backButton.zPosition = 0
                    self.backButton.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: -400, duration: 4), SKAction.moveTo(x: 400, duration: 4)])))
                    for idx in 0 ..< 3 {
                        self.livesOptions[idx].run(SKAction.fadeIn(withDuration: 0.5))
                        self.livesOptions[idx].run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(y: 400, duration: 3), SKAction.moveTo(y: 0, duration: 4)])))
                    }
                    node.removeFromParent()
                    return
                } else if self.backButton.zPosition == 0 {
                    if self.backButton.contains(node.position) {
                    self.titleSprite.run(SKAction.fadeIn(withDuration: 0.5))
                    self.playButton.run(SKAction.fadeIn(withDuration: 0.5))
                    self.playButton.zPosition = 0
                    self.scoresButton.run(SKAction.fadeIn(withDuration: 0.5))
                    self.scoresButton.zPosition = 0
                    self.optionsButton.run(SKAction.fadeIn(withDuration: 0.5))
                    self.optionsButton.zPosition = 0
                    self.scoreTable.run(SKAction.fadeOut(withDuration: 0.5))
                    self.backButton.run(SKAction.fadeOut(withDuration: 0.5))
                    self.backButton.zPosition = -1
                    for idx in 0 ..< 3 {
                        self.livesOptions[idx].run(SKAction.fadeOut(withDuration: 0.5))
                    }
                    node.removeFromParent()
                    return
                    } else {
                        for idx in 0 ..< 3 {
                            if self.livesOptions[idx].contains(node.position) {
                                switch idx {
                                case 0:
                                    self.lives = 1
                                case 1:
                                    self.lives = 6
                                case 2:
                                    self.lives = 10
                                default:
                                    return
                                }
                                self.livesLabel.text = "Lives: \(self.lives)"
                                node.removeFromParent()
                                return
                            }
                        }
                    }
                }
                }
            }

        @objc func setGreenFlag() {
            greenFlag = self.changeLevelTimer == nil
        }
        @objc func setShipGreenFlag() {
            shipRateOfFire = true
        }
}
