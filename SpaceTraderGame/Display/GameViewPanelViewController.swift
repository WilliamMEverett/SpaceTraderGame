//
//  GameViewPanelDelegate.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/5/22.
//

import Foundation
import AppKit

protocol GameViewPanelDelegate : AnyObject {
    func starSystemSelected(sender: GameViewPanelViewController, starIdent: Int)
}

class GameViewPanelViewController : NSViewController {
    
    weak var delegate : GameViewPanelDelegate?
}
