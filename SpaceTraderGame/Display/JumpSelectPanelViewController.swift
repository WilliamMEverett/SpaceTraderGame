//
//  JumpSelectPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/10/22.
//

import Cocoa

class JumpSelectPanelViewController: GameViewPanelViewController, GameViewPanelDelegate {
    
    @IBOutlet var holderView : NSView!
    @IBOutlet var cancelButton : NSButton!
    @IBOutlet weak var destinationLabel: NSTextField!
    @IBOutlet weak var distanceLabel: NSTextField!
    @IBOutlet weak var timeFuelLabel: NSTextField!
    @IBOutlet weak var jumpButton: NSButton!
    
    var selectedStar : Int = 0
    var starMapController : StarMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.isHidden = self.delegate?.shouldDisplayCancelButton(sender: self) == false
        
        starMapController = StarMapViewController()
        starMapController.gameState = self.gameState
        starMapController.delegate = self
        starMapController.centerOnStarSystem(self.gameState.player.location)
        
        self.addChild(starMapController)
        starMapController.view.frame = self.holderView.bounds
        self.holderView.addSubview(starMapController.view)
        self.refreshView()
    }
    
    private func refreshView() {
        self.jumpButton.isEnabled = false
        
        self.distanceLabel.stringValue = ""
        self.timeFuelLabel.stringValue = ""
        
        if self.selectedStar == 0 || self.selectedStar == self.gameState.player.location {
            self.destinationLabel.stringValue = "Select a destination to jump to"
        }
        else {
            guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
                return
            }
            guard let destinationStar = self.gameState.galaxyMap.getSystemForId(self.selectedStar) else {
                return
            }
            
            self.destinationLabel.stringValue = destinationStar.name
            
            if !currentStar.connectingSystems.contains(self.selectedStar) {
                self.distanceLabel.stringValue = "You must select a system adjacent to your current location"
            }
            else {
                let distance = currentStar.position.distance(destinationStar.position)
                self.distanceLabel.stringValue = String(format:"%.1f ly",distance)
                
                let time = self.gameState.player.timeToJump(distance: distance)
                let fuel = self.gameState.player.fuelToTravelTime(time: time)
                
                if fuel > self.gameState.player.ship.fuel {
                    self.timeFuelLabel.stringValue = String(format: "You do not have enough fuel. This jump requires %.1f fuel.", fuel)
                }
                else {
                    self.jumpButton.isEnabled = true
                    self.timeFuelLabel.stringValue = String(format: "This jump will take %.1f days and %.1f fuel", time, fuel)
                }
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    @IBAction func jumpButtonPressed(_ sender: NSButton) {
        
        let res = self.gameState.player.performJump(from: self.gameState.player.location, to: self.selectedStar, galaxyMap: self.gameState.galaxyMap)
        if res.success {
            self.gameState.time += res.timeElapsed
            self.delegate?.cancelButtonPressed(sender: self)
        }
    }
    
    //MARK: - GameViewPanelDelegate
    
    func starSystemSelected(sender: GameViewPanelViewController, starIdent: Int) {
        self.selectedStar = starIdent
        self.refreshView()
        self.delegate?.starSystemSelected(sender: self, starIdent: starIdent)
    }
    
    func cancelButtonPressed(sender: GameViewPanelViewController) {
        
    }
    
    func shouldDisplayCancelButton(sender: GameViewPanelViewController) -> Bool {
        return false
    }
    
    func presentGameViewPanel(sender: GameViewPanelViewController, newPanel: GameViewPanelViewController) {
    }
    
}
