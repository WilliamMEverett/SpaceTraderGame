//
//  RefuelPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/10/22.
//

import Cocoa

class RefuelPanelViewController: GameViewPanelViewController, NSTextFieldDelegate {

    @IBOutlet weak var fullRefuelButton: NSButton!
    @IBOutlet weak var fullRefuelLabel: NSTextField!
    @IBOutlet weak var partialRefuelTextField: NSTextField!
    @IBOutlet weak var partialRefuelLabel: NSTextField!
    @IBOutlet weak var partialRefuelButton: NSButton!
    
    private var pricePerUnit : Double = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.partialRefuelTextField.stringValue = "1"
        self.refreshDisplay()
    }
    
    func refreshDisplay() {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        pricePerUnit = system.getFuelCost()
        
        let remainingAmount = self.gameState.player.ship.engine -  self.gameState.player.ship.fuel
        let fullPrice = Int(ceil(pricePerUnit*remainingAmount))
        self.fullRefuelLabel.stringValue = "Cost: \(fullPrice) cr"
        self.fullRefuelButton.isEnabled = self.gameState.player.money >= fullPrice
        
        let partialAmount = Double(self.partialRefuelTextField.stringValue) ?? -1
        if partialAmount < 0 {
            self.partialRefuelLabel.stringValue = "Cannot parse"
            self.partialRefuelButton.isEnabled = false
        }
        else {
            let partialPrice = Int(ceil(fmin(partialAmount, remainingAmount)*pricePerUnit))
            self.partialRefuelLabel.stringValue = "Cost: \(partialPrice) cr"
            self.partialRefuelButton.isEnabled = self.gameState.player.money >= partialPrice
        }
        
    }
    
    
    //MARK: - Actions
    @IBAction func fullRefuelPressed(_ sender: NSButton) {
        let remainingAmount = self.gameState.player.ship.engine -  self.gameState.player.ship.fuel
        let fullPrice = Int(ceil(pricePerUnit*remainingAmount))
        
        if self.gameState.player.money < fullPrice {
            self.refreshDisplay()
            return
        }
        self.gameState.player.ship.fuel = self.gameState.player.ship.engine
        self.gameState.player.money -= fullPrice
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    @IBAction func partialRefuelPressed(_ sender: NSButton) {
        let partialAmount = Double(self.partialRefuelTextField.stringValue) ?? -1
        if partialAmount < 0 {
            self.refreshDisplay()
            return
        }
        else {
            let remainingAmount = self.gameState.player.ship.engine -  self.gameState.player.ship.fuel
            let effectiveAmount = fmin(partialAmount, remainingAmount)
            let partialPrice = Int(ceil(effectiveAmount*pricePerUnit))
            if self.gameState.player.money < partialPrice {
                self.refreshDisplay()
                return
            }
            self.gameState.player.ship.fuel += effectiveAmount
            self.gameState.player.money -= partialPrice
            self.refreshDisplay()
        }
    }
    
    //MARK: - NSTextField Delegate
    
    func controlTextDidChange(_ obj: Notification) {
        let newString = self.partialRefuelTextField.stringValue
        
        var filteredString = ""
        var firstPoint = false
        for character in newString {
            if character == "." {
                if firstPoint {
                    continue
                }
                filteredString += String(character)
                firstPoint = true
                continue
            }
            if "0123456789".contains(character) {
                filteredString += String(character)
            }
        }
        self.partialRefuelTextField.stringValue = filteredString
        self.refreshDisplay()
    }
}
