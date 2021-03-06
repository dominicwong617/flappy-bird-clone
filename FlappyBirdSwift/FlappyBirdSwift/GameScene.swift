//
//  GameScene.swift
//  FlappyBirdSwift
//
//  Created by Dominic Wong on 27/1/15.
//  Copyright (c) 2015 Dominic Wong. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    
    var score = 0
    var scoreLabel = SKLabelNode()
    
    let birdGroup:UInt32 = 1
    let gapGroup:UInt32 = 0 << 3
    let objectGroup:UInt32 = 2
    
    var gameOver = 0
    var gameOverLabel = SKLabelNode()
    var movingObjects = SKNode()
    
    var labelHolder = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        self.addChild(movingObjects)
        createBackground()
        createBird()
        self.addChild(labelHolder)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 9
        self.addChild(scoreLabel)
    }
    
    func createBackground() {
        var backgroundTexture = SKTexture(imageNamed: "images/bg.png")
        var moveBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9)
        var replaceBackground = SKAction.moveByX(900, y: 0, duration: 0)
        var moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for var i:CGFloat = 0; i < 3; i++ {
            background = SKSpriteNode(texture: backgroundTexture)
            background.position  = CGPoint(x: backgroundTexture.size().width / 2 + backgroundTexture.size().width * i, y: CGRectGetMidY(self.frame))
            background.size.height = self.frame.height
            
            background.runAction(moveBackgroundForever)
            movingObjects.addChild(background)
        }
    }
    
    func createBird() {
        var birdTexture = SKTexture(imageNamed: "images/flappy1.png")
        var birdTextureTwo = SKTexture(imageNamed: "images/flappy2.png")
        var animation = SKAction.animateWithTextures([birdTexture, birdTextureTwo], timePerFrame: 0.1)
        var makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.collisionBitMask = objectGroup
        bird.physicsBody?.contactTestBitMask = objectGroup
        bird.zPosition = 10
        self.addChild(bird)
        
        // the ground
        var ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        self.addChild(ground)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createPipes"), userInfo: nil, repeats: true)
    }
    
    func createPipes() {
        if gameOver == 0 {
            let gapHeight = bird.size.height * 4
            var movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
            var pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
            
            var movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
            var removePipes = SKAction.removeFromParent()
            var moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
            
            // pipe at the top
            var pipeOneTexture = SKTexture(imageNamed: "images/pipe1.png")
            var pipeOne = SKSpriteNode(texture: pipeOneTexture)
            pipeOne.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOne.size.height / 2 + gapHeight / 2 + pipeOffset)
            pipeOne.runAction(moveAndRemovePipes)
            pipeOne.physicsBody = SKPhysicsBody(rectangleOfSize: pipeOne.size)
            pipeOne.physicsBody?.dynamic = false
            pipeOne.physicsBody?.categoryBitMask = objectGroup
            movingObjects.addChild(pipeOne)
            
            // pipe at the bottom
            var pipeTwoTexture = SKTexture(imageNamed: "images/pipe2.png")
            var pipeTwo = SKSpriteNode(texture: pipeTwoTexture)
            pipeTwo.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeTwo.size.height / 2 - gapHeight / 2 + pipeOffset)
            pipeTwo.runAction(moveAndRemovePipes)
            pipeTwo.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTwo.size)
            pipeTwo.physicsBody?.dynamic = false
            pipeTwo.physicsBody?.categoryBitMask = objectGroup

            movingObjects.addChild(pipeTwo)
            
            // score
            var gap = SKNode()
            gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, gapHeight))
            gap.runAction(moveAndRemovePipes)
            gap.physicsBody?.dynamic = false
            gap.physicsBody?.collisionBitMask = gapGroup
            gap.physicsBody?.categoryBitMask = gapGroup
            gap.physicsBody?.contactTestBitMask = birdGroup
            movingObjects.addChild(gap)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup {
            score++
            scoreLabel.text = "\(score)"
        } else {
            if gameOver == 0 {
                gameOver = 1
                movingObjects.speed = 0
                
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game over! Tap to play again"
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                labelHolder.addChild(gameOverLabel)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if gameOver == 0 {
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            score = 0
            scoreLabel.text = "0"
            movingObjects.removeAllChildren()
            createBackground()
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
            labelHolder.removeAllChildren()
            gameOver = 0
            movingObjects.speed = 1
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
