//
//  GameViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/5/22.
//

import Cocoa

class GameViewController: NSViewController, GameViewPanelDelegate {
    @IBOutlet var centralDisplayPanel : NSView!
    @IBOutlet var upperRightDisplayPanel : NSView!
    
    var starMapViewController : StarMapViewController!
    var starSystemInfoViewController : StarSystemInfoViewController!
    
    var gameState : GameState!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameState = GameState(playerName: "Incognito", starSystems: 1000)

        starMapViewController = StarMapViewController()
        starMapViewController.gameState = self.gameState
        starMapViewController.delegate = self
        
        self.addChild(starMapViewController)
        starMapViewController.view.frame = self.centralDisplayPanel.bounds
        self.centralDisplayPanel.addSubview(starMapViewController.view)
        
        starSystemInfoViewController = StarSystemInfoViewController()
        starSystemInfoViewController.gameState = self.gameState
        starSystemInfoViewController.delegate = self
        
        self.addChild(starSystemInfoViewController)
        starSystemInfoViewController.view.frame = self.upperRightDisplayPanel.bounds
        self.upperRightDisplayPanel.addSubview(starSystemInfoViewController.view)
        starSystemInfoViewController.systemNumber = 1
        
        self.starMapViewController.centerOnStarSystem(self.gameState.player.location)
        self.starSystemInfoViewController.systemNumber = self.gameState.player.location
    }
    
    
    //MARK: - GameViewPanelDelegate
    
    func starSystemSelected(sender: GameViewPanelViewController, starIdent: Int) {
        self.starMapViewController.centerOnStarSystem(starIdent)
        self.starSystemInfoViewController.systemNumber = starIdent
    }
}
