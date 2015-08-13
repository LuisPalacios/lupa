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
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var searchField: NSTextField!
    @IBOutlet weak var statusMenu: NSMenu!
    
    // ------------------------------------------------------------------
    // MARK: Attributes
    // ------------------------------------------------------------------
    
    /// Controllers
    /// Note I'm using Implicitly Unwrapped Optional(!) so no need to initialize them here
    ///
    var lupaDefaultsController  : LupaDefaults!      // Preferences -
    var statusbarController     : statusBarCtrl!
    
    
    // ------------------------------------------------------------------
    // MARK: Main 
    // ------------------------------------------------------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // Initialize the defaults preferences and window controller
        self.lupaDefaultsController = LupaDefaults(windowNibName: "LupaDefaults")
        
        // Activo mi clase menubarController para controlar el statusBar
        self.statusbarController = statusBarCtrl(statusMenu)

    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // Call default browser with full URL from the prefix + search_field
    //
    @IBAction func doSearch(sender: AnyObject) {

        // Read userDefaults (String) and convert into NSURL
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_URLPrefix) as? String {
            // print("lupa_URLPrefix: \(letTheString)")
            
            if !letTheString.isEmpty {
                if !searchField.stringValue.isEmpty {
                    let searchURLString : String = letTheString + searchField.stringValue
                    let myUrlString : String = searchURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    let theURL : NSURL? = NSURL (string: myUrlString)

                    // print("Searching: \(searchURLString)")
                    // Let's go rock and roll
                    NSWorkspace.sharedWorkspace().openURL(theURL!)
                } else {
                    // print ("Search string empty, ignore it...")
                }
            } else {
                // print ("URL Prefix is empty, call doDefaults...")
                doLupaDefaults(self)
            }
        } else {
            // print("Prefix is not an string object, ignore it....")
        }
    }

    // Open the preferences (Defaults) window
    //
    @IBAction func doLupaDefaults(sender: AnyObject) {
        if let window = self.lupaDefaultsController.window {
            window.makeKeyAndOrderFront(self)
            window.makeFirstResponder(self.lupaDefaultsController.window)
            window.center()
        }
    }
}

