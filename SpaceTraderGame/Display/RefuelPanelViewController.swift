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
    
    @IBOutlet weak var fullRepairButton: NSButton!
    @IBOutlet weak var fullRepairLabel: NSTextField!
    @IBOutlet weak var partialRepairTextField: NSTextField!
    @IBOutlet weak var partialRepairLabel: NSTextField!
    @IBOutlet weak var partialRepairButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.partialRefuelTextField.stringValue = "1"
        self.partialRepairTextField.stringValue = "1"
        self.refreshDisplay()
    }
    
    func refreshDisplay() {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let fuelPricePerUnit = system.getFuelCost()
        let repairPricePerUnit = system.getRepairCost()
        
        let remainingAmount = self.gameState.player.ship.engine -  self.gameState.player.ship.fuel
        let fullPrice = Int(ceil(fuelPricePerUnit*remainingAmount))
        self.fullRefuelLabel.stringValue = "Cost: \(fullPrice) cr"
        self.fullRefuelButton.isEnabled = (self.gameState.player.money >= fullPrice && remainingAmount > 0)
        
        let partialAmount = Double(self.partialRefuelTextField.stringValue) ?? -1
        if partialAmount < 0 {
            self.partialRefuelLabel.stringValue = "Cannot parse"
            self.partialRefuelButton.isEnabled = false
        }
        else {
            let partialPrice = Int(ceil(fmin(partialAmount, remainingAmount)*fuelPricePerUnit))
            self.partialRefuelLabel.stringValue = "Cost: \(partialPrice) cr"
            self.partialRefuelButton.isEnabled = self.gameState.player.money >= partialPrice
        }
        
        let remainingRepairAmount = self.gameState.player.ship.hullDamage
        let fullRepairPrice = Int(ceil(repairPricePerUnit*remainingRepairAmount))
        self.fullRepairLabel.stringValue = "Cost: \(fullRepairPrice) cr"
        self.fullRepairButton.isEnabled = (self.gameState.player.money >= fullRepairPrice && remainingRepairAmount > 0)
        
        let partialRepairAmount = Double(self.partialRepairTextField.stringValue) ?? -1
        if partialRepairAmount < 0 {
            self.partialRepairLabel.stringValue = "Cannot parse"
            self.partialRepairButton.isEnabled = false
        }
        else {
            let partialRepairPrice = Int(ceil(fmin(partialRepairAmount, remainingRepairAmount)*repairPricePerUnit))
            self.partialRepairLabel.stringValue = "Cost: \(partialRepairPrice) cr"
            self.partialRepairButton.isEnabled = self.gameState.player.money >= partialRepairPrice
        }
        
    }
    
    
    //MARK: - Actions
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    @IBAction func fullRefuelPressed(_ sender: NSButton) {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let fuelPricePerUnit = system.getFuelCost()
        
        let remainingAmount = self.gameState.player.ship.engine -  self.gameState.player.ship.fuel
        let fullPrice = Int(ceil(fuelPricePerUnit*remainingAmount))
        
        if self.gameState.player.money < fullPrice {
            self.refreshDisplay()
            return
        }
        self.gameState.player.ship.fuel = self.gameState.player.ship.engine
        self.gameState.player.money -= fullPrice
        self.refreshDisplay()
    }
    
    @IBAction func partialRefuelPressed(_ sender: NSButton) {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let fuelPricePerUnit = system.getFuelCost()
        
        let partialAmount = Double(self.partialRefuelTextField.stringValue) ?? -1
        if partialAmount < 0 {
            self.refreshDisplay()
            return
        }
        else {
            let remainingAmount = self.gameState.player.ship.engine -  self.gameState.player.ship.fuel
            let effectiveAmount = fmin(partialAmount, remainingAmount)
            let partialPrice = Int(ceil(effectiveAmount*fuelPricePerUnit))
            if self.gameState.player.money < partialPrice {
                self.refreshDisplay()
                return
            }
            self.gameState.player.ship.fuel += effectiveAmount
            self.gameState.player.money -= partialPrice
            self.refreshDisplay()
        }
    }
    
    @IBAction func fullRepairPressed(_ sender: NSButton) {
        
        guard let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let repairPricePerUnit = system.getRepairCost()
        
        let remainingAmount = self.gameState.player.ship.hullDamage
        let fullPrice = Int(ceil(repairPricePerUnit*remainingAmount))
        
        if self.gameState.player.money < fullPrice {
            self.refreshDisplay()
            return
        }
        self.gameState.player.ship.hullDamage = 0
        self.gameState.player.money -= fullPrice
        self.refreshDisplay()
    }
    
    @IBAction func partialRepairPressed(_ sender: NSButton) {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let repairPricePerUnit = system.getRepairCost()
        
        let partialAmount = Double(self.partialRepairTextField.stringValue) ?? -1
        if partialAmount < 0 {
            self.refreshDisplay()
            return
        }
        else {
            let remainingAmount = self.gameState.player.ship.hullDamage
            let effectiveAmount = fmin(partialAmount, remainingAmount)
            let partialPrice = Int(ceil(effectiveAmount*repairPricePerUnit))
            if self.gameState.player.money < partialPrice {
                self.refreshDisplay()
                return
            }
            self.gameState.player.ship.hullDamage -= effectiveAmount
            self.gameState.player.money -= partialPrice
            self.refreshDisplay()
        }
    }
    
    //MARK: - NSTextField Delegate
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            return
        }
        let newString = textField.stringValue
        
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
        textField.stringValue = filteredString
        self.refreshDisplay()
    }
}
