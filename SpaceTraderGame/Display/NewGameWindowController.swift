//
//  NewGameWindowController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 7/3/22.
//

import Cocoa

class NewGameWindowController: NSWindowController {

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var navigationScoreLabel: NSTextField!
    @IBOutlet weak var combatScoreLabel: NSTextField!
    @IBOutlet weak var negotiationScoreLabel: NSTextField!
    @IBOutlet weak var diplomacyScoreLabel: NSTextField!
    @IBOutlet weak var pointsRemainingLabel: NSTextField!
    
    @IBOutlet weak var navigationPlusButton: NSButton!
    @IBOutlet weak var navigationMinusButton: NSButton!
    @IBOutlet weak var combatPlusButton: NSButton!
    @IBOutlet weak var combatMinusButton: NSButton!
    @IBOutlet weak var negotiationPlusButton: NSButton!
    @IBOutlet weak var negotiationMinusButton: NSButton!
    @IBOutlet weak var diplomacyPlusButton: NSButton!
    @IBOutlet weak var diplomacyMinusButton: NSButton!
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    private var navigationScore = 5
    private var combatScore = 5
    private var negotiationScore = 5
    private var diplomacyScore = 0
    
    var gameState : GameState? = nil
    
    private let allowedPoints = 15
    
    private var remainingPoints : Int {
        self.allowedPoints - self.navigationScore - self.combatScore - self.negotiationScore - self.diplomacyScore
    }
    
    convenience init() {
        self.init(windowNibName: "NewGameWindowController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.refreshView()
    }
    
    private func refreshView() {
        self.navigationScoreLabel.stringValue = "\(self.navigationScore)"
        self.combatScoreLabel.stringValue = "\(self.combatScore)"
        self.negotiationScoreLabel.stringValue = "\(self.negotiationScore)"
        self.diplomacyScoreLabel.stringValue = "\(self.diplomacyScore)"
        self.pointsRemainingLabel.stringValue = "\(self.remainingPoints)"
        
        self.navigationMinusButton.isEnabled = self.navigationScore > 0
        self.combatMinusButton.isEnabled = self.combatScore > 0
        self.negotiationMinusButton.isEnabled = self.negotiationScore > 0
        self.diplomacyMinusButton.isEnabled = self.diplomacyScore > 0
        self.navigationPlusButton.isEnabled = self.remainingPoints > 0
        self.combatPlusButton.isEnabled = self.remainingPoints > 0
        self.negotiationPlusButton.isEnabled = self.remainingPoints > 0
        self.diplomacyPlusButton.isEnabled = self.remainingPoints > 0
        
        self.startButton.isEnabled = self.remainingPoints == 0
    }
    
    //MARK: - Actions
    
    @IBAction func scoreButtonPressed(_ sender: NSButton) {
        if sender === self.navigationPlusButton || sender === self.combatPlusButton || sender === self.negotiationPlusButton || sender === self.diplomacyPlusButton {
            if self.remainingPoints <= 0 {
                self.refreshView()
                return
            }
            if sender === self.navigationPlusButton {
                self.navigationScore += 1
            } else if sender === self.combatPlusButton {
                self.combatScore += 1
            } else if sender === self.negotiationPlusButton {
                self.negotiationScore += 1
            } else if sender === self.diplomacyPlusButton {
                self.diplomacyScore += 1
            }
            self.refreshView()
            return
        }
        
        if sender === self.navigationMinusButton && self.navigationScore > 0 {
            self.navigationScore -= 1
        } else if sender === self.combatMinusButton && self.combatScore > 0 {
            self.combatScore -= 1
        } else if sender === self.negotiationMinusButton && self.negotiationScore > 0 {
            self.negotiationScore -= 1
        } else if sender === self.diplomacyMinusButton && self.diplomacyScore > 0 {
            self.diplomacyScore -= 1
        }
        self.refreshView()
    }
    
    @IBAction func startButtonPressed(_ sender: NSButton) {
        let fieldName = self.nameTextField.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let playerName = fieldName.isEmpty ? "Incognito" : fieldName
        
        let pl = Player(name: playerName, navigation: self.navigationScore, combat: self.combatScore, negotiation: self.negotiationScore, diplomacy: self.diplomacyScore)
        self.gameState = GameState(player: pl, starSystems: 1000)
        self.window?.sheetParent?.endSheet(self.window!, returnCode: .OK)
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: .cancel)
    }
}
