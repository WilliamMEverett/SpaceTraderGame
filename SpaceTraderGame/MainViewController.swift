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
    var savePanel : NSSavePanel?
    var loadPanel : NSOpenPanel?
    var jobsWindow : NSWindow?

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
        self.jobsWindow?.close()
        self.jobsWindow = nil
        
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
        
        self.savePanel = NSSavePanel()
        self.savePanel!.nameFieldStringValue = fileName
        self.savePanel!.title = "Save Game"
        self.savePanel!.showsHiddenFiles = false
        self.savePanel!.allowsOtherFileTypes = false
        
        self.savePanel!.allowedContentTypes = [UTType("com.shinybuttonsoftware.spacetrader")!]
        
        let currentGameState = self.gameViewController!.gameState!
        
        self.savePanel!.beginSheetModal(for: self.view.window!) { response in
            if response == .OK && weakSelf?.savePanel?.url != nil {
                weakSelf?.saveGame(game: currentGameState, location: weakSelf!.savePanel!.url!)
            }
            weakSelf?.savePanel = nil
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
    
    private func showLoadGameDialog() {

        weak var weakSelf = self
        
        self.loadPanel = NSOpenPanel()
        self.loadPanel!.title = "Load Game"
        self.loadPanel!.showsHiddenFiles = false
        self.loadPanel!.allowsOtherFileTypes = false
        
        self.loadPanel!.allowedContentTypes = [UTType("com.shinybuttonsoftware.spacetrader")!]
        
        self.loadPanel!.beginSheetModal(for: self.view.window!) { response in
            if response == .OK && weakSelf?.loadPanel?.url != nil {
                weakSelf?.loadGame(location: weakSelf!.loadPanel!.url!)
            }
            weakSelf?.loadPanel = nil
        }
    }
    
    private func loadGame(location : URL) {
        guard let data = FileManager.default.contents(atPath: location.path) else {
            print("Invalid file at \(location)")
            return
        }
        guard let newGameState = try? JSONDecoder().decode(GameState.self, from: data) else {
            print("Invalid json structure in file at \(location)")
            return
        }
        
        newGameState.saved = true
        
        self.startGameWithGameState(newGameState)
        
    }
    
    private func showUnsavedConfirmation(_ completion: @escaping ()->Void) {
        let al = NSAlert()
        al.alertStyle = .informational
        al.messageText = "Game in Progress"
        al.informativeText = "You have an unsaved game in progress. Continuing will end this game."
        al.addButton(withTitle: "OK")
        al.addButton(withTitle: "Cancel")
        al.beginSheetModal(for: self.view.window!) { response in
            if response == .alertFirstButtonReturn {
                completion()
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func newMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil || self.savePanel != nil || self.loadPanel != nil {
            return
        }
        
        weak var weakSelf = self
        if self.gameViewController?.gameState.gameOver == false && self.gameViewController?.gameState.saved == false {
            self.showUnsavedConfirmation {
                weakSelf?.showNewGameDialog()
            }
        }
        else {
            self.showNewGameDialog()
        }
    }
    
    @IBAction func saveMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil || self.savePanel != nil || self.loadPanel != nil {
            return
        }
        self.showSaveGameDialog()
    }
    
    @IBAction func loadMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil || self.savePanel != nil || self.loadPanel != nil {
            return
        }
        
        weak var weakSelf = self
        if self.gameViewController?.gameState.gameOver == false && self.gameViewController?.gameState.saved == false {
            self.showUnsavedConfirmation {
                weakSelf?.showLoadGameDialog()
            }
        }
        else {
            self.showLoadGameDialog()
        }
    }
    
    @IBAction func jobsMenuItem(_ sender : AnyObject?) {
        if self.newGameWindowController != nil || self.savePanel != nil || self.loadPanel != nil {
            return
        }
        
        if self.gameViewController?.gameState == nil {
            return
        }
        
        if self.jobsWindow != nil {
            (self.jobsWindow!.contentViewController as? PlayerMissionViewController)?.gameState = self.gameViewController?.gameState
            
            self.jobsWindow?.makeKeyAndOrderFront(sender)
            (self.jobsWindow!.contentViewController as? PlayerMissionViewController)?.refreshView()
        }
        else {
            let newJobsController = PlayerMissionViewController()
            newJobsController.gameState = self.gameViewController?.gameState
            self.jobsWindow = NSWindow(contentViewController: newJobsController)
            self.jobsWindow?.makeKeyAndOrderFront(sender)
        }
    }

}

