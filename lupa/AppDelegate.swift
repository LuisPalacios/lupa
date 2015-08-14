//
//  AppDelegate.swift
//  lupa
//
//  Created by Luis Palacios on 11/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // ------------------------------------------------------------------
    // MARK: IBOutlets
    // ------------------------------------------------------------------
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    // ------------------------------------------------------------------
    // MARK: Attributes
    // ------------------------------------------------------------------
    
    /// Controllers
    /// Note I'm using Implicitly Unwrapped Optional(!) so no need to initialize them here
    ///
    var defaultWindow           :   NSWindow!
    var statusbarController     :   statusBarCtrl!
    
    // --------------------------------------------------------------------------------
    // MARK: IBActions through First Responder
    
    ///
    /// Show the preferences window: Program->Preferences or just CMD+","
    ///
    /// Connect MainMenu.xib->Program->Preferences w/ FirstResponder->"showPreferences:"
    /// so when the user selects "Preferences" it will go through the First Responder
    /// chain till it finds someone implementing this method. Notice that you don't
    /// have to connect to this method itself, do it thorugh First Responder.
    //
    @IBAction func showPreferences(sender : AnyObject) {
        statusbarController.showPreferences()
    }
    
    
    ///
    /// Show the searc box view 
    ///
    /// Connect with FirstResponder->"showSearchBox:"
    //
    @IBAction func showSearchBox(sender : AnyObject) {
        statusbarController.showSearchBox()
    }
    
    @IBAction func showDefaultWindow(sender: AnyObject) {
        defaultWindow.makeKeyAndOrderFront(nil)
    }

    
    // ------------------------------------------------------------------
    // MARK: Main 
    // ------------------------------------------------------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // Close the default window
        defaultWindow = NSApplication.sharedApplication().windows.first
        defaultWindow.close()

        // Activo mi clase menubarController para controlar el statusBar
        self.statusbarController = statusBarCtrl(statusMenu)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
}

