//
//  GameScene.swift
//  SpriteKitGameDemo
//
//  Created by MacBook_Air_41 on 16/09/24.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var ballOfYarn: SKSpriteNode!
    var cat: SKSpriteNode!
    
    var isGameOver = false

    override func didMove(to view: SKView) {
        // Set the background color
        backgroundColor = SKColor.green
        
        // Set up the ball of yarn (toy)
        ballOfYarn = SKSpriteNode(imageNamed: "yarnBall")
        ballOfYarn.position = CGPoint(x: frame.midX, y: frame.midY)
        ballOfYarn.size = CGSize(width: 100, height: 100)
        ballOfYarn.zPosition = 1
        ballOfYarn.physicsBody = SKPhysicsBody(circleOfRadius: ballOfYarn.size.width / 2)
        ballOfYarn.physicsBody?.isDynamic = true
        ballOfYarn.physicsBody?.friction = 0.2
        ballOfYarn.physicsBody?.restitution = 0.8
        ballOfYarn.name = "yarn"
        addChild(ballOfYarn)
        
        // Set up the cat
        cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(x: frame.midX - 300, y: frame.midY)
        cat.size = CGSize(width: 150, height: 150)
        cat.zPosition = 1
        addChild(cat)
        
        // Set up scene physics (border)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // Start the cat chasing the yarn
        let chaseAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in self?.chaseYarn() },
                SKAction.wait(forDuration: 0.5)
            ])
        )
        cat.run(chaseAction)
    }

    // Move the cat towards the ball of yarn
    func chaseYarn() {
        if isGameOver { return }
        
        let distanceToYarn = distance(from: cat.position, to: ballOfYarn.position)
        if distanceToYarn < 50 {
            // If the cat is close to the ball, stop the game and declare it "caught"
            gameOver()
        } else {
            // Move the cat towards the ball of yarn
            let action = SKAction.move(to: ballOfYarn.position, duration: 1.0)
            cat.run(action)
        }
    }
    
    // Calculate the distance between two points
    func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }

    // Handle touches to move the ball of yarn
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        moveBall(to: touchLocation)
    }

    // Move the ball to a location
    func moveBall(to location: CGPoint) {
        if isGameOver { return }
        
        let action = SKAction.move(to: location, duration: 0.1)
        ballOfYarn.run(action)
    }
    
    // End the game when the cat catches the ball
    func gameOver() {
        isGameOver = true
        cat.removeAllActions()
        
        // Display "Caught!" message
        let label = SKLabelNode(text: "Caught!")
        label.fontSize = 50
        label.fontColor = SKColor.red
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        label.zPosition = 2
        addChild(label)
        
        // Optionally, reset the game after a few seconds
        let waitAction = SKAction.wait(forDuration: 2.0)
        let resetAction = SKAction.run { [weak self] in self?.resetGame() }
        run(SKAction.sequence([waitAction, resetAction]))
    }
    
    // Reset the game
    func resetGame() {
        isGameOver = false
        cat.position = CGPoint(x: frame.midX - 300, y: frame.midY)
        ballOfYarn.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Remove the "Caught!" label
        childNode(withName: "Caught!")?.removeFromParent()
        
        // Start the chase again
        let chaseAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in self?.chaseYarn() },
                SKAction.wait(forDuration: 0.5)
            ])
        )
        cat.run(chaseAction)
    }
}
