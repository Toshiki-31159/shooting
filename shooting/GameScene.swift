//
//  GameScene.swift
//  shooting
//
//  Created by 高橋星輝 on 2020/11/13.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var myShip = SKSpriteNode()
    var count = 0
    var enemyRate:CGFloat = 0.0
    var enemySaze = CGSize(width: 0, height: 0)
    var timer:Timer?
    
    let motionMgr = CMMotionManager()
    var accelarationX: CGFloat = 0.0
    
    var lifeLabelNode = SKLabelNode()
    var scoreLabelNode = SKLabelNode()
    var vc: GameViewController! //追加
    
    //life用プロパティ
    var life: Int = 0 {
        didSet{
            self.lifeLabelNode.text = "LIFE: \(life)"
        }
    }
    //score用プロパティ
    var score: Int = 0 {
        didSet{
            self.scoreLabelNode.text = "SCORE: \(score)"
        }
    }
    
    //カテゴリビットマスクの定義
    let myshipCategory: UInt32 = 0b0001
    let missileCategory: UInt32 = 0b0010
    let enemyCategory2: UInt32 = 0b1000
    let enemyCategory: UInt32 = 0b1100
    
    override func didMove(to view: SKView) {
        var sizeRate:CGFloat = 0.0
        var myShipSize = CGSize(width: 0.0, height: -1.0)
        let offSetY = frame.height / 20
    //画面への重力設定
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
    //自機の画像ファイル読み込み
        self.myShip = SKSpriteNode(imageNamed: "戦闘機")
    //自機のサイズ計算と位置設定
        sizeRate = (frame.width / 5) / self.myShip.size.width
        myShipSize = CGSize(width: self.myShip.size.width * sizeRate,
                            height: self.myShip.size.height * sizeRate)
        self.myShip.scale(to: myShipSize)
        self.myShip.position =
            CGPoint(x: 0, y: (-frame.height / 2) + offSetY + myShipSize.height / 2)
    //自機への物理ボディ、カテゴリビットマスク、衝突ビットマスクの設定
        self.myShip.physicsBody = SKPhysicsBody(rectangleOf: self.myShip.size)
        self.myShip.physicsBody?.categoryBitMask = self.myshipCategory
        self.myShip.physicsBody?.collisionBitMask = self.enemyCategory
        self.myShip.physicsBody?.contactTestBitMask = self.enemyCategory
        self.myShip.physicsBody?.isDynamic = true
    //自機の表示
        addChild(self.myShip)
        
    //敵の画像ファイルの読み込み
        let tempEnemy = SKSpriteNode(imageNamed: "岩1")
    //敵のサイズ計算
        self.enemyRate = (frame.width / 10) / tempEnemy.size.width
        self.enemySaze = CGSize(width: tempEnemy.size.width * self.enemyRate,
                                height: tempEnemy.size.height * self.enemyRate)
    //敵を表示するメソッドを1秒毎に呼び出し(moveEnemy)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true,
                                     block: { _ in
                                        self.moveEnemy()
                                     })
        
        //加速度センサーの取得間隔を設定取得処理
            motionMgr.accelerometerUpdateInterval = 0.05
        //加速度センサーの変更取得
            motionMgr.startAccelerometerUpdates(to: OperationQueue.current!) { (val, _) in
                guard let unwrapVal = val else {
                    return
                }
                let acc = unwrapVal.acceleration
                self.accelarationX = CGFloat(acc.x)
                print(acc.x)
            }
        
    //ライフの作成
        self.life = 3
        self.lifeLabelNode.fontName = "HelvecicaNeue-Bold"
        self.lifeLabelNode.fontColor = UIColor.white
        self.lifeLabelNode.fontSize = 30
        self.lifeLabelNode.position = CGPoint(
            x: frame.width / 2 - (self.lifeLabelNode.frame.width + 20),
            y: frame.height / 2 - self.lifeLabelNode.frame.height * 3)
        addChild(self.lifeLabelNode)
    //スコアの作成
        self.score = 0
        self.scoreLabelNode.fontName = "HelvecicaNeue-Bold"
        self.scoreLabelNode.fontColor = UIColor.white
        self.scoreLabelNode.fontSize = 30
        self.scoreLabelNode.position = CGPoint(
            x: -frame.width / 2 + self.scoreLabelNode.frame.width,
            y: frame.height / 2 - self.scoreLabelNode.frame.height * 3)
        addChild(self.scoreLabelNode)
    }
    
    //シーンの更新
    override func didSimulatePhysics() {
        let pos = self.myShip.position.x + self.accelarationX * 30
        if pos > frame.width / 2 - self.myShip.frame.width / 2 { return }
        if pos < -frame.width / 2 + self.myShip.frame.width / 2 { return }
        self.myShip.position.x = pos
    }
    
    //敵を表示するメソッド
    func moveEnemy() {
        let enemy1 = SKSpriteNode(imageNamed: "岩1")
        let enemy2 = SKSpriteNode(imageNamed: "岩2")
        let enemy3 = SKSpriteNode(imageNamed: "フェニックス")
        let enemys = [enemy1, enemy2, enemy3]
        let idx = Int.random(in: 0...2)
        let  enemy = enemys[idx]
        
    //敵のサイズを設定する
        enemy.scale(to: enemySaze)
    //敵のx方向の位置を設定する
        let xPos = (frame.width / CGFloat.random(in: 1...5)) - frame.width / 2
    //敵の位置を設定する
        enemy.position = CGPoint(x: xPos, y: frame.height / 2)

    //敵への物理ボディ、カテゴリビットマスク、衝突ビットマスクの設定
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        if enemy == enemys[1] {
            enemy.physicsBody?.categoryBitMask = self.enemyCategory2
        }
        else {
        enemy.physicsBody?.categoryBitMask = self.enemyCategory
        }
        enemy.physicsBody?.isDynamic = true
    //敵を表示する
        addChild(enemy)
    //指定した位置まで2.0秒で移動させる フェニックスは左右に揺れながら移動させる
        let move = SKAction.moveTo(y: -frame.height / 2, duration: 2)
        let moveA = SKAction.moveTo(x: frame.width / 4, duration: 0.5)
        let moveB = SKAction.moveTo(x: -frame.width / 4, duration: 0.5)
    //親からノードを削除する
        let remove = SKAction.removeFromParent()
    //アクションを連続して続行する
        enemy.run(SKAction.sequence([move, remove]))
        enemys[2].run(SKAction.sequence([moveA, moveB, moveA, moveB]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //画像ファイルの読み込み
        let missile = SKSpriteNode(imageNamed: "戦闘機銃弾")
    //ミサイルの発射位置の作成
        let missilePos = CGPoint(x: self.myShip.position.x,
                                 y: self.myShip.position.y +
                                    (self.myShip.size.height / 2) -
                                    (missile.size.height / 2))
    //ミサイル発射位置の設定
        missile.position = missilePos
    //ミサイルの物理ボディ、カテゴリビットマスク、衝突ビットマスクの設定
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.categoryBitMask = self.missileCategory
        missile.physicsBody?.collisionBitMask = self.enemyCategory
        missile.physicsBody?.contactTestBitMask = self.enemyCategory
        missile.physicsBody?.isDynamic = true
    //シーンにミサイルを表示する
        addChild(missile)
    //指定した位置まで1秒で移動する
        let move = SKAction.moveTo(y: frame.height + missile.size.height,
                                   duration: 1.0)
    //親からノードを削除する
        let remove = SKAction.removeFromParent()
    //アクションを連続して実行する
        missile.run(SKAction.sequence([move, remove]))
    }
    
    //衝突時のメソッド
    func didBegin(_ contact: SKPhysicsContact) {
        
    //敵が岩2の場合２回目までは破壊されない
        if  contact.bodyA.categoryBitMask == enemyCategory2 &&
            contact.bodyB.categoryBitMask == missileCategory && self.count < 2 ||
            contact.bodyA.categoryBitMask == missileCategory &&
            contact.bodyB.categoryBitMask == enemyCategory2 && self.count < 2 {
                self.count += 1
            if  contact.bodyA.categoryBitMask == missileCategory {
                    contact.bodyA.node?.removeFromParent()
            }
            else {
                    contact.bodyB.node?.removeFromParent()
            }
        }
    //その他の敵の衝突後の処理
        else {
    //炎のパーティクルの読み込みと表示
            let explosion = SKEmitterNode(fileNamed: "explosion")
            explosion?.position = contact.bodyA.node?.position ?? CGPoint(x: 0, y: 0)
            addChild(explosion!)
    //衝突したノードを削除する
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        
    //炎のパーティクルを0.５秒表示して削除
            self.run(SKAction.wait(forDuration: 0.5)) {
                explosion?.removeFromParent()
            }
    
    //岩2の３回目の処理
            if  contact.bodyA.categoryBitMask == enemyCategory2 &&
                contact.bodyB.categoryBitMask == missileCategory && self.count == 2 ||
                contact.bodyA.categoryBitMask == missileCategory &&
                contact.bodyB.categoryBitMask == enemyCategory2 && self.count == 2 {
                    self.count = 0
                }
    //ミサイルが敵に当たった時の処理
            if contact.bodyA.categoryBitMask == missileCategory ||
                contact.bodyB.categoryBitMask == missileCategory {
                self.score += 10
            }
    //自機が爆発した時の処理
            if contact.bodyA.categoryBitMask == myshipCategory ||
                contact.bodyB.categoryBitMask == myshipCategory {
                self.life -= 1
                self.run(SKAction.wait(forDuration: 1)) {
                    self.restart()
                }
            }
        }
    }
    //リスタート処理
    func restart() {
        if self.life <= 0 {
            vc.dismiss(animated: true, completion: nil)
        }
        addChild(self.myShip)
    }
}
