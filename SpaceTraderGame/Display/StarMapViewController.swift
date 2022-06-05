//
//  StarMapViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

class StarMapViewController: NSViewController {
    
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
        }
    }
    var centerCoordinates = Coord()
    var galaxyMap = GalaxyMap()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.starMapView.zoomLevel = self.zoomLevel
        self.starMapView.centerCoordinates = self.centerCoordinates
        self.starMapView.galaxyMap = self.galaxyMap
        
        self.refreshInformationDisplay()
    }
    
    func refreshInformationDisplay() {
        self.coordinateLabel.stringValue = "\(self.centerCoordinates)"
        
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
        self.refreshInformationDisplay()
    }
    
    @IBAction func zoomOutButtonPressed(_ sender : NSButton) {
        self.zoomLevel -= 1
        self.refreshInformationDisplay()
    }
    
}
