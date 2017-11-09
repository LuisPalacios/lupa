//
//  LPStatusItem.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 17/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa


/// Singleton LPStatusItem
///
/// Class that allows to install and activate a custom window in the status bar. I've 
/// prepared it as a singleton.
///
/// Reference it from SWIFT:
///  var reference : LPStatusItem = lpStatusItem
///  lpStatusItem.someMethod()
///
///
@objc class LPStatusItem: NSObject {
    
    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.

    var statusItemWindowController  : LPStatusItemWindowCtrl!
    var statusItem                  : NSStatusItem!
    var statusItemMenu              : NSMenu!
    var button                      : NSStatusBarButton!
    var windowConfig                : LPStatusItemWindowConfig!
    
    // Menu
    var statusMenu                  : NSMenu!

    // Vars that I need to be initialized
    var leftButtomInterval          : TimeInterval = 0.0
    

    //  Singleton accessible from IB and Obj-C if needed
    //
    class var sharedInstance: LPStatusItem {
        return lpStatusItem
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Dynamic attributes
    /// --------------------------------------------------------------------------------

    /// True if the window I control is open, otherwise false
    //
    var isStatusItemWindowVisible : Bool {
        get {
            if ( self.statusItemWindowController != nil ) {
                if ( self.statusItemWindowController.isWindowOpen == true ) {
                    return true
                }
            }
            return false
        }
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    override init() {
        super.init()
        // print("LPStatusItem - init()")
    }
    
    deinit {
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Present item in Status Bar
    /// --------------------------------------------------------------------------------
    
    /// Activate my status item and present it in the bar
    ///
    func activateStatusItemWithMenuImageWindow (_ statusMenu: NSMenu, itemImage : NSImage, winController: NSWindowController) {
        
        // Log
        //print("LPStatusItem - Activate my status item and present it in the bar")
        //print("    activateStatusItemWithMenuImageWindow (statusMenu : \(statusMenu), itemImage: \(itemImage), winController: \(winController)) ")
        
        // Store the Menu
        self.statusMenu = statusMenu
        
        /// Create Status Bar Item with an NSImage
        //
        self.createStatusBarItemWithImage(statusMenu, itemImage: itemImage)
        
        // Create the default configuration
        //
        self.windowConfig = LPStatusItemWindowConfig()
        
        /// Create Custom NSWindowController
        //
        var success: Bool = false
        do {
            try statusItemWindowController = LPStatusItemWindowCtrl (
                statusItem: self,                               //  self : This statusItem
                window: winController.window,                   //  Window
                windowConfig: self.windowConfig )               //  windowConfig : Window configuration object to use to prepare the window
            success = true
        } catch let error as skStatusItemWindowCtrlNotReady {
            print(error.description)
        } catch {
            print ("Undefined error")
        }
        
        // Show result
        if success {
            // print("activateStatusItemWithImage: you're all set!!!")
        } else {
            print("activateStatusItemWithImage: Something really bad hapenned !!!!!")
        }
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: StatusBar Item
    /// --------------------------------------------------------------------------------

    // Create Status Bar Item with an NSImage
    //
    func  createStatusBarItemWithImage (_ statusMenu: NSMenu, itemImage : NSImage) {
        
        // 1. Identify the icon image as a template
        itemImage.isTemplate = true
        
        // 2. Create an statusItem inside the status bar
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // 3. Get the NSStatusBarButton (*new* in 10.10) and prepare it
        self.button = self.statusItem.button

        // 4. Assign the custom icon image passed from AppDelegate
        self.button.image = itemImage
        
        // 5. Setup myself as actions target for Mouse events
        button.target = self;
        button.action = #selector(LPStatusItem.clickActions(_:))
        button.sendAction( on: NSEvent.EventTypeMask(rawValue: UInt64(Int(NSEvent.EventTypeMask.leftMouseDown.rawValue) |
            Int(NSEvent.EventTypeMask.rightMouseDown.rawValue) |
            Int(NSEvent.EventTypeMask.leftMouseUp.rawValue) |
            Int(NSEvent.EventTypeMask.rightMouseUp.rawValue))) )

        // 6. Store the Menu I should show when right-clicked
        self.statusItemMenu = statusMenu

    }
    
    //  StatusBar button handling
    //
    @objc func clickActions(_ sender : AnyObject) {
        
        if let letCurrentEvent = NSApp.currentEvent {
            let currentEvent = letCurrentEvent

            switch currentEvent.type {
            case NSEvent.EventType.leftMouseDown:
                // Show status item window
                leftButtomInterval = currentEvent.timestamp
                self.showStatusItemWindow()

            case NSEvent.EventType.leftMouseUp:
                // Dismiss status item window if user click was slow
                leftButtomInterval = currentEvent.timestamp - leftButtomInterval
                if ( leftButtomInterval > 0.5 ) {
                    self.dismissStatusItemWindow()
                }
                
            case NSEvent.EventType.rightMouseDown:
                // Ignore it...
                return
                
            case NSEvent.EventType.rightMouseUp:
                // Start the menu
                self.showStatusItemMenu()
                
            default:
                print ("clickActions: default, should never come here")
            }
        }
     }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Handling Status Item window visibility
    /// --------------------------------------------------------------------------------
    
    // Show the status item window
    //
    func showStatusItemWindow() {
        self.statusItemWindowController.showStatusItemWindow()
    }
    
    // Show the status item window
    //
    func updateFrameStatusItemWindow() {
        if ( self.statusItemWindowController != nil ) {
            self.statusItemWindowController.updateWindowFrame()
        }
    }
    
    // Dismiss the status item window
    //
    func dismissStatusItemWindow() {
        if ( self.statusItemWindowController != nil ) {
            self.statusItemWindowController.dismissStatusItemWindow()
        }
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Handling Status Item Menu visibility
    /// --------------------------------------------------------------------------------
    
    // Show the menu
    //
    func showStatusItemMenu() {
        self.statusMenu.popUp(positioning: nil, at: self.getPositioningPoint(), in: nil)
    }
    
    
    // Get the positioning point on the status bar
    //
    func getPositioningPoint() -> NSPoint {
        
        // ToDo: Just in case I'm assign dummy default...
        var point = NSMakePoint(100.0, 100.0)

        // Find Screen Coordinates of the NSStatusItem Frame
        let rectInWindow : NSRect = self.button.convert(self.button.bounds, to: nil)
        
        // Position the menu in the right place in screen
        if let letButtonWindow = self.button.window {
            let buttonWindow = letButtonWindow
            let screenRect : NSRect = buttonWindow.convertToScreen(rectInWindow)
            point = NSMakePoint(screenRect.origin.x, screenRect.origin.y - 3.0)
        }
        
        return point
    }

}

