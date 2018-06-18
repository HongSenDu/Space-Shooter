//
//  GameScene.swift
//  SpaceBattler
//
//  Created by Hong Sen Du on 11/26/17.
//  Copyright © 2017 Hong Sen Du. All rights reserved.
//

import SpriteKit
import GameplayKit


var gameScore=0

class GameScene: SKScene, SKPhysicsContactDelegate   {
    var levelNumber=0
    let scoreLabel=SKLabelNode(fontNamed: "The Bold Font")
    var livesNumber=5
    let livesLabel=SKLabelNode(fontNamed: "The Bold Font")
    let player  = SKSpriteNode(imageNamed: "playerShip")
    let gameArea:CGRect
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState=gameState.inGame
    
    
    struct PhysicsCategories{
        static let None: UInt32=0
        static let Player: UInt32=0b1
        static let Bullet: UInt32=0b10
        static let Enemy: UInt32=0b100
        
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    func random(with min:CGFloat,max:CGFloat)->CGFloat{
        return random()*(max-min)+min
    }
    override init(size:CGSize){
        
        let maxAspectRatio: CGFloat=16.0/9.0
        let playableWidth=size.height/maxAspectRatio
        let margin=(size.width-playableWidth)/2
        gameArea=CGRect(x:margin,y:0,width:playableWidth,height:size.height)
        
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        gameScore=0
        self.physicsWorld.contactDelegate=self
        
        for i in 0...1{
        let background = SKSpriteNode(imageNamed:"background")
        background.size=self.size
            background.anchorPoint=CGPoint(x:0.5,y:0)
        background.position=CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
        background.zPosition=0
        background.name="Background"
        self.addChild(background)
        }
        player.setScale(1)
        player.position=CGPoint(x:self.size.width/2,y:self.size.height/5)
        player.zPosition=2
        player.physicsBody=SKPhysicsBody(rectangleOf:player.size)
        player.physicsBody!.affectedByGravity=false
        player.physicsBody!.categoryBitMask=PhysicsCategories.Player
        player.physicsBody!.collisionBitMask=PhysicsCategories.None
        player.physicsBody!.contactTestBitMask=PhysicsCategories.Enemy
        
        self.addChild(player)
        
        scoreLabel.text="Score: 0"
        scoreLabel.fontSize=70
        scoreLabel.fontColor=SKColor.white
        scoreLabel.horizontalAlignmentMode=SKLabelHorizontalAlignmentMode.left
        scoreLabel.position=CGPoint(x: self.size.width*0.15,y:self.size.height*0.9)
        scoreLabel.zPosition=100
        self.addChild(scoreLabel)
        
        livesLabel.text="Lives: 5"
        livesLabel.fontSize=70
        livesLabel.fontColor=SKColor.white
        livesLabel.horizontalAlignmentMode=SKLabelHorizontalAlignmentMode.right
        livesLabel.position=CGPoint(x:self.size.width*0.85, y:self.size.height*0.9)
        livesLabel.zPosition=100
        self.addChild(livesLabel)
        
        
        startNewLevel()
    }
    var lastUpdateTime: TimeInterval=0
    var deltaFrameTime: TimeInterval=0
    var amountToMovePerSec: CGFloat=600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime==0{
            lastUpdateTime=currentTime
        }
        else{
            deltaFrameTime=currentTime-lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground=amountToMovePerSec*CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background"){
        background, stop in
            if self.currentGameState==gameState.inGame{
                background.position.y-=amountToMoveBackground
            }
        
            if background.position.y < -self.size.height{
                background.position.y+=self.size.height*2
            }
        }
    }
    
    
    
    
    func loseLife(){
        livesNumber-=1
        livesLabel.text="Lives: \(livesNumber)"
        
        let scaleUp=SKAction.scale(to:1.5, duration:0.2)
        let scaleDown=SKAction.scale(to:1, duration:0.2)
        let scaleSequence=SKAction.sequence([scaleUp,scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber==0{
            gameOver()
        }
    }
    
    func gameOver(){
        currentGameState=gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
            
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeScene=SKAction.run(changeToEndScene)
        let waitToChangeScene=SKAction.wait(forDuration:1)
        let changeSceneSequence=SKAction.sequence([waitToChangeScene,changeScene])
        self.run(changeSceneSequence)
        
        
    }
    
    func changeToEndScene(){
        let sceneToMoveTo = GameOverScene(size:self.size)
        sceneToMoveTo.scaleMode=self.scaleMode
        let Mytransitions=SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo,transition: Mytransitions)
    }
    
    func addScore(){
        gameScore+=1
        scoreLabel.text="Score: \(gameScore)"
        
        if gameScore==5||gameScore==10||gameScore==20{
            startNewLevel()
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var body1=SKPhysicsBody()
        var body2=SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1=contact.bodyA
            body2=contact.bodyB
        }
        else{
            body1=contact.bodyB
            body2=contact.bodyA
        }
        
        if body1.categoryBitMask==PhysicsCategories.Player && body2.categoryBitMask==PhysicsCategories.Enemy{
            if body1.node != nil{
            spawnExplosion(SpawnPosition: body1.node!.position)
            }
            if body2.node != nil {
            spawnExplosion(SpawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            gameOver()
        }
        
        if body1.categoryBitMask==PhysicsCategories.Bullet && body2.categoryBitMask==PhysicsCategories.Enemy{
            addScore()
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return
                }
                else{
                    spawnExplosion(SpawnPosition: body2.node!.position)
                }
            }

            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
    }
    
    func spawnExplosion(SpawnPosition: CGPoint){
        let explosion=SKSpriteNode(imageNamed: "explosion")
        explosion.position=SpawnPosition
        explosion.zPosition=3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn=SKAction.scale(to:1,duration: 0.1)
        let fadeOut=SKAction.fadeOut(withDuration: 0.1)
        let delete=SKAction.removeFromParent()
        let explosionSequence=SKAction.sequence([scaleIn,fadeOut,delete])
        explosion.run(explosionSequence)
        
    }
    
    func bulletFire(){
        let bullet=SKSpriteNode(imageNamed: "bullet")
        bullet.name="Bullet"
        bullet.setScale(1)
        bullet.position=player.position
        bullet.zPosition=1
        bullet.physicsBody=SKPhysicsBody(rectangleOf:bullet.size)
        bullet.physicsBody!.affectedByGravity=false
        bullet.physicsBody!.categoryBitMask=PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask=PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask=PhysicsCategories.Enemy
        self.addChild(bullet)
        let moveBullet=SKAction.moveTo(y: self.size.height+bullet.size.height, duration: 1)
        let deleteBullet=SKAction.removeFromParent()
        let bulletSequence=SKAction.sequence([moveBullet,deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func Enemy(){
        let randomXStart=random(with: gameArea.minX,max:gameArea.maxX)
        let randomXEnd=random(with: gameArea.minX,max:gameArea.maxX)
        let start=CGPoint(x: randomXStart, y:self.size.height*1.2)
        let end=CGPoint(x: randomXEnd, y:-self.size.height/5)
        
        let enemy=SKSpriteNode(imageNamed: "enemyShip")
        enemy.name="Enemy"
        enemy.setScale(1)
        enemy.position=start
        enemy.zPosition=2
        enemy.physicsBody=SKPhysicsBody(rectangleOf:enemy.size)
        enemy.physicsBody!.affectedByGravity=false
        enemy.physicsBody!.categoryBitMask=PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask=PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask=PhysicsCategories.Player|PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy=SKAction.move(to:end, duration:2)
        let deleteEnemy=SKAction.removeFromParent()
        let loseALifeAction=SKAction.run(loseLife)
        let enemySequence=SKAction.sequence([moveEnemy,deleteEnemy,loseALifeAction])
        
        if currentGameState==gameState.inGame{
        enemy.run(enemySequence)
        }
        
        let dx=end.x-start.x
        let dy=end.y-start.y
        
        let amountToRotate = atan2(dy,dx)
        enemy.zRotation = amountToRotate
    }
    
    func startNewLevel(){
        levelNumber+=1
        if self.action(forKey: "SpawningEnemies") != nil{
            self.removeAction(forKey: "SpawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        switch levelNumber{
        case 1:levelDuration=1.2
        case 2:levelDuration=1
        case 3:levelDuration=0.8
        case 4:levelDuration=0.5
        default:
            levelDuration=0.5
            print("Cannot find level")
        }
        
        let spawn=SKAction.run(Enemy)
        let waitToSpawn=SKAction.wait(forDuration: levelDuration)
        let spawnSequence=SKAction.sequence([waitToSpawn,spawn])
        let spawnForever=SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "SpawningEnemies")
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState==gameState.inGame{
        bulletFire()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch=touch.location(in:self)
            let previousPointOfTouch=touch.previousLocation(in:self)
            
            let amountOfDrag=pointOfTouch.x-previousPointOfTouch.x
            
            if currentGameState==gameState.inGame{
               player.position.x+=amountOfDrag
            }
            
            
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
}

