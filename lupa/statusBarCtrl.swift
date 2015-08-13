//
//  statusBarCtrl.swift
//  lupa
//
//  Created by Luis Palacios on 12/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa


class statusBarCtrl: NSObject, NSMenuDelegate {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.

    //var lupaDefaultsController  : LupaDefaults!      // Preferences -

    var statusItem              : NSStatusItem!
    var statusItemAction        : LUPAStatusItemType!
    var button                  : NSStatusBarButton!
    var statusItemMenu          : NSMenu!
    
    var statusImageOn           : NSImage!
    var statusImageOff          : NSImage!
    var statusImageOnNeg        : NSImage!
    var statusImageOffNeg       : NSImage!


    /// --------------------------------------------------------------------------------
    //  MARK: Init
    /// --------------------------------------------------------------------------------
    
    override init() {
        super.init()
    }
    
    deinit {
    }

    // Custom init by LuisPa
    //
    convenience init(_ statusMenu: NSMenu) {
        self.init()
        
        // Initialize the defaults preferences and window controller
        self.lupaDefaultsController = LupaDefaults(windowNibName: "LupaDefaults")
        
        // Have the "image" objetcs prepared to be able to set the right icon
        // based on status (On/Off) and Clicked (pressed=Negative/Unpressed=Normal)
        let bundle : NSBundle = NSBundle.mainBundle()
        self.statusImageOn = NSImage(contentsOfFile: bundle.pathForResource("LupaOn_18x18", ofType: "png")!)
        self.statusImageOff = NSImage(contentsOfFile: bundle.pathForResource("LupaOff_18x18", ofType: "png")!)
        self.statusImageOnNeg = NSImage(contentsOfFile: bundle.pathForResource("LupaOnNeg_18x18", ofType: "png")!)
        self.statusImageOffNeg = NSImage(contentsOfFile: bundle.pathForResource("LupaOffNeg_18x18", ofType: "png")!)

        // 1. Create an statusItem inside the status bar
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        // 2. Get the NSStatusBarButton (*new* in 10.10) and prepare it
        self.button = self.statusItem.button
        self.button.image = self.statusImageOn
        self.button.alternateImage = self.statusImageOnNeg
        
        // 4. Bind the custom menu I've been given through the init, 
        // ISSUE: If I use this method then I cannot separate left/right clicks, 
        //        the *new* 10.10 API does not resolve it, so I've implemented my own mouse event handling
        //statusMenu.delegate = self              // Set myself as delegate
        //self.statusItem.menu = statusMenu       // Assign the menu
        
        // 4. Setup my own mouse event handling
        button.target = self;
        button.action = "handleStatusItemActions:"
        button.sendActionOn( Int(NSEventMask.LeftMouseDownMask.rawValue) | Int(NSEventMask.RightMouseDownMask.rawValue) |
                             Int(NSEventMask.LeftMouseUpMask.rawValue) | Int(NSEventMask.RightMouseUpMask.rawValue) )
        self.statusItemAction = LUPAStatusItemType.LUPAStatusItemActionNone
        
        // 5. Store the Menu in my attribute
        self.statusItemMenu = statusMenu
        
        
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: StatusBar button handling
    /// --------------------------------------------------------------------------------

    // MARK: Action on user clicking the icon
    //
    func handleStatusItemActions(sender : AnyObject) {

        // Identify which button has been pressed
        let buttonMask = NSEvent.pressedMouseButtons()
        let primaryDown : Bool = ((buttonMask & (1 << 0)) != 0);
        let secondaryDown : Bool = ((buttonMask & (1 << 1)) != 0);


        if (primaryDown) {
            self.statusItemAction = LUPAStatusItemType.LUPAStatusItemActionPrimary;

            // Setup here actions for a Left-Click
            
            print ("Left clicked")
            
        } else if (secondaryDown) {
            self.statusItemAction = LUPAStatusItemType.LUPAStatusItemActionSecondary;

            // Find out the Screen Coordinates of the NSStatusItem Frame and generate
            // a right-click MENU.
            let rectInWindow : NSRect = self.button.convertRect(self.button.bounds, toView: nil)
            if let letButtonWindow = self.button.window {
                
                let buttonWindow = letButtonWindow
                let screenRect : NSRect = buttonWindow.convertRectToScreen(rectInWindow)
                let point : NSPoint = NSMakePoint(screenRect.origin.x, screenRect.origin.y - 3.0)
                // print("screenRect: \(screenRect)   point: \(point)")
                
                // Start the menu
                self.statusItemMenu.popUpMenuPositioningItem(nil, atLocation: point, inView: nil)
                
                // There is one issue with this Solution: the status item stays highlighted after
                // an option is choosen in the right-click menu. The highlight goes away as soon 
                // as you interact with something else; so I'm simulating it programatically by
                // generating a "click" :)
                self.button.performClick(self)
                
            }
            
        } else {

            self.statusItemAction = LUPAStatusItemType.LUPAStatusItemActionNone;
            
        }
        
        // Some logging
        // print("handleStatusItemActions, buttonMask: \(buttonMask). primaryDown: \(primaryDown). secondaryDown: \(secondaryDown). statusItemAction: \(self.statusItemAction)")
        
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Defaults (preferences) handling
    /// --------------------------------------------------------------------------------
    

    // Open the preferences (Defaults) window
//    //
//    func doLupaDefaults(sender: AnyObject) {
//        if let window = self.lupaDefaultsController.window {
//            window.makeKeyAndOrderFront(self)
//            window.makeFirstResponder(self.lupaDefaultsController.window)
//            window.center()
//        }
//    }

}
