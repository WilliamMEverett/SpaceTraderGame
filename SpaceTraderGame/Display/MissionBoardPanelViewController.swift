//
//  MissionBoardPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 7/30/22.
//

import Cocoa

class MissionBoardPanelViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var missionTableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshView()
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    private func refreshView() {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        
        currentStar.missionBoard.sort { miss1, miss2 in
            if miss1.minimumReputation < miss2.minimumReputation {
                return true
            }
            else {
                return miss1.moneyReward < miss2.moneyReward
            }
        }

        self.missionTableView.reloadData()
    }
    
    //MARK: - Table View
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return 0
        }
        return currentStar.missionBoard.count

    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return nil
        }
        let mission = currentStar.missionBoard[row]
        
        if (tableView.tableColumns[0] == tableColumn) {
            return mission.missionText
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            return "\(mission.type)"
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            return "\(mission.moneyReward) cr"
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            return "\(Int(floor(mission.expiration - self.gameState.time))) days"
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectionRow = self.missionTableView.selectedRow
        self.missionTableView.deselectAll(nil)
        
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        if selectionRow >= 0 && selectionRow < currentStar.missionBoard.count {
            
        }
        
    }
}
