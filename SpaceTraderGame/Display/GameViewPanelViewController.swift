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
    func cancelButtonPressed(sender: GameViewPanelViewController)
    func shouldDisplayCancelButton(sender: GameViewPanelViewController) -> Bool
    func presentGameViewPanel(sender: GameViewPanelViewController, newPanel: GameViewPanelViewController)
}

class GameViewPanelViewController : NSViewController {
    
    weak var delegate : GameViewPanelDelegate?
    var gameState : GameState!
    
    func canRemovePanel() -> Bool {
        return true
    }
}
