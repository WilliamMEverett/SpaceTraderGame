//
//  PlayerMissionViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 8/1/22.
//

import Cocoa

class PlayerMissionViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var currentJobsTableView: NSTableView!
    @IBOutlet weak var completedJobsTableView: NSTableView!
    @IBOutlet weak var cancelledJobsTableView: NSTableView!
    
    var gameState : GameState? = nil
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(GameState.timeUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.timeWasUpdated(notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Player.playerUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.playerWasUpdated(notification)
        }
        
    }
    
    func refreshView() {
        
        self.currentJobsTableView.reloadData()
        self.completedJobsTableView.reloadData()
        self.cancelledJobsTableView.reloadData()
    }
    
    private func timeWasUpdated(_ notification : Notification) {
        self.refreshView()
    }
    
    private func playerWasUpdated(_ notification : Notification) {
        self.refreshView()
    }
    
    //MARK: - Table View
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView === self.currentJobsTableView {
            return self.gameState?.player.missions.count ?? 0
        }
        else if tableView === self.cancelledJobsTableView {
            return self.gameState?.player.cancelledMissions.count ?? 0
        }
        else if tableView === self.completedJobsTableView {
            return self.gameState?.player.completedMissions.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        var mission : Mission? = nil
        if tableView === self.currentJobsTableView {
            mission = self.gameState?.player.missions[row]
        }
        else if tableView === self.cancelledJobsTableView {
            mission = self.gameState?.player.cancelledMissions[row]
        }
        else if tableView === self.completedJobsTableView {
            mission = self.gameState?.player.completedMissions[row]
        }
        if mission == nil {
            return nil
        }
        
        if (tableView.tableColumns[0] == tableColumn) {
            return mission!.missionText
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            return "\(mission!.moneyReward) cr"
        }
        else if (tableView.tableColumns[2] == tableColumn && tableView === self.currentJobsTableView) {
            let remainingTime = mission!.expiration - self.gameState!.time
            if remainingTime < 0 {
                return "Expired"
            }
            else if remainingTime > 2 {
                return "\(Int(floor(remainingTime))) days"
            }
            else {
                return String(format: "%0.1f days", remainingTime)
            }
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            let timeStamp = tableView === self.completedJobsTableView ? mission!.completedTime : mission!.expiration
            return GameState.timeStringDescription(timeStamp)
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            let timeStamp = mission!.expiration
            return GameState.timeStringDescription(timeStamp)
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if notification.object as? NSTableView === self.currentJobsTableView {
            let selectionRow = self.currentJobsTableView.selectedRow
            self.currentJobsTableView.deselectAll(nil)
            
        }
        
    }
    
    
}
