//
//  GameScene.swift
//  Impulse
//
//  Created by Lukas Romsicki on 2016-05-23.
//  Copyright (c) 2016 Lukas Romsicki. All rights reserved.
//

import SpriteKit
import UIKit

public extension CGFloat {
    // creates a randomizer
    
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF )
    }
    
    public static func random(min : CGFloat, max : CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}

struct physics {
    // gives all physics objects an identity
    static let circle : UInt32 = 0x1 << 1
    static let ground : UInt32 = 0x1 << 2
    static let pipe : UInt32 = 0x1 << 3
    static let score : UInt32 = 0x1 << 4
    static let upperBound : UInt32 = 0x1 << 5
}

struct global {
    // variables accessed from other classes and documents
    static var background = SKSpriteNode()
    static var popEnabled = Bool()
    static var pipeDirection = Int()
    static var difficulty = Int()
    
    static var colorScheme = String()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // prepare all variables and constants
    
    var vc: UIViewController = UIViewController()
    let userDefaults = UserDefaults.standard
    
    var ground = SKShapeNode()
    var upperBound = SKShapeNode()
    var circle = SKShapeNode()
    
    let btnPlayAgain = UIButton(type: UIButtonType.system)
    let btnOptions = UIButton(type: UIButtonType.system)
    let gameMenuGlass = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    
    let appCurrentScore = UILabel()
    let appTitle = UILabel()
    let appHighScore = UILabel()
    
    let scoreLabel = SKLabelNode(fontNamed:"E4 2017 Regular")
    let highScoreLabel = SKLabelNode(fontNamed:"E4 2017 Regular")
    
    var pipePair = SKNode()
    var createAndDestroy = SKAction()
    var gameStarted = Bool()
    var hadCollision = Bool()
    
    var score = Int()
    var highScore:Int = 0
    
    func setBackground() {
        // sets either the default background or user-selected background
        
        var background = SKSpriteNode()
        
        if global.colorScheme == "Default (Blue)" {
            background = SKSpriteNode(imageNamed: "background")
            
        } else if global.colorScheme == "Warm Red" {
            background = SKSpriteNode(imageNamed: "red")
            
        } else if global.colorScheme == "Deep Purple" {
            background = SKSpriteNode(imageNamed: "purple")
            
        } else if global.colorScheme == "Forest Green" {
            background = SKSpriteNode(imageNamed: "green")
            
        } else if global.colorScheme == "Solid Black" {
            background = SKSpriteNode(imageNamed: "black")
            
        } else {
            background = SKSpriteNode(imageNamed: "background")
        }
        
        background.size = CGSize(width: frame.width, height: frame.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = -999
        
        if background.parent == nil {
            self.addChild(background)
        }
    }
    
    func createScene() {
        // prepare the game scene and create all objects & initializes physics
        
        setBackground()
        self.physicsWorld.contactDelegate = self
        
        ground = SKShapeNode(rectOf: CGSize(width: 1000, height: 30))
        ground.fillColor = SKColor.white
        ground.position = CGPoint(x: self.frame.width / 2, y: 0 + (ground.frame.height - 2) / 2)
        ground.zPosition = 0
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1000, height: 30))
        ground.physicsBody?.categoryBitMask = physics.ground
        ground.physicsBody?.collisionBitMask = physics.circle
        ground.physicsBody?.contactTestBitMask = physics.circle
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        
        self.addChild(ground)
        
        upperBound = SKShapeNode(rectOf: CGSize(width: 1000, height: 10))
        upperBound.fillColor = SKColor.clear
        upperBound.strokeColor = SKColor.clear
        upperBound.position = CGPoint(x: self.frame.width / 2, y: self.frame.height + 20)
        upperBound.zPosition = 0
        
