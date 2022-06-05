//
//  GameViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/5/22.
//

import Cocoa

class GameViewController: NSViewController, GameViewPanelDelegate {
    @IBOutlet var centralDisplayPanel : NSView!
    @IBOutlet var upperRightDisplayPanel : NSView!
    
    var starMapViewController : StarMapViewController!
    var starSystemInfoViewController : StarSystemInfoViewController!
    
    var galaxyMap : GalaxyMap!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        galaxyMap = GalaxyMap(1000)

        starMapViewController = StarMapViewController()
        starMapViewController.galaxyMap = galaxyMap
        starMapViewController.delegate = self
        
        self.addChild(starMapViewController)
        starMapViewController.view.frame = self.centralDisplayPanel.bounds
        self.centralDisplayPanel.addSubview(starMapViewController.view)
        
        starSystemInfoViewController = StarSystemInfoViewController()
        starSystemInfoViewController.galaxyMap = self.galaxyMap
        starSystemInfoViewController.delegate = self
        
        self.addChild(starSystemInfoViewController)
        starSystemInfoViewController.view.frame = self.upperRightDisplayPanel.bounds
        self.upperRightDisplayPanel.addSubview(starSystemInfoViewController.view)
        starSystemInfoViewController.systemNumber = 1
    }
    
    
    //MARK: - GameViewPanelDelegate
    
    func starSystemSelected(sender: GameViewPanelViewController, starIdent: Int) {
        self.starMapViewController.centerOnStarSystem(starIdent)
        self.starSystemInfoViewController.systemNumber = starIdent
    }
}
