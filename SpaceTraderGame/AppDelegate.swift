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

    //MARK: - Actions
    
    @IBAction func newMenuItem(_ sender : AnyObject?) {
        (NSApplication.shared.mainWindow?.windowController?.contentViewController as? MainViewController)?.newMenuItem(sender)
    }
    
    @IBAction func saveMenuItem(_ sender : AnyObject?) {
        (NSApplication.shared.mainWindow?.windowController?.contentViewController as? MainViewController)?.saveMenuItem(sender)
    }
    
    @IBAction func loadMenuItem(_ sender : AnyObject?) {
        (NSApplication.shared.mainWindow?.windowController?.contentViewController as? MainViewController)?.loadMenuItem(sender)
    }
    
    @IBAction func jobsMenuItem(_ sender : AnyObject?) {
        (NSApplication.shared.mainWindow?.windowController?.contentViewController as? MainViewController)?.jobsMenuItem(sender)
    }
}

