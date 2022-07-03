//
//  EncounterPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/23/22.
//

import Cocoa

enum EncounterMenuActionType : Int, CustomStringConvertible {
    case fight
    case flee
    case dumpCargo
    case dumpCargoFlee
    case ignore
    case exit
    
    var description : String {
        switch self {
        case .fight: return "Fight"
        case .flee: return "Flee"
        case .dumpCargo: return "Dump Cargo"
        case .dumpCargoFlee: return "Dump Cargo and Flee"
        case .ignore: return "Ignore"
        case .exit: return "Exit Screen"
        }
    }
}

enum EncounterResolutionType : Int {
    case none
    case destroyed
    case enemyDestroyed
    case enemyFled
    case playerFled
    case peaceful
}

class EncounterPanelViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var actionTableView : NSTableView!
    @IBOutlet weak var otherShipLabel: NSTextField!
    @IBOutlet weak var otherShipWeaponLabel: NSTextField!
    @IBOutlet weak var otherShipHullLabel: NSTextField!
    @IBOutlet weak var otherShipShieldLabel: NSTextField!
    @IBOutlet weak var otherShipManeuverLabel: NSTextField!
    @IBOutlet weak var otherShipEscapeLabel: NSTextField!
    @IBOutlet weak var playerWeaponLabel: NSTextField!
    @IBOutlet weak var playerHullLabel: NSTextField!
    @IBOutlet weak var playerShieldLabel: NSTextField!
    @IBOutlet weak var playerManeuverLabel: NSTextField!
    @IBOutlet weak var playerEscapeLabel: NSTextField!
    @IBOutlet weak var encounterDetailView: NSView!
    @IBOutlet weak var summaryLabel: NSTextField!
    @IBOutlet weak var roundDescriptionLabel: NSTextField!
    
    var encounter : Encounter!
    
    private var initialPhase = true
    private var combatRound = 0
    private var combatRoundDescription = ""
    
    private var playerEscapeProgress : Double = 0
    private var enemyEscapeProgress : Double = 0
    private var resolution : EncounterResolutionType = .none
    
    private var actionList : [EncounterMenuActionType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.encounter.player?.ship.shieldValue = self.encounter.player?.ship.totalShieldStrength() ?? 0
        self.gameState.player.ship.shieldValue = self.gameState.player.ship.totalShieldStrength()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.refreshView()
    }
    
    override func canRemovePanel() -> Bool {
        return resolution != .none
    }
    
    func refreshView() {
        
        self.actionList.removeAll()
        
        let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location)
        let destinationStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.priorLocation)
        
        var canFlee = false
        var canFleeWithoutCargo = false
        if currentStar != nil && destinationStar != nil {
            let distance = currentStar!.position.distance(destinationStar!.position)
            canFlee = self.gameState.player.fuelToTravelDistance(distance: distance) <= self.gameState.player.ship.fuel
            
            canFleeWithoutCargo = self.gameState.player.ship.carryingDisposableCargo() && self.gameState.player.fuelToTravelTime(time: self.gameState.player.timeToJumpWithoutCommodities(distance: distance)) <= self.gameState.player.ship.fuel
        }
        
        if resolution != .none {
            self.encounterDetailView.isHidden = true
            self.summaryLabel.isHidden = false
            self.actionList.append(.exit)
            self.actionTableView.reloadData()
            self.summaryLabel.stringValue = self.getTextDescriptionForResolution()
            return
        }
        
        if self.initialPhase {
            self.actionList.append(.ignore)
        }
        if self.gameState.player.ship.carryingDisposableCargo() {
            if self.initialPhase {
                self.actionList.append(.dumpCargo)
            }
            if canFleeWithoutCargo {
                self.actionList.append(.dumpCargoFlee)
            }
        }
        if canFlee {
            self.actionList.append(.flee)
        }
        self.actionList.append(.fight)
        
        if self.initialPhase {
            self.encounterDetailView.isHidden = true
            self.summaryLabel.isHidden = false
            
            var descriptionString = ""
            if self.encounter.type == .pirate {
                descriptionString += "A ship is approaching. It demands you dump all your cargo."
            }
            else if self.encounter.type == .other {
                descriptionString += "A ship is moving to engage you. Its intentions are unknown."
            }
            let otherShipThreat = self.encounter.player?.ship.threatLevel() ?? 0
            let playerThreat = self.gameState.player.ship.threatLevel()
            if otherShipThreat < playerThreat - 2 {
                descriptionString += " The other ship appears much less capable than yours."
            } else if otherShipThreat < playerThreat {
                descriptionString += " The other ship appears less capable than yours."
            } else if otherShipThreat == playerThreat {
                descriptionString += " The other ship appears comparable to yours."
            } else if otherShipThreat < playerThreat + 3 {
                descriptionString += " The other ship appears more capable than yours."
            } else {
                descriptionString += " The other ship appears much more capable than yours."
            }
            self.summaryLabel.stringValue = descriptionString
            
        }
        else {
            self.encounterDetailView.isHidden = false
            self.summaryLabel.isHidden = true
            self.roundDescriptionLabel.stringValue = self.combatRoundDescription
            
            self.otherShipLabel.stringValue = "\(self.encounter.type)"
            self.otherShipWeaponLabel.stringValue = String(format: "%0.0f",self.encounter.player!.ship.totalWeaponStrength())
            let remainingOtherHull = self.encounter.player!.ship.hull - self.encounter.player!.ship.hullDamage
            self.otherShipHullLabel.stringValue = String(format: "%0.1f/%0.0f", remainingOtherHull,self.encounter.player!.ship.hull)
            self.otherShipShieldLabel.stringValue = String(format: "%0.1f/%0.0f", self.encounter.player!.ship.shieldValue, self.encounter.player!.ship.totalShieldStrength())
            self.otherShipManeuverLabel.stringValue = String(format: "%0.1f", self.encounter.player!.ship.engine*10/self.encounter.player!.ship.totalShipWeight())
            self.otherShipEscapeLabel.stringValue = String(format: "%0.0f%%", enemyEscapeProgress)
            self.playerWeaponLabel.stringValue = String(format: "%0.0f",self.gameState.player.ship.totalWeaponStrength())
            let remainingPlayerHull = self.gameState.player.ship.hull - self.gameState.player.ship.hullDamage
            self.playerHullLabel.stringValue = String(format: "%0.1f/%0.0f", remainingPlayerHull,self.gameState.player.ship.hull)
            self.playerShieldLabel.stringValue = String(format: "%0.1f/%0.0f", self.gameState.player.ship.shieldValue, self.gameState.player.ship.totalShieldStrength())
            self.playerManeuverLabel.stringValue = String(format: "%0.1f", self.gameState.player.ship.engine*10/self.gameState.player.ship.totalShipWeight())
            self.playerEscapeLabel.stringValue = String(format: "%0.0f%%", playerEscapeProgress)
        }
        
        self.actionTableView.reloadData()
    }
    
    private func dumpAllCargo(_ flee : Bool) {
        self.gameState.player.ship.dumpCargo()
        if self.encounter.type == .pirate && self.initialPhase {
            if flee {
                self.resolution = .playerFled
            }
            else {
                self.resolution = .peaceful
            }
        }
        else {
            self.performCombatWithPlayerFlee(flee, playerIgnore: !flee)
        }
    }
    
    private func tryIgnoring() {
        self.initialPhase = false
        performCombatWithPlayerFlee(false, playerIgnore: true)
    }
    
    private func resolveEncounterAndExit() {
        if self.resolution == .enemyDestroyed {
            self.gameState.player.combatExperience += Double(self.encounter.player!.ship.threatLevel()*10 + 1)
            self.gameState.player.money += self.encounter.bounty
            if self.encounter.player!.ship.threatLevel()*10 > self.gameState.player.reputation {
                let diff = self.encounter.player!.ship.threatLevel() - self.gameState.player.reputation/10
                self.gameState.player.reputation += diff
            }
            
        } else if self.resolution == .enemyFled {
            self.gameState.player.combatExperience += Double(self.encounter.player!.ship.threatLevel()*5 + 1)
        } else if self.resolution == .playerFled {
            self.gameState.player.combatExperience += Double(self.encounter.player!.ship.threatLevel())
            let res = self.gameState.player.performJump(from: self.gameState.player.location, to: self.gameState.player.priorLocation, galaxyMap: self.gameState.galaxyMap)
            if res.success {
                self.gameState.time += res.timeElapsed
            }
            self.gameState.player.reputation -= 1
        }
        
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    private func getTextDescriptionForResolution() -> String {
        switch self.resolution {
        case .destroyed:
            return "Your ship was destroyed."
        case .enemyDestroyed:
            var descrip = "You were victorious. The enemy ship was destroyed."
            if encounter.bounty > 0 {
                descrip += "\nYou earn a bounty of \(encounter.bounty) credits"
            }
            return descrip
        case .playerFled:
            return "You managed to escape. You jump back to system you came from."
        case .enemyFled:
            return "The enemy ship managed to escape."
        case .peaceful:
            return "The other ship moves away, apparently having gotten what it wanted."
        default:
            return ""
        }
    }
    
    //MARK: - Combat resolution
    
    private func performCombatWithPlayerFlee(_ flee : Bool, playerIgnore: Bool = false) {
        self.combatRound += 1
        self.combatRoundDescription = "Round \(self.combatRound)"
        self.initialPhase = false
        let enemyFlee = self.shouldEnemyFlee()
        if flee && enemyFlee {
            self.resolution = .playerFled
            self.refreshView()
            return
        }
        
        let playerFirst = playerIgnore ? false : playerGoesFirst()
        if playerFirst {
            playerCombatAction(flee)
            
            enemyCombatAction(enemyFlee)
        }
        else {
            enemyCombatAction(enemyFlee)
            
            playerCombatAction(flee)
        }
        if self.gameState.player.ship.isDestroyed {
            self.gameState.gameOver = true
            resolution = .destroyed
        }
        else if self.playerEscapeProgress >= 100 {
            resolution = .playerFled
        }
        else if self.encounter.player?.ship.isDestroyed == true {
            resolution = .enemyDestroyed
        }
        else if self.enemyEscapeProgress >= 100 {
            resolution = .enemyFled
        }
    }
    
    private func performAttack(attack: Player, defend: Player) {
        
        let man1 = attack.ship.engine/attack.ship.totalShipWeight()
        let man2 = defend.ship.engine/defend.ship.totalShipWeight()
        
        let manRatio = fmax(0.3,fmin(man1/man2,3))
        
        let comDiff = fmax(-30, fmin(Double(attack.combat - defend.combat),30))
        
        let percentHit = fmax(1,fmin(99,30 + 20*manRatio + comDiff))
        
        var totalDam : Double = 0
        attack.ship.equipment.filter{ $0.type == .weapon }.forEach { weap in
            let hit = Double.random(in: 0...100)
            if hit > percentHit {
                self.combatRoundDescription += "\nmisses"
                return
            }
            let dam = weap.strength * Double.random(in: 0...1)
            totalDam += dam
            self.combatRoundDescription += String(format: "\nhits for %0.1f damage", dam)
        }
        
        if totalDam < defend.ship.shieldValue {
            defend.ship.shieldValue -= totalDam
        }
        else {
            let hullDam = totalDam - defend.ship.shieldValue
            defend.ship.shieldValue = 0
            defend.ship.hullDamage += hullDam
        }

    }
    
    private func playerCombatAction(_ flee : Bool) {
        if self.gameState.player.ship.isDestroyed || self.enemyEscapeProgress >= 100 {
            return
        }
        self.combatRoundDescription += "\nPlayer Action"
        if flee {
            let escapeProgress = calculateFlee(player: self.gameState.player)
            self.combatRoundDescription += String(format:"\nFlee progress increases by %0.0f",escapeProgress)
            playerEscapeProgress += escapeProgress
        }
        else {
            self.playerEscapeProgress = 0
            performAttack(attack: self.gameState.player, defend: self.encounter.player!)
        }
    }
    
    private func enemyCombatAction(_ flee : Bool) {
        if self.encounter.player!.ship.isDestroyed || self.playerEscapeProgress >= 100 {
            return
        }
        self.combatRoundDescription += "\nEnemy Action"
        if flee {
            let escapeProgress = calculateFlee(player: self.encounter.player!)
            self.combatRoundDescription += String(format:"\nFlee progress increases by %0.0f",escapeProgress)
            enemyEscapeProgress += escapeProgress
        }
        else {
            self.enemyEscapeProgress = 0
            performAttack(attack: self.encounter.player!, defend: self.gameState.player)
        }
    }
    
    private func calculateFlee(player: Player) -> Double {
        
        return (player.ship.engine/player.ship.totalShipWeight() + (Double(player.navigation + player.combat)/200))*Double.random(in: 2...50)*player.ship.speedDamageAdjustment()
    }
    
    private func playerGoesFirst() -> Bool {
        let playerScore = Int(10*self.gameState.player.ship.engine/self.gameState.player.ship.totalShipWeight()) + self.gameState.player.combat + Int.random(in: 1...100)
        let enemyScore = Int(10*self.encounter.player!.ship.engine/self.encounter.player!.ship.totalShipWeight()) + self.encounter.player!.combat + Int.random(in: 1...100)
        return playerScore >= enemyScore
    }
    
    private func shouldEnemyFlee() -> Bool {
        if self.encounter.player!.ship.remainingHull < 10 && self.gameState.player.ship.remainingHull > 2*self.encounter.player!.ship.remainingHull {
            return true
        }
        else {
            return false
        }
    }
    
    //MARK: - NSTableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return actionList.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row < actionList.count {
            return "\(actionList[row])"
        }
        else {
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = self.actionTableView.selectedRow
        if row == -1 || row >= actionList.count {
            return
        }
        self.actionTableView.deselectAll(nil)
        
        let action = actionList[row]
        switch action {
        case .exit:
            resolveEncounterAndExit()
        case .dumpCargo:
            dumpAllCargo(false)
        case .dumpCargoFlee:
            dumpAllCargo(true)
        case .flee:
            performCombatWithPlayerFlee(true)
        case .fight:
            performCombatWithPlayerFlee(false)
        case .ignore:
            tryIgnoring()
        }
        
        refreshView()
    }
    
}
