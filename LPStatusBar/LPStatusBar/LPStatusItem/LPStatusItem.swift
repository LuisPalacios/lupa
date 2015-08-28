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
/// Global (Singleton) variable of my Swift LPStatusItem. This just calls
/// my default init and is threat safedue to all global variables are dispatch_once
/// by default in Swift.
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
            print("statusItemWindowController: WENT WELL!!!")
        } else {
            print("statusItemWindowController: VAYA CAGADA!!!!!")
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
        //self.button.alternateImage = self.statusImageOnNeg
        
        // 5. Setup myself as actions target
        button.target = self;
        button.action = "handleStatusItemActions:"
        button.sendActionOn( Int(NSEventMask.LeftMouseDownMask.rawValue) |
            Int(NSEventMask.RightMouseDownMask.rawValue) |
            Int(NSEventMask.LeftMouseUpMask.rawValue) |
            Int(NSEventMask.RightMouseUpMask.rawValue) )
        
        // 6. Save mouse press status
        self.statusItemAction = eMouseStatusItemAction.actionNone
        
        // 7. Store the Menu in my attribute
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
            print("actionPrimary")
            
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
            print("actionSecondary")
            
            // Change my status
            self.statusItemAction = eMouseStatusItemAction.actionSecondary
            
            // Do something here
//            // Start the menu
//            // NOTE: There is one issue with the right click. If I call the menu right away
//            // then the status item stays highlighted after an option is choosen in the menu
//            // so what I'm doing is leting it be called through a timer, after I exit this
//            // function
//            startTimerMenu()
            
        } else {
            
            // Log
            print("actionNone")
            
            // Change my status
            self.statusItemAction = eMouseStatusItemAction.actionNone
        }
        
        // Some logging
        print("handleStatusItemActions, buttonMask: \(buttonMask). primaryDown: \(primaryDown). secondaryDown: \(secondaryDown). statusItemAction: \(self.statusItemAction)")
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
    
}

