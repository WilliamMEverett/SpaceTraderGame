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
    
    var currentGameViewMainPanel : GameViewPanelViewController? = nil
    var starSystemInfoViewController : StarSystemInfoViewController!
    
    var gameState : GameState!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameState = GameState(playerName: "Incognito", starSystems: 1000)
        
        let basicMenuViewController = BasicMenuViewController()
        _ = self.installGamePanelInMainDisplayPanel(newPanel: basicMenuViewController)
        
        starSystemInfoViewController = StarSystemInfoViewController()
        starSystemInfoViewController.gameState = self.gameState
        starSystemInfoViewController.delegate = self
        
        self.addChild(starSystemInfoViewController)
        starSystemInfoViewController.view.frame = self.upperRightDisplayPanel.bounds
        self.upperRightDisplayPanel.addSubview(starSystemInfoViewController.view)
        starSystemInfoViewController.systemNumber = 1
        
        self.starSystemInfoViewController.systemNumber = self.gameState.player.location
    }
    
    func installGamePanelInMainDisplayPanel(newPanel : GameViewPanelViewController) -> Bool {
        if currentGameViewMainPanel?.canRemovePanel() == false {
            return false
        }
        
        currentGameViewMainPanel?.removeFromParent()
        currentGameViewMainPanel?.view.removeFromSuperview()
        
        newPanel.gameState = self.gameState
        newPanel.delegate = self
        self.addChild(newPanel)
        newPanel.view.frame = self.centralDisplayPanel.bounds
        self.centralDisplayPanel.addSubview(newPanel.view)
        self.currentGameViewMainPanel = newPanel
        
        return true
    }
    
    
    //MARK: - GameViewPanelDelegate
    
    func starSystemSelected(sender: GameViewPanelViewController, starIdent: Int) {
        if self.currentGameViewMainPanel is StarMapViewController {
            (self.currentGameViewMainPanel as? StarMapViewController)?.centerOnStarSystem(starIdent)
            self.starSystemInfoViewController.systemNumber = starIdent
        }
    }
    
    func cancelButtonPressed(sender: GameViewPanelViewController) {
        if self.currentGameViewMainPanel is StarMapViewController {
            let basicMenuViewController = BasicMenuViewController()
            _ = self.installGamePanelInMainDisplayPanel(newPanel: basicMenuViewController)
            self.starSystemInfoViewController.systemNumber = self.gameState.player.location
        }
    }
    
    func shouldDisplayCancelButton(sender: GameViewPanelViewController) -> Bool {
        return true
    }
    
    func displayStarMap(sender: GameViewPanelViewController) {
        let starMapViewController = StarMapViewController()
        _ = self.installGamePanelInMainDisplayPanel(newPanel: starMapViewController)
        starMapViewController.centerOnStarSystem(self.gameState.player.location)
        self.starSystemInfoViewController.systemNumber = self.gameState.player.location
    }
    
}
