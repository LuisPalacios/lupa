//
//  AppDelegate.swift
//  lupa
//
//  Created by Luis Palacios on 11/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

// ErroType's
//
enum skControllerNotReady: ErrorType {
    case cannotActivate
    case cannotCreate
    case cannotAccessIconImage
}
extension skControllerNotReady: CustomStringConvertible {
    var description: String {
        switch self {
        case cannotActivate: return "Attention! can't activate the custom NSViewController"
        case cannotCreate: return "Attention! can't create the custom NSViewController"
        case cannotAccessIconImage : return "Attention! can't access the Icon Image"
        }
    }
}

// Main app entry point
//
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!)
    //  they are optionals and no need to initialize them here, will do later.

    var searchViewCtrl          : LupaSearchViewCtrl!   // My View for the status bar
    var searchWinCtrl           : LupaSearchWinCtrl!    // My Window for the status bar
    var lupaDefaultsController  : LupaDefaults!         // Preferences Window
    var defaultWindow           : NSWindow!             // Find out the main window (to hide it)

    //  Key's to observe for the HotKeys
    var observableKeys_HotKey = [ LUPADefaults.lupa_HotkeyEnabled ]

    //  Connected to MainMenu.xib objects through Interface Builder
    @IBOutlet weak var statusMenu: NSMenu!

    //  In order to work with the user defaults, stored under:
    //  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
    //  $ defaults read parchis.org.XX.plist
    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()

    // To prepare the program name with GIT numbers
    var programName : String    = ""


    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // NOTE: In order for the Icon disapear from the Dock and also disapear 
        //       from the CMD-ALT list I also modified the Info.plist and added:
        //
        //      Application is agent (UIElement) -> YES
        //

        /// Prepare windows
        // I deleted the default main window from MainMenu.xib but just in 
        // case double check and hide it.
        defaultWindow = NSApplication.sharedApplication().windows.first
        if defaultWindow != nil {
            defaultWindow.close()
        }

        /// Program name
        // Store my program name.
        self.programName = programLongName()

        /// HotKey
        // Register default values to be used when app start for the first time
        // I ship with some already predefined values for some keys.
        self.userDefaults.registerDefaults( [ LUPADefaults.lupa_HotkeyEnabled:true ] )

        // Start observing changes in the user Defaults hotkey properties...
        self.loadKVO()

        // Initialize the defaults Preferences Window
        self.lupaDefaultsController = LupaDefaults(windowNibName: "LupaDefaults")
        
        /// Create my custom View Controller
        //  Based on LPStatusItem framework singleton
        //
        var success: Bool = false
        do {
            try createCustomViewController()
            do {
                /// Activate the status bar and make all connections
                ///
                try activateStatusBarWithWinController()
                success = true
            } catch let error as skControllerNotReady {
                print(error.description)
            } catch {
                print ("Undefinded error")
            }
        } catch let error as skControllerNotReady {
            print(error.description)
        } catch {
            print ("Undefinded error")
        }
        
        // Show result
        if success {
            // print("AppDelegate: Everything WENT WELL!!!")
        } else {
            print("AppDelegate: Something really bad hapenned !!!!")
        }
    }

    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Deactivate the KVO - Key Value Observing
        self.unloadKVO()
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: IBActions through First Responder
    /// --------------------------------------------------------------------------------
    
    //
    // Show the preferences window:
    // When the user selects "Preferences" it will go through the First Responder
    // chain till it finds someone implementing this method. 
    // I just use it thorugh First Responder.
    // 
    // Connect MainMenu.xib->Program->Preferences with FirstResponder->"showPreferences:"
    //
    @IBAction func showPreferences(sender : AnyObject) {

        // Open the preferences (Defaults) window
        //
        if let window = self.lupaDefaultsController.window {
            NSApplication.sharedApplication().activateIgnoringOtherApps(true)
            window.makeKeyAndOrderFront(self)
            window.center()
        }
        
    }
    
    //
    // Show the searc box view:
    //
    // Connect with FirstResponder->"showSearchBox:"
    //
    @IBAction func showSearchBox(sender : AnyObject) {
        
        // Ask the LPStatusItem to manifest
        lpStatusItem.showStatusItemWindow()
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: Main custom view controller and status bar activation
    /// --------------------------------------------------------------------------------
    
    // Create my custom View Controller which will be shown under
    // the status bar.
    //
    func createCustomViewController () throws {

        /// CREATE LupaSearchViewCtrl   !!!
        ///
        //
        // Prepare the name of the NIB (from the name of the class)
        let searchViewNibName = NSStringFromClass(LupaSearchViewCtrl).componentsSeparatedByString(".").last!
        // Create custom View Controller
        if let letSearchViewCtrl = LupaSearchViewCtrl(nibName: searchViewNibName, bundle: nil) {
            searchViewCtrl = letSearchViewCtrl
        } else {
            throw skControllerNotReady.cannotCreate
        }
        
        
        /// CREATE LupaSearchWinCtrl   !!!
        //
        // Prepare the name of the NIB (from the name of the class) and create custom Win Controller
        let searchWinNibName = NSStringFromClass(LupaSearchWinCtrl).componentsSeparatedByString(".").last!
        Swift.print("searchWinNibName: \(searchWinNibName)")
        searchWinCtrl = LupaSearchWinCtrl(windowNibName: searchWinNibName)
        Swift.print("searchWinCtrl: \(self.searchWinCtrl)")

    }
    
    // Activate status bar and make connections
    // ((DEPRECATED)
    func activateStatusBarWithViewController () throws {
        //
        // Activate my (singleton) "lpStatusItem" (Status Bar Item) passing:
        //
        //      the custom view controller
        //      the custom icon
        //
        if ( searchViewCtrl != nil ) {
            
            if let letItemImage = NSImage(named: "LupaOn_18x18") {
                let itemImage = letItemImage
                
                Swift.print("searchViewCtrl.view (ORIGINAL): \(searchViewCtrl.view)")
                Swift.print("searchViewCtrl.view.constraints (ORIGINAL): \(searchViewCtrl.view.constraints)")

                searchViewCtrl.view.backgroundColor = NSColor.greenColor()
                
                lpStatusItem.activateStatusItemWithImage(self.statusMenu, itemImage: itemImage, contentViewController: searchViewCtrl)
                
            } else {
                throw skControllerNotReady.cannotAccessIconImage
            }
            
        } else {
            throw skControllerNotReady.cannotActivate
        }
    }

    // Activate status bar and make connections
    //
    func activateStatusBarWithWinController () throws {
    
        //
        // Activate my (singleton) "lpStatusItem" (Status Bar Item) passing:
        //
        //      the custom view controller
        //      the custom icon
        //
        if ( searchWinCtrl != nil ) {
            
            if let letItemImage = NSImage(named: "LupaOn_18x18") {
                let itemImage = letItemImage
                
                //searchViewCtrl.view.backgroundColor = NSColor.greenColor()
                Swift.print("searchWinCtrl.window: \(self.searchWinCtrl.window)")

                lpStatusItem.activateStatusItemWithMenuImageWindow(self.statusMenu, itemImage: itemImage, winController: searchWinCtrl)
                
            } else {
                throw skControllerNotReady.cannotAccessIconImage
            }
            
        } else {
            throw skControllerNotReady.cannotActivate
        }

    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: KVO - Key Value Observing activation, de-activation and action
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
    
    // Actions when a change comes...
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

    // Action when the HotKey is Pressed
    //
    func actionHotKey() {
        // Send a message to firstResponder
        NSApplication.sharedApplication().sendAction("showSearchBox:", to: nil, from: self)
    }
}

