//
//  StarSystemInfoViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/5/22.
//

import Cocoa

class StarSystemInfoViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var identifierLabel : NSTextField!
    @IBOutlet var nameLabel : NSTextField!
    @IBOutlet var coordinateLabel : NSTextField!
    @IBOutlet var stageLabel : NSTextField!
    @IBOutlet var economyLabel : NSTextField!
    @IBOutlet var populationLabel : NSTextField!
    @IBOutlet var dangerLabel : NSTextField!
    @IBOutlet var connectingSystemsTableView : NSTableView!
    
    var galaxyMap : GalaxyMap? = nil
    var systemNumber : Int = 0 {
        didSet {
            self.refreshDisplay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshDisplay()
    }
    
    private func refreshDisplay() {
        guard let system = galaxyMap?.getSystemForId(self.systemNumber) else {
            return
        }
        self.identifierLabel.stringValue = "\(system.num_id)"
        self.nameLabel.stringValue = system.name
        self.coordinateLabel.stringValue = "\(system.position)"
        self.stageLabel.stringValue = "\(system.stage)"
        self.economyLabel.stringValue = "\(system.economy)"
        self.populationLabel.stringValue = "\(system.populationDescription)"
        self.dangerLabel.stringValue = "\(system.danger)"
        
        self.connectingSystemsTableView.reloadData()
        
    }
    
    //MARK: - TableView methods
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let system = galaxyMap?.getSystemForId(self.systemNumber) else {
            return 0
        }
        return system.connectingSystems.count
        
    }
    
    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
        guard let system = galaxyMap?.getSystemForId(self.systemNumber) else {
            return nil
        }
        if row < system.connectingSystems.count {
            let ident = system.connectingSystems[row]
            let otherSystem = galaxyMap?.getSystemForId(ident)
            let otherName = otherSystem?.name ?? "Error"
            let distance = otherSystem?.position.distance(system.position) ?? 0.0
            let cell = NSCell(textCell: "\(otherName) (\(String(format: "%.1f", distance)))")
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
    
}
