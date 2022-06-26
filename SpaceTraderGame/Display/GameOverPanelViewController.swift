//
//  GameOverPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/26/22.
//

import Cocoa

class GameOverPanelViewController: GameViewPanelViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func canRemovePanel() -> Bool {
        return false
    }
}
