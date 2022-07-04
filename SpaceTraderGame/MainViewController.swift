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
            self.showNewGameDialog()
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
    
    private func showNewGameDialog() {
        self.newGameWindowController = NewGameWindowController()
        weak var weakSelf = self
        self.view.window?.beginSheet(newGameWindowController!.window!, completionHandler: { response in
            if response == .OK {
                weakSelf?.startGameWithGameState(weakSelf!.newGameWindowController!.gameState!)
            }
            weakSelf?.newGameWindowController = nil
        })
    }
    
    //MARK: - Actions
    
    @IBAction func newMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil {
            return
        }
        
        if self.gameViewController?.gameState.gameOver == false && self.gameViewController?.gameState.saved == false {
            let al = NSAlert()
            al.alertStyle = .informational
            al.messageText = "Game in Progress"
            al.informativeText = "You have an unsaved game in progress. Continuing will end this game."
            al.addButton(withTitle: "OK")
            al.addButton(withTitle: "Cancel")
            weak var weakSelf = self
            al.beginSheetModal(for: self.view.window!) { response in
                if response == .alertFirstButtonReturn {
                    weakSelf?.showNewGameDialog()
                }
            }
        }
        else {
            self.showNewGameDialog()
        }
    }

}

