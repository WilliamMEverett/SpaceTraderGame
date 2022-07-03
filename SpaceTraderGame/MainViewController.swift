//
//  ViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

class MainViewController: NSViewController {
    
    var gameViewController : GameViewController?
    var newGameWindowController : NewGameWindowController?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if self.gameViewController == nil {
            self.newGameWindowController = NewGameWindowController()
            weak var weakSelf = self
            self.view.window?.beginSheet(newGameWindowController!.window!, completionHandler: { response in
                if response == .OK {
                    weakSelf?.startGameWithGameState(weakSelf!.newGameWindowController!.gameState!)
                }
                weakSelf?.newGameWindowController = nil
            })
        }
    }
    
    private func startGameWithGameState(_ gameState : GameState) {
        
        self.gameViewController?.view.removeFromSuperview()
        self.gameViewController?.removeFromParent()
        
        self.gameViewController = GameViewController()
        self.gameViewController!.gameState = gameState
        
        self.addChild(self.gameViewController!)
        self.gameViewController!.view.frame = self.view.bounds
        self.view.addSubview(gameViewController!.view)
    }

}

