//
//  GameOverScene.swift
//  SpaceBattler
//
//  Created by Hong Sen Du on 11/29/17.
//  Copyright © 2017 Hong Sen Du. All rights reserved.
//

import Foundation
import SpriteKit

let restartLabel=SKLabelNode(fontNamed:"The Bold Font")

class GameOverScene: SKScene{
    override func didMove(to view: SKView) {
        let background=SKSpriteNode(imageNamed:"background")
        background.position=CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition=0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed:"The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize=200
        gameOverLabel.fontColor=SKColor.white
        gameOverLabel.position=CGPoint(x: self.size.width*0.5,y:self.size.height*0.7)
        gameOverLabel.zPosition=1
        self.addChild(gameOverLabel)
        
        let scoreLabel=SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text="Score: \(gameScore)"
        scoreLabel.fontSize=125
        scoreLabel.fontColor=SKColor.white
        scoreLabel.position=CGPoint(x:self.size.width/2,y:self.size.height*0.55)
        scoreLabel.zPosition=1
        self.addChild(scoreLabel)
        
        let defaults=UserDefaults()
        var highScore=defaults.integer(forKey:"highScoreSaved")
        
        if gameScore > highScore{
            highScore=gameScore
            defaults.set(highScore,forKey:"highScoreSaved")
        }
        
        let highScoreLabel=SKLabelNode(fontNamed:"The Bold Font")
        highScoreLabel.text="High Score: \(highScore)"
        highScoreLabel.fontSize=125
        highScoreLabel.fontColor=SKColor.white
        highScoreLabel.zPosition=1
        highScoreLabel.position=CGPoint(x:self.size.width/2,y: self.size.height*0.45)
        self.addChild(highScoreLabel)
        
        let restartLabel=SKLabelNode(fontNamed:"The Bold Font")
        restartLabel.text="Touch Anywhere to restart"
        restartLabel.fontSize=60
        restartLabel.fontColor=SKColor.red
        restartLabel.zPosition=1
        restartLabel.position=CGPoint(x:self.size.width/2,y: self.size.height*0.3)
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                let sceneToMoveTo=GameScene(size: self.size)
                sceneToMoveTo.scaleMode=self.scaleMode
                let myTransition=SKTransition.fade(withDuration:0.5)
                self.view!.presentScene(sceneToMoveTo,transition: myTransition)
        
    }
}
