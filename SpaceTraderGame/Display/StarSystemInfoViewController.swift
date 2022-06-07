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
    
    var gameState : GameState? = nil
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
        guard let system = self.gameState?.galaxyMap.getSystemForId(self.systemNumber) else {
            return
        }
        self.currentSystemLabel.isHidden = (self.gameState?.player.location ?? 0) != system.num_id
        self.nameLabel.stringValue = system.name
        self.coordinateLabel.stringValue = "\(system.position)"
        self.stageLabel.stringValue = "\(system.stage)"
        self.economyLabel.stringValue = "\(system.economy)"
        self.populationLabel.stringValue = "\(system.populationDescription)"
        self.dangerLabel.stringValue = "\(system.danger)"
        self.refreshConnectingSystems()
    }
    
    private func refreshConnectingSystems() {
        let subs = self.connectingSystemsHolderView.subviews
        subs.forEach() { $0.removeFromSuperview() }
        
        guard let system = self.gameState?.galaxyMap.getSystemForId(self.systemNumber) else {
            return
        }
        
        let allStars = self.gameState!.player.allKnownStars
        
        var yOffset : CGFloat = self.connectingSystemsHolderView.bounds.size.height
        system.connectingSystems.forEach { ident in
            if !allStars.contains(ident) {
                return
            }
            let otherSystem = self.gameState?.galaxyMap.getSystemForId(ident)
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
                                     
    //MARK: - Actions
    @objc func handleClickOnConnectingSystem(gestureRecognizer: NSClickGestureRecognizer) {
        let systemIdent = gestureRecognizer.view?.tag ?? 0
        if (systemIdent > 0) {
            delegate?.starSystemSelected(sender: self, starIdent: systemIdent)
        }
    }
    
}
