//
//  GameViewController.swift
//  bubbleSky
//
//  Created by sang gi kim on 9/5/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        if let view = self.view as! SKView? {
            // Create the game scene programmatically with proper size
            let scene = GameScene(size: view.bounds.size)
            
            // Set the scale mode to scale to fill the window
            scene.scaleMode = .aspectFill
            
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = false  // GameScene에서 제어
            #endif
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
