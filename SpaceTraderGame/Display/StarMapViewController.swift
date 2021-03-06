//
//  StarMapViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

class StarMapViewController: GameViewPanelViewController, StarMapViewDelegate {
    
    @IBOutlet var zoomInButton : NSButton?
    @IBOutlet var zoomOutButton : NSButton?
    @IBOutlet var cancelButton : NSButton?
    @IBOutlet var coordinateLabel : NSTextField?
    @IBOutlet var starMapView : StarMapView?
    
    var zoomLevel = 0 {
        didSet {
            if zoomLevel > 3 {
                zoomLevel = 3
            }
            if zoomLevel < -3 {
                zoomLevel = -3
            }
            self.starMapView?.zoomLevel = zoomLevel
            self.refreshInformationDisplay()
        }
    }
    
    var centerCoordinates = Coord() {
        didSet {
            self.refreshInformationDisplay()
            self.starMapView?.centerCoordinates = self.centerCoordinates
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.starMapView?.zoomLevel = self.zoomLevel
        self.starMapView?.centerCoordinates = self.centerCoordinates
        self.starMapView?.gameState = self.gameState
        
        self.refreshInformationDisplay()
    }
    
    func refreshInformationDisplay() {
        self.coordinateLabel?.stringValue = "\(String(format: "%.1f", self.centerCoordinates.x)),\(String(format: "%.1f", self.centerCoordinates.y))"
        
        self.zoomInButton?.isEnabled = true
        self.zoomOutButton?.isEnabled = true
        if self.zoomLevel <= -3 {
            self.zoomOutButton?.isEnabled = false
        }
        else if self.zoomLevel >= 3 {
            self.zoomInButton?.isEnabled = false
        }
        
        self.cancelButton?.isHidden = self.delegate?.shouldDisplayCancelButton(sender: self) != true
        
    }
    
    func centerOnStarSystem(_ systemIdent : Int) {
        guard let system = self.gameState.galaxyMap.getSystemForId(systemIdent) else {
            return
        }
        
        self.centerCoordinates = system.position
    }
    
    //MARK: - Actions
    @IBAction func zoomInButtonPressed(_ sender : NSButton) {
        self.zoomLevel += 1
    }
    
    @IBAction func zoomOutButtonPressed(_ sender : NSButton) {
        self.zoomLevel -= 1
    }
    
    @IBAction func cancelButtonPressed(_ sender : NSButton) {
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    // MARK: - StarMapViewDelegate methods
    
    func mapClickedAtCoordinates(sender: StarMapView, coordinates: CGPoint) {
        guard let system = self.gameState.galaxyMap.closestSystemToCoordinates(coordinates) else {
            return
        }
        
        if !self.gameState.player.allKnownStars.contains(system.num_id) {
            return
        }
        
        if system.position.distance2D(coordinates) < 1 {
            delegate?.starSystemSelected(sender: self, starIdent: system.num_id)
        }
    }
    
    func mapDragged(sender: StarMapView, from: CGPoint, to: CGPoint) {
        self.centerCoordinates = Coord(x:self.centerCoordinates.x + from.x - to.x,
                                       y:self.centerCoordinates.y + from.y - to.y,
                                       z:0)
        
    }
    
}
