//
//  StarSystemInfoViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/5/22.
//

import Cocoa

class StarSystemInfoViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var currentSystemLabel : NSTextField!
    @IBOutlet var nameLabel : NSTextField!
    @IBOutlet var coordinateLabel : NSTextField!
    @IBOutlet var stageLabel : NSTextField!
    @IBOutlet var economyLabel : NSTextField!
    @IBOutlet var populationLabel : NSTextField!
    @IBOutlet var dangerLabel : NSTextField!
    @IBOutlet var connectingSystemsHolderView : NSView!
    
    @IBOutlet var lastViewedMarketLabel : NSTextField!
    @IBOutlet var marketTableView : NSTableView!
    @IBOutlet weak var marketScrollView: NSScrollView!
    @IBOutlet weak var marketHolderView: NSView!
    
    var systemNumber : Int = 0 {
        didSet {
            self.refreshDisplay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshDisplay()
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: StarSystem.starSystemUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.starSystemUpdated(notification)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.marketScrollView.frame = NSRect(x: 0, y: 0, width: self.marketHolderView.frame.width, height: self.marketHolderView.frame.height - 40)
    }
    
    private func refreshDisplay() {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.systemNumber) else {
            return
        }
        self.checkForMarket()
        
        self.currentSystemLabel.isHidden = (self.gameState.player.location) != system.num_id
        self.marketHolderView.isHidden = system.market == nil
        self.lastViewedMarketLabel.isHidden = (self.gameState.player.location) == system.num_id
        self.nameLabel.stringValue = system.name
        self.coordinateLabel.stringValue = "\(system.position)"
        self.stageLabel.stringValue = "\(system.stage)"
        self.economyLabel.stringValue = "\(system.economy)"
        self.populationLabel.stringValue = "\(system.populationDescription)"
        self.dangerLabel.stringValue = "\(system.danger)"
        self.refreshConnectingSystems()
        self.marketTableView.reloadData()
        
        if system.market != nil {
            self.lastViewedMarketLabel.stringValue = String(format: "Last viewed %0.0f days ago", round(self.gameState.time - system.market!.timestamp))
        }
    }
    
    private func checkForMarket() {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.systemNumber) else {
            return
        }
        if self.systemNumber != self.gameState.player.location {
            return
        }
    
        if system.market == nil && system.economy != .none {
            system.market = Market.generateNewMarket(starSystem: system, time: self.gameState.time)
        }
        else if system.market?.needsRefresh == true {
            system.market?.recalculateMarketQuantities(starSystem: system, time: self.gameState.time)
        }
    }
    
    private func refreshConnectingSystems() {
        let subs = self.connectingSystemsHolderView.subviews
        subs.forEach() { $0.removeFromSuperview() }
        
        guard let system = self.gameState.galaxyMap.getSystemForId(self.systemNumber) else {
            return
        }
        
        let allStars = self.gameState!.player.allKnownStars
        
        var yOffset : CGFloat = self.connectingSystemsHolderView.bounds.size.height
        system.connectingSystems.forEach { ident in
            if !allStars.contains(ident) {
                return
            }
            let otherSystem = self.gameState.galaxyMap.getSystemForId(ident)
            let otherName = otherSystem?.name ?? "Error"
            let distance = otherSystem?.position.distance(system.position) ?? 0.0
            let text = "\(otherName) (\(String(format: "%.1f", distance)))"
            
            let attributes = [NSAttributedString.Key.font:NSFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor:NSColor.black]
            let nsText = text as NSString
            
            let boundingRect = nsText.boundingRect(with: NSSize(width: self.connectingSystemsHolderView.bounds.size.width, height: self.connectingSystemsHolderView.bounds.size.height), attributes: attributes)
            let height = fmin(boundingRect.size.height, 20)
            
            let label = NSTextField(labelWithString: text)
            label.maximumNumberOfLines = 0
            label.isEnabled = true
            label.frame = NSRect(x: 0, y: yOffset - height, width: self.connectingSystemsHolderView.bounds.size.width, height: height)
            label.tag = ident
            yOffset -= (height + 5)
            let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClickOnConnectingSystem(gestureRecognizer:)))
            label.addGestureRecognizer(clickGesture)
            
            self.connectingSystemsHolderView.addSubview(label)
            
        }

    }
    
    //MARK: - Notification
    
    private func starSystemUpdated(_ notification : Notification) {
        if (notification.object as? StarSystem)?.num_id == self.systemNumber {
            self.refreshDisplay()
        }
    }
                                     
    //MARK: - Actions
    @objc func handleClickOnConnectingSystem(gestureRecognizer: NSClickGestureRecognizer) {
        let systemIdent = gestureRecognizer.view?.tag ?? 0
        if (systemIdent > 0) {
            delegate?.starSystemSelected(sender: self, starIdent: systemIdent)
        }
    }
    
    //MARK: - NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let sys = self.gameState.galaxyMap.getSystemForId(self.systemNumber) else {
            return 0
        }
        if sys.economy == .none || sys.market == nil {
            return 0
        }
        return Commodity.allCases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let system = self.gameState.galaxyMap.getSystemForId(self.systemNumber) else {
            return nil
        }
        self.checkForMarket()
        
        let allComms = Commodity.allCases
        
        let comm = allComms[row]
        let price = system.market!.priceForCommodity(comm)
        
        let priceString = price == nil ? "-" : String(format: "%0.1f",price!)
        
        let result = self.marketTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("Column1"), owner: self) as? TwoLabelTableCellView
        
        result?.textField?.stringValue = "\(comm.shortDescription)"
        result?.rightSideTextField.stringValue = priceString
        
        return result
        
    }

    
}
