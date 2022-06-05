//
//  StarMapViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

class StarMapViewController: GameViewPanelViewController, StarMapViewDelegate {
    
    @IBOutlet var zoomInButton : NSButton!
    @IBOutlet var zoomOutButton : NSButton!
    @IBOutlet var coordinateLabel : NSTextField!
    @IBOutlet var starMapView : StarMapView!
    
    var zoomLevel = 0 {
        didSet {
            if zoomLevel > 3 {
                zoomLevel = 3
            }
            if zoomLevel < -3 {
                zoomLevel = -3
            }
            self.starMapView.zoomLevel = zoomLevel
            self.refreshInformationDisplay()
        }
    }
    
    var centerCoordinates = Coord() {
        didSet {
            self.refreshInformationDisplay()
            self.starMapView.centerCoordinates = self.centerCoordinates
        }
    }
    
    var galaxyMap : GalaxyMap!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.starMapView.zoomLevel = self.zoomLevel
        self.starMapView.centerCoordinates = self.centerCoordinates
        self.starMapView.galaxyMap = self.galaxyMap
        
        self.refreshInformationDisplay()
    }
    
    func refreshInformationDisplay() {
        self.coordinateLabel.stringValue = "\(String(format: "%.1f", self.centerCoordinates.x)),\(String(format: "%.1f", self.centerCoordinates.y))"
        
        self.zoomInButton.isEnabled = true
        self.zoomOutButton.isEnabled = true
        if self.zoomLevel <= -3 {
            self.zoomOutButton.isEnabled = false
        }
        else if self.zoomLevel >= 3 {
            self.zoomInButton.isEnabled = false
        }
    }
    
    @IBAction func zoomInButtonPressed(_ sender : NSButton) {
        self.zoomLevel += 1
    }
    
    @IBAction func zoomOutButtonPressed(_ sender : NSButton) {
        self.zoomLevel -= 1
    }
    
    func centerOnStarSystem(_ systemIdent : Int) {
        guard let system = self.galaxyMap.getSystemForId(systemIdent) else {
            return
        }
        
        self.centerCoordinates = system.position
    }
    
    // MARK: - StarMapViewDelegate methods
    
    func mapClickedAtCoordinates(sender: StarMapView, coordinates: CGPoint) {
        guard let system = self.galaxyMap.closestSystemToCoordinates(coordinates) else {
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
