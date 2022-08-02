//
//  AppDelegate.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func getMainViewController() -> MainViewController? {
        let mainWindow = NSApplication.shared.windows.first(where: {
            $0.windowController?.contentViewController is MainViewController
        })
        return mainWindow?.windowController?.contentViewController as? MainViewController
    }

    //MARK: - Actions
    
    @IBAction func newMenuItem(_ sender : AnyObject?) {
        self.getMainViewController()?.newMenuItem(sender)
    }
    
    @IBAction func saveMenuItem(_ sender : AnyObject?) {
        self.getMainViewController()?.saveMenuItem(sender)
    }
    
    @IBAction func loadMenuItem(_ sender : AnyObject?) {
        self.getMainViewController()?.loadMenuItem(sender)
    }
    
    @IBAction func jobsMenuItem(_ sender : AnyObject?) {
        self.getMainViewController()?.jobsMenuItem(sender)
    }
}

