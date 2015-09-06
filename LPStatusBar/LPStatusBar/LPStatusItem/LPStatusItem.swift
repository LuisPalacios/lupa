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
    var statusItemAction            : eMouseStatusItemAction!
    var windowConfig                : LPStatusItemWindowConfig!

    // Menu
    var statusMenu                  : NSMenu!
    var timerShowMenu               : NSTimer!          //!< Timer para mostrar el Menu right-click
    

    //  Singleton accessible from IB and Obj-C if needed
    //
    class var sharedInstance: LPStatusItem {
        return lpStatusItem
    }
    
    // Class attributes
    var name: String            = "LPStatusItem"

    
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
    func activateStatusItemWithImage (statusMenu: NSMenu, itemImage : NSImage, contentViewController: NSViewController) {
        
        // Log
        //print("LPStatusItem - Activate my status item and present it in the bar")
        //print("    activateStatusItemWithImage (imageName : \(imageName), contentViewController: \(contentViewController)) ")
        
        // Store the Menu 
        self.statusMenu = statusMenu
        
        /// Create Status Bar Item with an NSImage
        //
        self.createStatusBarItemWithImage(statusMenu, itemImage: itemImage)

        
        // Create the default configuration
        //
        self.windowConfig = LPStatusItemWindowConfig() // = [CCNStatusItemWindowConfiguration defaultConfiguration];

        
        /// Create Custom NSWindowController
        //
        //      self                    : This statusItem
        //      contentViewController   : The custom view controller passef by the AppDelegate
        //      windowConfig            : Window configuration object to use to prepare the window
        //
        var success: Bool = false
        do {
            try statusItemWindowController = LPStatusItemWindowCtrl (
                statusItem: self,
                contentViewController: contentViewController,
                windowConfig: self.windowConfig )
            success = true
        } catch let error as skStatusItemWindowCtrlNotReady {
            print(error.description)
        } catch {
            print ("Undefinded error")
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
    func  createStatusBarItemWithImage (statusMenu: NSMenu, itemImage : NSImage) {
        
        // 1. Identify the icon image as a template
        itemImage.template = true
        
        // 2. Create an statusItem inside the status bar
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

        // 3. Get the NSStatusBarButton (*new* in 10.10) and prepare it
        self.button = self.statusItem.button

        // 4. Assign the custom icon image passed from AppDelegate
        self.button.image = itemImage
        
        // 5. Setup myself as actions target
        button.target = self;
        button.action = "handleStatusItemActions:"
        button.sendActionOn( Int(NSEventMask.LeftMouseDownMask.rawValue) |
            Int(NSEventMask.RightMouseDownMask.rawValue) |
            Int(NSEventMask.LeftMouseUpMask.rawValue) |
            Int(NSEventMask.RightMouseUpMask.rawValue) )
        
        // 6. Save mouse press status
        self.statusItemAction = eMouseStatusItemAction.actionNone
        
        // 7. Store the Menu I should show when right-clicked
        self.statusItemMenu = statusMenu

    }
    
    //  StatusBar button handling
    //
    func handleStatusItemActions(sender : AnyObject) {
        
        // Identify which button has been pressed
        let buttonMask = NSEvent.pressedMouseButtons()
        // print("buttonMask: \(buttonMask)")
        let primaryDown : Bool = ((buttonMask & (1 << 0)) != 0);
        let secondaryDown : Bool = ((buttonMask & (1 << 1)) != 0);
        
        if (primaryDown) {
            
            // Log
            // print("actionPrimary")
            
            // Change my status
            self.statusItemAction = eMouseStatusItemAction.actionPrimary

            // Show / Dismiss the status item window
            if ( self.isStatusItemWindowVisible == true ) {
                self.dismissStatusItemWindow()
            } else {
                self.showStatusItemWindow()
            }

        } else if (secondaryDown) {
            
            // Log
            // print("actionSecondary")
            
            // Change my status
            self.statusItemAction = eMouseStatusItemAction.actionSecondary
            
            // Start the menu
            // NOTE: There is one issue with the right click. If I call the menu right away
            // then the status item stays highlighted after an option is choosen in the menu
            // so what I'm doing is leting it be called through a timer, after I exit this
            // function
            startTimerMenu()
            
        } else {
            
            // Log
            // print("actionNone")
            
            // Change my status
            self.statusItemAction = eMouseStatusItemAction.actionNone
        }
        
        // Some logging
        // print("handleStatusItemActions, buttonMask: \(buttonMask). primaryDown: \(primaryDown). secondaryDown: \(secondaryDown). statusItemAction: \(self.statusItemAction)")
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Handling Status Item window visibility
    /// --------------------------------------------------------------------------------
    
    // Show the status item window
    //
    func showStatusItemWindow() {
        self.statusItemWindowController.showStatusItemWindow()
    }
    
    // Dismiss the status item window
    //
    func dismissStatusItemWindow() {
        self.statusItemWindowController.dismissStatusItemWindow()
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Timer to show the Menu
    /// --------------------------------------------------------------------------------
    
    // Start a timer to show the Menu
    //
    func startTimerMenu() {
        
        timerShowMenu = NSTimer.scheduledTimerWithTimeInterval(0.0,
            target: self,
            selector: Selector("actionTimerMenu"),
            userInfo: nil,
            repeats: false)
        
    }
    
    // Stop the timer (not used, but comes with my template :-))
    //
    func stopTimerMenu() {
        if ( timerShowMenu != nil ) {
            if (  timerShowMenu.valid ) {
                timerShowMenu.invalidate()
            }
            timerShowMenu = nil
        }
    }
    
    // Action to execute when the timer finishes
    //
    func actionTimerMenu() {
        
        // Start the menu
        // print("Launching the menu")
        
        // Find out the Screen Coordinates of the NSStatusItem Frame and generate
        // a right-click MENU.
        let rectInWindow : NSRect = self.button.convertRect(self.button.bounds, toView: nil)
        
        if let letButtonWindow = self.button.window {
            
            let buttonWindow = letButtonWindow
            let screenRect : NSRect = buttonWindow.convertRectToScreen(rectInWindow)
            let point : NSPoint = NSMakePoint(screenRect.origin.x, screenRect.origin.y - 3.0)
            self.statusMenu.popUpMenuPositioningItem(nil, atLocation: point, inView: nil)
        }
    }

}

