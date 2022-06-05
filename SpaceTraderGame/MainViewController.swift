//
//  ViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

class MainViewController: NSViewController {
    
    var gameViewController : GameViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameViewController = GameViewController()
        
        self.addChild(gameViewController)
        gameViewController.view.frame = self.view.bounds
        self.view.addSubview(gameViewController.view)
    }

}

