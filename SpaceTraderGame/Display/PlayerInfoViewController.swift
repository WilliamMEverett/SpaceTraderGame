//
//  PlayerInfoViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/10/22.
//

import Cocoa

class PlayerInfoViewController: GameViewPanelViewController {

    @IBOutlet weak var playerNameLabel: NSTextField!
    @IBOutlet weak var navigationScoreLabel: NSTextField!
    @IBOutlet weak var combatScoreLabel: NSTextField!
    @IBOutlet weak var negotiationScoreLabel: NSTextField!
    @IBOutlet weak var diplomacyScoreLabel: NSTextField!
    @IBOutlet weak var creditsScoreLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var hullLabel: NSTextField!
    @IBOutlet weak var engineLabel: NSTextField!
    @IBOutlet weak var fuelLabel: NSTextField!
    @IBOutlet weak var cargoLabel: NSTextField!
    
    @IBOutlet weak var heightLayoutConstraint : NSLayoutConstraint!
    @IBOutlet weak var widthLayoutConstaint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshView()
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Player.playerUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.playerWasUpdated(notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Ship.shipUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.playerWasUpdated(notification)
        }
    }
    
    private func refreshView() {
        self.playerNameLabel.stringValue = self.gameState.player.name
        self.navigationScoreLabel.stringValue = "\(self.gameState.player.navigation)"
        self.combatScoreLabel.stringValue = "\(self.gameState.player.combat)"
        self.negotiationScoreLabel.stringValue = "\(self.gameState.player.negotiation)"
        self.diplomacyScoreLabel.stringValue = "\(self.gameState.player.diplomacy)"
        self.creditsScoreLabel.stringValue = "\(self.gameState.player.money)"
        
        let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location)
        let systemName = system?.name ?? "Error"
        self.locationLabel.stringValue = systemName
        
        self.hullLabel.stringValue = String(format: "%0.0f/%0.0f", (self.gameState.player.ship.hull - self.gameState.player.ship.hullDamage),(self.gameState.player.ship.hull))
        self.engineLabel.stringValue = String(format: "%0.0f", self.gameState.player.ship.engine)
        self.fuelLabel.stringValue = String(format: "%0.1f/%0.0f", (self.gameState.player.ship.fuel),(self.gameState.player.ship.engine))
        self.cargoLabel.stringValue = String(format: "%0.0f/%0.0f", self.gameState.player.ship.totalCargoWeight(), self.gameState.player.ship.cargo)
        
    }
    
    //MARK: - Notification
    
    func playerWasUpdated(_ notification: Notification) {
        self.refreshView()
    }
}
