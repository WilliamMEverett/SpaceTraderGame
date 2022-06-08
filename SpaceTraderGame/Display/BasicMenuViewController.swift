//
//  BasicMenuViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/7/22.
//

import Cocoa

class BasicMenuViewController: GameViewPanelViewController {

    @IBOutlet weak var currentSystemLabel: NSTextField!
    @IBOutlet weak var inStationLabel: NSTextField!
    @IBOutlet weak var creditsLabel: NSTextField!
    @IBOutlet weak var fuelLabel: NSTextField!
    @IBOutlet weak var timestampLabel: NSTextField!
    @IBOutlet weak var dockButton: NSButton!
    @IBOutlet weak var jumpButton: NSButton!
    @IBOutlet weak var starmapButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.refreshView()
    }
    
    private func refreshView() {
        self.currentSystemLabel.stringValue = (self.gameState.galaxyMap.getSystemForId(self.gameState.player.location)?.name) ?? "Error"
        
        self.inStationLabel.stringValue = self.gameState.player.inStation ? "Docked" : "Outer System"
        self.creditsLabel.stringValue = "\(self.gameState.player.money) cr"
        self.fuelLabel.stringValue = String(format: "%.1f", self.gameState.player.ship.fuel)
        self.timestampLabel.stringValue = self.gameState.timeStringDescription()
        if self.gameState.player.inStation {
            self.dockButton.title = "Leave Dock"
        }
        else {
            self.dockButton.title = "Dock"
        }
        let fuelRequired = self.gameState.player.ship.fuelToTravelTime(time: Ship.timeToLeaveDock())
        self.dockButton.isEnabled = self.gameState.player.ship.fuel >= fuelRequired
        
        self.jumpButton.isEnabled = !self.gameState.player.inStation
        
    }
    
    //MARK: - Actions
    @IBAction func dockButtonPressed(_ sender: NSButton) {
        let fuelRequired = self.gameState.player.ship.fuelToTravelTime(time: Ship.timeToLeaveDock())
        if self.gameState.player.ship.fuel >= fuelRequired {
            self.gameState.player.ship.fuel -= fuelRequired
            self.gameState.time += Ship.timeToLeaveDock()
            self.gameState.player.inStation = !self.gameState.player.inStation
        }
        self.refreshView()
    }
    
    @IBAction func jumpButtonPressed(_ sender: Any) {
    }
    
    @IBAction func starmapButtonPressed(_ sender: Any) {
        self.delegate?.displayStarMap(sender: self)
    }
    
}