        upperBound.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1000, height: 10))
        upperBound.physicsBody?.categoryBitMask = physics.upperBound
        upperBound.physicsBody?.collisionBitMask = physics.circle
        upperBound.physicsBody?.contactTestBitMask = physics.circle
        upperBound.physicsBody?.affectedByGravity = false
        upperBound.physicsBody?.isDynamic = false
        
        self.addChild(upperBound)
        
        circle = SKShapeNode(circleOfRadius: 27)
        circle.strokeColor = SKColor.white
        circle.lineWidth = 15
        
        var pipeDirectionBasedCirclePoint = CGPoint()
        
        if global.pipeDirection == 0 {
            pipeDirectionBasedCirclePoint = CGPoint(x: self.frame.width / 2 - circle.frame.width, y: self.frame.height / 2)
        } else {
            pipeDirectionBasedCirclePoint = CGPoint(x: self.frame.width / 2 + circle.frame.width, y: self.frame.height / 2)
        }
        
        circle.position = pipeDirectionBasedCirclePoint
        circle.zPosition = 1
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.frame.height / 2)
        circle.physicsBody?.categoryBitMask = physics.circle
        circle.physicsBody?.collisionBitMask = physics.ground | physics.pipe | physics.upperBound
        circle.physicsBody?.contactTestBitMask = physics.ground | physics.pipe | physics.score | physics.upperBound
        circle.physicsBody?.affectedByGravity = false
        circle.physicsBody?.isDynamic = true
        
        self.addChild(circle)
        
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 54
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: (self.frame.height / 5) * 4)
        scoreLabel.zPosition = 2
        
        self.addChild(scoreLabel)
        
        highScoreLabel.text = "HIGH SCORE: \(highScore)"
        highScoreLabel.fontSize = 14
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        highScoreLabel.fontColor = SKColor.darkGray
        highScoreLabel.position = CGPoint(x: 10, y: 10)
        highScoreLabel.zPosition = 3
        
        self.addChild(highScoreLabel)
    }
    
    func clearScene() {
        // resets the scene for the next game
        
        self.removeAllChildren()
        self.removeAllActions()
        hadCollision = false
        gameStarted = false
        score = 0
        
        createScene()
    }
    
    override func didMove(to view: SKView) {
        // called when the view becomes visible
        
        prepareSavedVariables()
        self.run(SKAction.playSoundFileNamed("init.wav", waitForCompletion: false))
        
        createScene()
    }
    
    func prepareSavedVariables() {
        // loads any saved variables when the view is opened
        
        if (userDefaults.object(forKey: "HighScoreValue")) == nil {
            userDefaults.set(highScore, forKey:"HighScoreValue")
        } else {
            highScore = userDefaults.object(forKey: "HighScoreValue") as! Int
        }
        
        if (userDefaults.object(forKey: "globalColorScheme")) == nil {
            userDefaults.set(global.colorScheme, forKey:"globalColorScheme")
        } else {
            global.colorScheme = userDefaults.object(forKey: "globalColorScheme") as! String
        }
        
        if (userDefaults.object(forKey: "isPopEnabled")) == nil {
            userDefaults.set(true, forKey:"isPopEnabled")
            global.popEnabled = true
        } else {
            global.popEnabled = userDefaults.object(forKey: "isPopEnabled") as! Bool
        }
        
        if (userDefaults.object(forKey: "pipeDirection")) == nil {
            userDefaults.set(0, forKey:"pipeDirection")
            
            global.pipeDirection = 0
        } else {
            global.pipeDirection = userDefaults.object(forKey: "pipeDirection") as! Int
        }
        
        if (userDefaults.object(forKey: "difficulty")) == nil {
            userDefaults.set(1, forKey:"difficulty")
            global.difficulty = 1
        } else {
            global.difficulty = userDefaults.object(forKey: "difficulty") as! Int
        }
        
        userDefaults.synchronize()
    }
    
    func displayGameMenu() {
        // displays the translucent game menu
        
        gameMenuGlass.alpha = 0
        
        self.view!.backgroundColor = UIColor.clear
        
        gameMenuGlass.frame = self.view!.bounds
        gameMenuGlass.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view!.addSubview(gameMenuGlass)
        
        SKView.animate(withDuration: 0.7, animations: {
            self.gameMenuGlass.alpha = 1.0
            // fades in view slowly, 1.2s from alpha == 0 to alpha == 1
        })
        
        appTitle.text = "ImpuLse"
        appTitle.font = UIFont(name: "E4-2017", size: 60)
        appTitle.textColor = SKColor.white
        appTitle.sizeToFit()
        appTitle.center = CGPoint(x: self.size.width / 2 , y: self.size.height / 4);
        
        gameMenuGlass.contentView.addSubview(appTitle)
        
        appHighScore.text = "HIGH SCORE: \(highScore)"
        appHighScore.font = UIFont(name: "E4-2017", size: 33)
        appHighScore.textColor = SKColor.white
        appHighScore.sizeToFit()
        appHighScore.center = CGPoint(x: self.size.width / 2 , y: (self.size.height / 4) + 50);
        
        gameMenuGlass.contentView.addSubview(appHighScore)
        
        appCurrentScore.text = "SCORE: \(score)"
        appCurrentScore.font = UIFont(name: "E4-2017", size: 33)
        appCurrentScore.textColor = SKColor.white
        appCurrentScore.sizeToFit()
        appCurrentScore.center = CGPoint(x: self.size.width / 2 , y: (self.size.height / 4) + 90);
        
        gameMenuGlass.contentView.addSubview(appCurrentScore)
        
        btnPlayAgain.setTitle("Play Again", for: UIControlState())
        btnPlayAgain.titleLabel!.font = UIFont(name: "E4-2017", size: 50)
        btnPlayAgain.setTitleColor(SKColor.white, for: UIControlState())
        btnPlayAgain.sizeToFit()
        btnPlayAgain.center = CGPoint(x: self.size.width / 2 , y: (self.size.height / 4) + 200);
        btnPlayAgain.addTarget(self, action: #selector(playAgain), for: UIControlEvents.touchUpInside)
        
        gameMenuGlass.contentView.addSubview(btnPlayAgain)
        
        btnOptions.setTitle("Options", for: UIControlState())
        btnOptions.titleLabel!.font = UIFont(name: "E4-2017", size: 30)
        btnOptions.setTitleColor(SKColor.white, for: UIControlState())
        btnOptions.sizeToFit()
        btnOptions.center = CGPoint(x: self.size.width / 2 , y: self.size.height - 40);
        btnOptions.addTarget(self, action: #selector(showOptions), for: UIControlEvents.touchUpInside)
        
        gameMenuGlass.contentView.addSubview(btnOptions)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // called whenever there is a physics collision
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if hadCollision == false {
            if firstBody.categoryBitMask == physics.score && secondBody.categoryBitMask == physics.circle || firstBody.categoryBitMask == physics.circle && secondBody.categoryBitMask == physics.score {
                score += 1
                scoreLabel.text = "\(score)"
            }
        }
        
        if firstBody.categoryBitMask == physics.circle && secondBody.categoryBitMask == physics.pipe || firstBody.categoryBitMask == physics.pipe && secondBody.categoryBitMask == physics.circle || firstBody.categoryBitMask == physics.circle && secondBody.categoryBitMask == physics.ground || firstBody.categoryBitMask == physics.ground && secondBody.categoryBitMask == physics.circle {
            
            if hadCollision == false {
                if score > highScore {
                    highScore = score
                    highScoreLabel.text = "HIGH SCORE: \(highScore)"
                    
                    userDefaults.set(highScore, forKey:"HighScoreValue")
                    userDefaults.synchronize()
                    // sets new high score and saves to user defaults
                }
                self.run(SKAction.playSoundFileNamed("end.wav", waitForCompletion: false))
                displayGameMenu()
                hadCollision = true
            }
        }
    }
    
    func createPipe() {
        // called at an interval when gameStarted is equal to true
        
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1, height: 200)
        scoreNode.color = SKColor.clear
        
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        
        scoreNode.physicsBody?.categoryBitMask = physics.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = physics.circle
        
        // scoreNode is an invisible object to detect passing beteen the pipes
        
        let pipePair = SKNode()
        var upperPipe = SKSpriteNode()
        var lowerPipe = SKSpriteNode()
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            upperPipe = SKSpriteNode(imageNamed: "rectangle")
            lowerPipe = SKSpriteNode(imageNamed: "rectangle")
        case .pad:
            upperPipe = SKSpriteNode(imageNamed: "rectangle-ipad")
            lowerPipe = SKSpriteNode(imageNamed: "rectangle-ipad")
        case .unspecified:
            upperPipe = SKSpriteNode(imageNamed: "rectangle")
            lowerPipe = SKSpriteNode(imageNamed: "rectangle")
        default:
            upperPipe = SKSpriteNode(imageNamed: "rectangle")
            lowerPipe = SKSpriteNode(imageNamed: "rectangle")
        }
        
        
        // set both pipes to same graphic asset
        
        var upperPipeDirectionBasedPosition = CGPoint()
        var lowerPipeDirectionBasedPosition = CGPoint()
        
        if global.pipeDirection == 0 {
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                upperPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 + 350)
                lowerPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 - 350)
            case .pad:
                upperPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 + 620)
                lowerPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 - 620)
            case .unspecified:
                upperPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 + 350)
                lowerPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 - 350)
            default:
                upperPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 + 350)
                lowerPipeDirectionBasedPosition = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2 - 350)
            }
            
            scoreNode.position = CGPoint(x: self.frame.width + 30, y: self.frame.height / 2)
        } else {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                upperPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 + 350)
                lowerPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 - 350)
            case .pad:
                upperPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 + 620)
                lowerPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 - 620)
            case .unspecified:
                upperPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 + 350)
                lowerPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 - 350)
            default:
                upperPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 + 350)
                lowerPipeDirectionBasedPosition = CGPoint(x: 0 - 30, y: self.frame.height / 2 - 350)
            }
            scoreNode.position = CGPoint(x: 0 - 30, y: self.frame.height / 2)
        }
        
        upperPipe.position = upperPipeDirectionBasedPosition
        lowerPipe.position = lowerPipeDirectionBasedPosition
        
        upperPipe.setScale(0.5)
        lowerPipe.setScale(0.5)
        // make the pipe sprites smaller
        
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipe.size)
        upperPipe.physicsBody?.categoryBitMask = physics.pipe
        upperPipe.physicsBody?.collisionBitMask = physics.circle
        upperPipe.physicsBody?.contactTestBitMask = physics.circle
        upperPipe.physicsBody?.isDynamic = false
        upperPipe.physicsBody?.affectedByGravity = false
        
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: lowerPipe.size)
        lowerPipe.physicsBody?.categoryBitMask = physics.pipe
        lowerPipe.physicsBody?.collisionBitMask = physics.circle
        lowerPipe.physicsBody?.contactTestBitMask = physics.circle
        lowerPipe.physicsBody?.isDynamic = false
        lowerPipe.physicsBody?.affectedByGravity = false
        
        pipePair.addChild(upperPipe)
        pipePair.addChild(lowerPipe)
        
        // merges the upper and lower pipes into one single object
        var randomPosition = CGFloat()
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if self.frame.height <= 500 {
                randomPosition = CGFloat.random(min: -120, max: 120)
            } else if self.frame.height == 568 {
                randomPosition = CGFloat.random(min: -150, max: 150)
            } else {
                randomPosition = CGFloat.random(min: -200, max: 200)
            }
        case .pad:
                randomPosition = CGFloat.random(min: -260, max: 260)
        case .unspecified:
            if self.frame.height <= 500 {
                randomPosition = CGFloat.random(min: -120, max: 120)
            } else if self.frame.height == 568 {
                randomPosition = CGFloat.random(min: -150, max: 150)
            } else {
                randomPosition = CGFloat.random(min: -200, max: 200)
            }
        default:
            if self.frame.height <= 500 {
                randomPosition = CGFloat.random(min: -120, max: 120)
            } else if self.frame.height == 568 {
                randomPosition = CGFloat.random(min: -150, max: 150)
            } else {
                randomPosition = CGFloat.random(min: -200, max: 200)
            }
        }
        
        pipePair.position.y = pipePair.position.y + randomPosition
        
        pipePair.addChild(scoreNode)
        // adds pipes to the view
        
        pipePair.run(createAndDestroy)
        pipePair.zPosition = -1
        self.addChild(pipePair)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // function is called whenever user touches anywhere on the screen
        
        if gameStarted == false {
            gameStarted = true
            
            circle.physicsBody?.affectedByGravity = true;
            
            let spawn = SKAction.run({
                () in
                self.createPipe()
            })
            // spawns a new pipe
            
            var difficultySetting = Double()
            
            if global.difficulty == 0 {
                difficultySetting = 3.15
            } else if global.difficulty == 1 {
                difficultySetting = 2.15
            } else {
                difficultySetting = 2.00
            }
            
            // ^ synchronizes difficulty with time intervals
            
            let delay = SKAction.wait(forDuration: difficultySetting)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            
            self.run(spawnDelayForever)
            
            var pipeMotion = SKAction()
            
            let distance = CGFloat(self.frame.width + pipePair.frame.width + 70)
            
            if global.pipeDirection == 0 {
                pipeMotion = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01 * distance))
            } else {
                pipeMotion = SKAction.moveBy(x: distance, y: 0, duration: TimeInterval(0.01 * distance))
            }
            
            let createPipe = pipeMotion
            let destroyPipe = SKAction.removeFromParent()
            createAndDestroy = SKAction.sequence([createPipe, destroyPipe])
            
            circle.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            if global.difficulty == 2 {
                circle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
            } else {
                circle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 77))
            }
            // apply an impulse upwards using a vector
            
            if global.popEnabled {
                self.run(SKAction.playSoundFileNamed("pop2.wav", waitForCompletion: false))
            }
        } else {
            if hadCollision == true {
                // do nothing!
                
            } else {
                circle.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                
                if global.difficulty == 2 {
                    circle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
                } else {
                    circle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 77))
                }
                
                if global.popEnabled {
                    self.run(SKAction.playSoundFileNamed("pop2.wav", waitForCompletion: false))
                }
            }
        }
    }
    
    func playAgain(_ sender:UIButton!) {
        // dismisses all views and score labels
        
        SKView.animate(withDuration: 0.2, animations: {
            self.gameMenuGlass.alpha = 0
            // fades out menu slowly
        })
        
        clearScene()
    }
    
    func showOptions(_ sender:UIButton!) {
        // called when button to open the modal is pressed
        
        vc = self.view!.window!.rootViewController!
        vc.performSegue(withIdentifier: "showOptions", sender: vc)
    }
}
