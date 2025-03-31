//
//  GameScene.swift
//  GameDemo
//
//  Created by MacBook_Air_41 on 16/09/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    var lastUpdateTime : TimeInterval = 0.0
    var dt : TimeInterval = 0.0
    
    var players: [SKSpriteNode] = [] // Array to hold multiple players
    var numberOfPlayers = 5
    let minimumDistance: CGFloat = 100.0
    var backgroundMusicPlayer: AVAudioPlayer?
    
    
    override func didMove(to view: SKView) {
        setUpNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
}

extension GameScene {
    func setUpNodes() {
        createBG()
        createMultiplePlayers()
        playBackgroundMusic(named: "backgroundMusic.mp3")
    }
    
    func createBG() {
        let bg = SKSpriteNode(imageNamed: "background")
        bg.anchorPoint = .zero
        bg.position = .zero
        bg.zPosition = -1.0
        addChild(bg)
    }
    
    // Function to play background music
    func playBackgroundMusic(named filename: String) {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop infinitely
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not play background music file: \(filename)")
            }
        }
    }
    
    // Function to create multiple butterflies (players) with a delay between each appearance
    func createMultiplePlayers() {
        for i in 0..<numberOfPlayers {
            let player = SKSpriteNode(imageNamed: "butterfly") // Replace "butterfly" with your actual image name
            player.size = CGSize(width: 50, height: 50)
            player.name = "player-\(i)"
            player.zPosition = 4.0
            
            let randomX = CGFloat.random(in: 0...frame.width)
            let startY = frame.height + player.size.height
            player.position = CGPoint(x: randomX, y: startY)
            player.isHidden = true
            addChild(player)
            players.append(player)
            
            // Move the player infinitely with a delay, so each player starts after the other
            let delay = SKAction.wait(forDuration: Double(i) * 5.0)
            let revealPlayer = SKAction.run {
                player.isHidden = false
                self.movePlayerInfinitely(player) // Start moving the player
            }
            let sequence = SKAction.sequence([delay, revealPlayer])
            run(sequence)
        }
    }
    
    // Function to move each butterfly player infinitely from top to bottom
    func movePlayerInfinitely(_ player: SKSpriteNode) {
        let screenHeight = frame.height
        let moveDistance = screenHeight + player.size.height
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -moveDistance), duration: TimeInterval(CGFloat.random(in: 4.0...8.0)))
        let resetPosition = SKAction.run {
            // Reset the player to start again from the top
            let newX = CGFloat.random(in: 0...self.frame.width)
            let newY = self.frame.height + player.size.height
            player.position = CGPoint(x: newX, y: newY)
        }
        // Create a sequence and repeat forever
        let sequence = SKAction.sequence([moveAction, resetPosition])
        let repeatForever = SKAction.repeatForever(sequence)
        
        player.run(repeatForever)
    }
    
}


extension GameScene {
    // Detect touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            for player in players {
                if player.contains(location) {
                    let tapSoundAction = SKAction.playSoundFileNamed("coin.mp3", waitForCompletion: false)
                    player.run(tapSoundAction)
                    player.isHidden = true
                    player.removeAllActions() // Stop the current animation
                    // then make the player reappear and continue moving
                    let reappearDelay = SKAction.wait(forDuration: TimeInterval.random(in: 2.0...3.0))
                    let reappear = SKAction.run {
                        player.isHidden = false
                        self.movePlayerInfinitely(player) // Resume the animation
                    }
                    let sequence = SKAction.sequence([reappearDelay, reappear])
                    player.run(sequence)
                }
            }
        }
    }
}
