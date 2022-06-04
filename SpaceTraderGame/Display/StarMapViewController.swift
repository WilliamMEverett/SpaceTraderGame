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
    
    var zoomLevel = 0
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
    }
    
}
