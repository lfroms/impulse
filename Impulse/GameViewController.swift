//
//  GameViewController.swift
//  Impulse
//
//  Created by Lukas Romsicki on 2016-05-23.
//  Copyright (c) 2016 Lukas Romsicki. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        // configures the scene
        
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {
            let skView = self.view as! SKView
            skView.showsNodeCount = false
            skView.showsFPS = false
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    // handles segue from popup menu to game view
    @IBAction func returnToGame(_ segue:UIStoryboardSegue) {}
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
