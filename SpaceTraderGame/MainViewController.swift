//
//  ViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

class MainViewController: NSViewController {
    
    var starMapViewController : StarMapViewController!
    var galaxyMap : GalaxyMap!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        galaxyMap = GalaxyMap()
        galaxyMap.generateSystems(1000)

        starMapViewController = StarMapViewController()
        starMapViewController.galaxyMap = galaxyMap
        
        self.addChild(starMapViewController)
        starMapViewController.view.frame = self.view.bounds
        self.view.addSubview(starMapViewController.view)
    }

}

