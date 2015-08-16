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

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    
    var defaultWindow           :   NSWindow!
    var statusbarController     :   statusBarCtrl!
    
    //  Key's to observe for the HotKeys
    var observableKeys_HotKey = [ LUPADefaults.lupa_HotkeyEnabled ]

    //  Connected to MainMenu.xib objects through the Interface Builder
    
    @IBOutlet weak var statusMenu: NSMenu!

    //  In order to work with the user defaults
    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()

    // Class attributes
    var programName : String    = ""


    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // NOTE: In order for the Icon disapear from the Dock and also disapear 
        //       from the CMD-ALT list you need to do the following: 
        //
        // Modify your info.plist file and add the following:
        //
        //      Application is agent (UIElement) -> YES
        //
        
        /// Prepare windows
        // Close the default window, in case you didn't delete it from MainMenu.xib :)
        defaultWindow = NSApplication.sharedApplication().windows.first
        if defaultWindow != nil {
            defaultWindow.close()
        }

        /// Program name
        // Store my program name.
        self.programName = programLongName()
        // Log
        // print("\(self.programName)")

        /// HotKey
        // Register default values to be used for the first app start
        // The first time I would access the propertys for the Hotkey
        // I would get nitl, false or 0, so instead of doing tests, 
        // I ship with some already predefined values for these keys.
        self.userDefaults.registerDefaults([
            LUPADefaults.lupa_HotkeyEnabled:true
            ])
        // Start observing changes in the user Defaults hotkey properties...
        self.loadKVO()

        /// Menubar (Phase 1)
        // Activo mi clase menubarController para controlar el statusBar
        self.statusbarController = statusBarCtrl(statusMenu)
        
        /// Menubar (Phase 2 = future, ToDo)
        // In the future I'll move to a Singleton...
        // print("lpStatusItem name: \(lpStatusItem.name)")
        
        // Change to background mode
        // self.setWindowMode(false)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        self.unloadKVO()
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: IBActions through First Responder
    /// --------------------------------------------------------------------------------
    
    //
    // Show the preferences window:
    // So when the user selects "Preferences" it will go through the First Responder
    // chain till it finds someone implementing this method. Notice that you don't
    // have to connect to this method itself, do it thorugh First Responder.
    // 
    // Connect MainMenu.xib->Program->Preferences with FirstResponder->"showPreferences:"
    //
    @IBAction func showPreferences(sender : AnyObject) {
        statusbarController.showPreferences()
    }
    
    //
    // Show the searc box view:
    //
    // Connect with FirstResponder->"showSearchBox:"
    //
    @IBAction func showSearchBox(sender : AnyObject) {
        statusbarController.showSearchBox()
    }
    
    //
    // Open the Preferences window
    //
    // Connect with FirstResponder->"showDefaultWindow:"
    //
    @IBAction func showDefaultWindow(sender: AnyObject) {
        defaultWindow.makeKeyAndOrderFront(nil)
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: KVO
    /// --------------------------------------------------------------------------------

    // Context (up=unsafe pointer)
    private var upLUPA_AppDelegate_KVOContext_HotKey = 0
    
    // Load and activate the Key Value Observing
    //
    func loadKVO () {
        self.onObserver()
    }
    
    // Activate the observer
    //
    func onObserver () {
        // Options
        //  I'm setting .Initial so a notification should be sent to the observer immediately, 
        //  before the observer registration method even returns. Nice trick to perform initial setup...
        //
        let options = NSKeyValueObservingOptions([.Initial, .New])
        
        for item in self.observableKeys_HotKey {
            // print("\(self.userDefaults).addObserver(\(self), item: \(item), options: \(options), context: &upLUPA_AppDelegate_KVOContext_HotKey)")
            self.userDefaults.addObserver(
                self,
                forKeyPath: item,
                options: options,
                context: &upLUPA_AppDelegate_KVOContext_HotKey)
            
        }
    }
    
    // Deactivate and unload the Key Value Observing
    //
    func unloadKVO () {
        self.offObserver()
    }
    
    // Deactivate the observer
    //
    func offObserver () {
        for item in self.observableKeys_HotKey {
            // print("\(self.userDefaults) removeObserver(\(self), forKeyPath: \(item), context: &upLUPA_AppDelegate_KVOContext_HotKey))")
            self.userDefaults.removeObserver(self, forKeyPath: item, context: &upLUPA_AppDelegate_KVOContext_HotKey)
        }
    }
    
    // Actions when observing a change...
    //
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        
        // Act on the appropiate context
        if context == &upLUPA_AppDelegate_KVOContext_HotKey {
            
            //	New guard statement to return early if there's no change.
            guard let change = change else {
                // print("No change, return")
                return
            }
            
            //  Identify the kind of change
            //
            if let rv = change[NSKeyValueChangeKindKey] as? UInt,
                kind = NSKeyValueChange(rawValue: rv) {
                    switch kind {
                    case .Setting:
                        if ( keyPath == LUPADefaults.lupa_HotkeyEnabled ) {
                            if let letNewValue : Bool = change[NSKeyValueChangeNewKey]?.boolValue {
                                let newValue = letNewValue
                                self.activateKotKey(newValue)
                            }
                        }
                    case .Insertion:
                        // print(".Insertion -> \(change[NSKeyValueChangeNewKey]) ")
                        break
                    case .Removal:
                        // print(".Removal -> \(change[NSKeyValueChangeOldKey]) ")
                        break
                    case .Replacement:
                        // print(".Replacement -> \(change[NSKeyValueChangeOldKey]) ")
                        break
                    }
                    // Debug purposes
                    //print("change[NSKeyValueChangeNewKey] -> \(change[NSKeyValueChangeNewKey]) ")
                    //print("change[NSKeyValueChangeOldKey] -> \(change[NSKeyValueChangeOldKey]) ")
                    //print("change[NSKeyValueChangeIndexesKey] -> \(change[NSKeyValueChangeIndexesKey]) ")
                    //print("change[NSKeyValueChangeNotificationIsPriorKey] -> \(change[NSKeyValueChangeNotificationIsPriorKey]) ")
            }
            
        } else {
            // Defaults...
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Hotkey actioning
    /// --------------------------------------------------------------------------------
    
    // Activate or deactivate the Shortcut HotKey
    //
    func activateKotKey (newValue: Bool) {
        if newValue == true {
            MASShortcutBinder.sharedBinder().bindShortcutWithDefaultsKey(LUPADefaults.lupa_Hotkey, toAction: {
                self.actionHotKey()
            })
        } else {
            MASShortcutBinder.sharedBinder().breakBindingWithDefaultsKey(LUPADefaults.lupa_Hotkey)
        }
    }

    // Action when HotKey is Pressed
    //
    func actionHotKey() {
        // Send a message to firstResponder
        NSApplication.sharedApplication().sendAction("showSearchBox:", to: nil, from: self)
    }
}

