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
    @IBOutlet weak var upperLeftDisplayPanel: NSView!
    @IBOutlet weak var timeDateLabel: NSTextField!
    
    var currentGameViewMainPanel : GameViewPanelViewController? = nil
    var starSystemInfoViewController : StarSystemInfoViewController!
    var playerInfoViewController : PlayerInfoViewController!
    
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
        
        playerInfoViewController = PlayerInfoViewController()
        playerInfoViewController.gameState = self.gameState
        playerInfoViewController.delegate = self
        
        self.addChild(playerInfoViewController)
        playerInfoViewController.view.frame = self.upperLeftDisplayPanel.bounds
        playerInfoViewController.widthLayoutConstaint.constant = self.upperLeftDisplayPanel.bounds.width
        playerInfoViewController.heightLayoutConstraint.constant = self.upperLeftDisplayPanel.bounds.height
        self.upperLeftDisplayPanel.addSubview(playerInfoViewController.view)
        
        self.starSystemInfoViewController.systemNumber = self.gameState.player.location
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(GameState.timeUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.timeWasUpdated(notification)
        }
        self.refreshTimeDisplay()
    }
    
    func installGamePanelInMainDisplayPanel(newPanel : GameViewPanelViewController) -> Bool {
        if currentGameViewMainPanel?.canRemovePanel() == false {
            return false
        }
        
        currentGameViewMainPanel?.view.removeFromSuperview()
        currentGameViewMainPanel?.removeFromParent()
        
        newPanel.gameState = self.gameState
        newPanel.delegate = self
        self.addChild(newPanel)
        newPanel.view.frame = self.centralDisplayPanel.bounds
        self.centralDisplayPanel.addSubview(newPanel.view)
        self.currentGameViewMainPanel = newPanel
        
        return true
    }
    
    func refreshTimeDisplay() {
        self.timeDateLabel.stringValue = self.gameState.timeStringDescription()
    }
    
    
    //MARK: - GameViewPanelDelegate
    
    func starSystemSelected(sender: GameViewPanelViewController, starIdent: Int) {
        if sender == self.currentGameViewMainPanel || self.currentGameViewMainPanel is StarMapViewController {
            (self.currentGameViewMainPanel as? StarMapViewController)?.centerOnStarSystem(starIdent)
            self.starSystemInfoViewController.systemNumber = starIdent
        }
    }
    
    func cancelButtonPressed(sender: GameViewPanelViewController) {
        let basicMenuViewController = BasicMenuViewController()
        _ = self.installGamePanelInMainDisplayPanel(newPanel: basicMenuViewController)
        self.starSystemInfoViewController.systemNumber = self.gameState.player.location
        
    }
    
    func shouldDisplayCancelButton(sender: GameViewPanelViewController) -> Bool {
        return true
    }
    
    func presentGameViewPanel(sender: GameViewPanelViewController, newPanel: GameViewPanelViewController) {
        _ = self.installGamePanelInMainDisplayPanel(newPanel: newPanel)
    }
    
    //MARK: - Notifications
    
    func timeWasUpdated(_ notification : Notification) {
        self.refreshTimeDisplay()
    }
    
}
