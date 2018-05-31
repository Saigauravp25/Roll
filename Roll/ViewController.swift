//
//  ViewController.swift
//  ZigZag
//
//  Created by Saigaurav Purushothaman on 5/21/18.
//  Copyright © 2018 saipurush. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var PillarCollection: [UIImageView]!
    @IBOutlet var PillarTopCollection: [UIImageView]!
    @IBOutlet var PillarFromLeftConstraints: [NSLayoutConstraint]!
    @IBOutlet var PillarFromTopConstraints: [NSLayoutConstraint]!
    @IBOutlet var PillarTopFromLeftConstraints: [NSLayoutConstraint]!
    @IBOutlet var PillarTopFromTopConstraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var BallFromLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var BallFromTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var GameView: UIView!
    @IBOutlet weak var Ball: UIImageView!
    @IBOutlet weak var GameOver: UIImageView!
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var ScoreBoard: UIImageView!
    @IBOutlet weak var Retry: UIButton!
    @IBOutlet weak var Play: UIButton!
    @IBOutlet weak var HighScoreOnBoard: UILabel!
    @IBOutlet weak var ScoreOnBoard: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    
    var timer = Timer()
    var ballTimer = Timer()
    var tapsValid: Bool?
    var ballRight: Bool?
    var acceleration: Double = 1
    var startingBuffer: Int = 5
    
    var score: Int = 0
    var highScore: Int = 0
    let defaults: UserDefaults = UserDefaults.standard
    let speed: Double = 0.0225
    
    
    @IBAction func Play(_ sender: Any) {
        tapsValid = true
        ballRight = true
        
        self.PillarFromTopConstraints[0].constant = self.GameView.frame.size.height / 2
        self.PillarFromLeftConstraints[0].constant = self.GameView.frame.size.width / 2 - self.PillarCollection[0].frame.size.width / 2
        
        self.BallFromTopConstraint.constant = self.PillarFromTopConstraints[0].constant + self.PillarCollection[0].frame.size.height / 12
        self.BallFromLeftConstraint.constant = self.GameView.frame.size.width / 2 - self.Ball.frame.size.width / 2
        
        timer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(movement), userInfo: nil, repeats: true)
        
        for index in 1..<PillarCollection.count {
            let leftConstraint = PillarFromLeftConstraints[index - 1]
            let topConstraint = PillarFromTopConstraints[index - 1]
            let point = pillarPlacement(x: leftConstraint.constant, y: topConstraint.constant)
            PillarFromLeftConstraints[index].constant = point.x
            PillarFromTopConstraints[index].constant = point.y
        }
        for index in 0..<PillarTopCollection.count {
            self.PillarTopFromTopConstraints[index].constant = PillarFromTopConstraints[index].constant
            self.PillarTopFromLeftConstraints[index].constant = PillarFromLeftConstraints[index].constant
        }

        self.Ball.isHidden = false
        self.GameOver.isHidden = true
        self.Logo.isHidden = true
        self.Retry.isHidden = true
        self.ScoreBoard.isHidden = true
        self.Play.isHidden = true
        ScoreOnBoard.isHidden = true
        HighScoreOnBoard.isHidden = true
        ScoreLabel.isHidden = false
        
        for currentPillar in PillarCollection {
            GameView.sendSubview(toBack: currentPillar)
            currentPillar.isHidden = false
        }
        for currentPillarTop in PillarTopCollection {
            currentPillarTop.isHidden = false
            GameView.sendSubview(toBack: currentPillarTop)
        }
    }
    
    @IBAction func Retry(_ sender: Any) {
        self.viewDidLoad()
        self.Play(Play)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingBuffer = 5
        score = 0
        ScoreLabel.text = String(score)
        highScore = defaults.integer(forKey: "HighScore")
        acceleration = 1
        
        ballTimer.invalidate()
        self.Ball.isHidden = true
        self.GameOver.isHidden = true
        self.Logo.isHidden = false
        self.Retry.isHidden = true
        self.ScoreBoard.isHidden = true
        self.Play.isHidden = false
        self.ScoreLabel.isHidden = true
        self.ScoreOnBoard.isHidden = true
        self.HighScoreOnBoard.isHidden = true
        
        for currentPillar in PillarCollection {
            currentPillar.isHidden = true
        }
        for currentPillarTop in PillarTopCollection {
            currentPillarTop.isHidden = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if tapsValid == true {
            ballRight = !ballRight!
            score += 1
            ScoreLabel.text = String(score)
        }
    }
    
    @objc func movement() -> Void {
        if ballRight! {
            self.BallFromLeftConstraint.constant += self.PillarCollection[0].frame.size.width / 24
        } else {
            self.BallFromLeftConstraint.constant -= self.PillarCollection[0].frame.size.width / 24
        }
        
        var touchesAPillarTop: Bool = false
        for currentPillarTop in PillarTopCollection {
            let intersectionRect = Ball.frame.intersection(currentPillarTop.frame)
            let areaOfIntersection = intersectionRect.size.width * intersectionRect.size.height
            let areaOfBallRect = Ball.frame.size.width * Ball.frame.size.height
            let touchesCurrentPillarTop = areaOfIntersection > 0.6 * areaOfBallRect
            touchesAPillarTop = touchesCurrentPillarTop || touchesAPillarTop
        }

        if !touchesAPillarTop {
            gameOver()
        }
        
        for index in 0..<PillarCollection.count {
            PillarFromTopConstraints[index].constant += self.PillarCollection[0].frame.size.height / 56
            if PillarFromTopConstraints[index].constant > GameView.frame.size.height - 2 * PillarCollection[0].frame.size.height {
                PillarFromTopConstraints[index].constant += self.PillarCollection[0].frame.size.height / 56
            }
        }
        for index in 0..<PillarCollection.count {
            let y = PillarFromTopConstraints[index].constant
            movePillarTop(yPos: y, pillarNumber: index)
        }
        for index in 0..<PillarCollection.count {
            let x = PillarFromLeftConstraints[index].constant
            let y = PillarFromTopConstraints[index].constant
            let point = regeneratePillars(xPos: x, yPos: y, pillarNumber: index)
            
            PillarFromLeftConstraints[index].constant = point.x
            PillarFromTopConstraints[index].constant = point.y
        }
    }
    
    func regeneratePillars(xPos: CGFloat, yPos: CGFloat, pillarNumber: Int) -> CGPoint {
        var point = CGPoint(x: xPos, y: yPos)
        if pillarTooLow(y: yPos) {
            let numOfPillars = PillarCollection.count
            let newIndex = (pillarNumber + (numOfPillars - 1)) % numOfPillars
            let newX = PillarFromLeftConstraints[newIndex].constant
            let newY = PillarFromTopConstraints[newIndex].constant
            point = pillarPlacement(x: newX, y: newY)
            GameView.sendSubview(toBack: PillarCollection[pillarNumber])
        }
        return point
    }

    func movePillarTop(yPos: CGFloat, pillarNumber: Int) -> Void {
        if pillarBelowMiddle(y: yPos) {
            let numOfPillars = PillarCollection.count
            print(pillarNumber)
            for indexOfPillarTop in 0..<PillarTopCollection.count {
                    let newIndex = (pillarNumber + (numOfPillars + indexOfPillarTop - 3)) % numOfPillars
                    PillarTopFromLeftConstraints[indexOfPillarTop].constant = PillarFromLeftConstraints[newIndex].constant
                    PillarTopFromTopConstraints[indexOfPillarTop].constant = PillarFromTopConstraints[newIndex].constant
                    GameView.sendSubview(toBack: PillarTopCollection[indexOfPillarTop])
            }
        }
    }
    
    func gameOver() -> Void {
        tapsValid = false
        if score > highScore {
            highScore = score
        }
        defaults.set(highScore, forKey: "HighScore")
        self.ballTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(animateFallingBall), userInfo: nil, repeats: true)

        tapsValid = false
        timer.invalidate()
        ScoreLabel.isHidden = true
        GameOver.isHidden = true
        Retry.isHidden = false
        ScoreBoard.isHidden = false
        ScoreOnBoard.isHidden = false
        HighScoreOnBoard.isHidden = false
        ScoreOnBoard.text = ScoreLabel.text
        HighScoreOnBoard.text = String(highScore)
    }
    
    @objc func animateFallingBall() {
        self.BallFromTopConstraint.constant += CGFloat(0.05 * acceleration)
        if ballRight! {
            self.BallFromLeftConstraint.constant += 0.1
        } else {
            self.BallFromLeftConstraint.constant -= 0.1
        }
        acceleration *= 1.01
        if acceleration > 10 {
            GameView.sendSubview(toBack: Ball)
        }
        if Ball.center.x < 0 - Ball.frame.size.width || Ball.center.x > GameView.frame.size.width + Ball.frame.size.width || Ball.center.y > GameView.frame.size.height + Ball.frame.size.height {
            ballTimer.invalidate()
        }
    }
    
    func pillarTooLow(y: CGFloat) -> Bool {
        return y > self.view.frame.size.height
    }
    
    func pillarBelowMiddle(y: CGFloat) -> Bool {
        return y > self.view.frame.size.height / 2 - self.PillarTopCollection[0].frame.size.height && y < self.view.frame.size.height / 2
    }
    
    func pillarPlacement(x: CGFloat, y: CGFloat) -> CGPoint {
        var newPillarX: CGFloat
        var newPillarY: CGFloat
        var randomNum: Int
        
        if startingBuffer > 0 {
            randomNum = 1
            startingBuffer -= 1
        } else {
            randomNum  = Int(arc4random() % 2)
        }
        
        if randomNum == 1 {
            newPillarX = x + PillarCollection[0].frame.size.width / 2.0256
            newPillarY = y - PillarCollection[0].frame.size.height / 4.8966
            if newPillarX >= self.view.frame.size.width - self.PillarCollection[0].frame.size.width {
                newPillarX = x - PillarCollection[0].frame.size.width / 1.9750
                newPillarY = y - PillarCollection[0].frame.size.height / 4.7333
            }
        } else {
            newPillarX = x - PillarCollection[0].frame.size.width / 1.9750
            newPillarY = y - PillarCollection[0].frame.size.height / 4.7333
            if newPillarX <= self.PillarCollection[0].frame.size.width {
                newPillarX = x + PillarCollection[0].frame.size.width / 2.0256
                newPillarY = y - PillarCollection[0].frame.size.height / 4.8966
            }
        }
        let newPillarCenter = CGPoint(x: newPillarX, y: newPillarY)
        return newPillarCenter
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

