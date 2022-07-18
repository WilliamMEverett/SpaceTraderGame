//
//  ViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa
import UniformTypeIdentifiers

class MainViewController: NSViewController {
    
    var gameViewController : GameViewController?
    var newGameWindowController : NewGameWindowController?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if self.gameViewController == nil {
            self.showNewGameDialog()
        }
    }
    
    private func startGameWithGameState(_ gameState : GameState) {
        
        self.gameViewController?.view.removeFromSuperview()
        self.gameViewController?.removeFromParent()
        
        self.gameViewController = GameViewController()
        self.gameViewController!.gameState = gameState
        
        self.addChild(self.gameViewController!)
        self.gameViewController!.view.frame = self.view.bounds
        self.view.addSubview(gameViewController!.view)
    }
    
    private func showNewGameDialog() {
        self.newGameWindowController = NewGameWindowController()
        weak var weakSelf = self
        self.view.window?.beginSheet(newGameWindowController!.window!, completionHandler: { response in
            if response == .OK {
                weakSelf?.startGameWithGameState(weakSelf!.newGameWindowController!.gameState!)
            }
            weakSelf?.newGameWindowController = nil
        })
    }
    
    private func showSaveGameDialog() {
        if self.gameViewController == nil || self.gameViewController?.gameState.gameOver == true || self.gameViewController?.gameState.player.inStation == false {
            return
        }
        weak var weakSelf = self
        
        let validatedName = self.gameViewController!.gameState.player.name.filter { c in
            !c.unicodeScalars.contains { !CharacterSet.alphanumerics.contains($0) }
        }
        let fileName = String(format: "%@_%0.1f", validatedName, self.gameViewController!.gameState.time).replacingOccurrences(of: ".", with: "_")
        
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = fileName
        savePanel.title = "Save Game"
        savePanel.showsHiddenFiles = false
        savePanel.allowsOtherFileTypes = false
        
        savePanel.allowedContentTypes = [UTType("com.shinybuttonsoftware.spacetrader")!]
        
        let currentGameState = self.gameViewController!.gameState!
        
        savePanel.beginSheetModal(for: self.view.window!) { response in
            if response == .OK && savePanel.url != nil {
                weakSelf?.saveGame(game: currentGameState, location: savePanel.url!)
            }
        }
    }
    
    private func saveGame(game : GameState, location : URL) {
        
        guard let data = try? JSONEncoder().encode(game) else {
            print("Failed to encode game state")
            return
        }
        
        if FileManager.default.createFile(atPath: location.path, contents: data, attributes: [FileAttributeKey.type:"com.shinybuttonsoftware.spacetrader"]) {
            game.saved = true
        }
        else {
            print("Failed to save game")
        }
        
        
    }
    
    //MARK: - Actions
    
    @IBAction func newMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil {
            return
        }
        
        if self.gameViewController?.gameState.gameOver == false && self.gameViewController?.gameState.saved == false {
            let al = NSAlert()
            al.alertStyle = .informational
            al.messageText = "Game in Progress"
            al.informativeText = "You have an unsaved game in progress. Continuing will end this game."
            al.addButton(withTitle: "OK")
            al.addButton(withTitle: "Cancel")
            weak var weakSelf = self
            al.beginSheetModal(for: self.view.window!) { response in
                if response == .alertFirstButtonReturn {
                    weakSelf?.showNewGameDialog()
                }
            }
        }
        else {
            self.showNewGameDialog()
        }
    }
    
    @IBAction func saveMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil {
            return
        }
        self.showSaveGameDialog()
    }
    
    @IBAction func loadMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil {
            return
        }
    }

}

