//
//  LPStatusItemWindowCtrl.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 17/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LPStatusItemWindowCtrl: NSWindowController {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  not needed to initialize them here, will do later.
    var statusItem      : LPStatusItem!
    var windowConfig    : LPStatusItemWindowConfig!
    var isWindowOpen    : Bool!
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    /// Initalization when created through IB
    ///
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        // print("init?(coder: \(coder))")
    }
    
    /// Initalization
    ///
    override init(window: NSWindow!)
    {
        super.init(window: window)
        // print("init(window: \(window))")
    }

    
    // The window did load
    //    
    override func windowDidLoad() {
        // Swift.print("windowDidLoad")
        super.windowDidLoad()
    
    }


    /// --------------------------------------------------------------------------------
    //  MARK: Initialize and Connect
    /// --------------------------------------------------------------------------------
    
    /// Initialize my own NSWindowController connecting with both the LPStatusItem
    /// (statusItem) and the calling App custom NSViewController (contentViewController)
    /// (option used by lupa)
    init?( statusItem statusItemOrNil: LPStatusItem!,
        window windowOrNil: NSWindow!,
        windowConfig windowConfigOrNil: LPStatusItemWindowConfig! ) throws {
        
        // Initialize
        super.init(window: nil)
        
        // If I'm not passed valid arguments return
        if ( statusItemOrNil == nil ) {
            throw skStatusItemWindowCtrlNotReady.statusItemIsNil
        }
        if ( windowOrNil == nil ) {
            throw skStatusItemWindowCtrlNotReady.windowOrNil
        }
        if ( windowConfigOrNil == nil ) {
            throw skStatusItemWindowCtrlNotReady.windowConfigOrNil
        }
        
        // Store the window configuration
        windowConfig = windowConfigOrNil
        
        // Prepare myself and make all connections
        self.isWindowOpen   = false
        self.statusItem     = statusItemOrNil // Connect to LPStatusItem

        /// !!! CONNECT the NSWindow  !!!
        /// ============================
        self.window = windowOrNil
    
        // Subscribe myself so I'll receive(Get) Notifications
        NotificationCenter.default.addObserver(self,
            selector: #selector(LPStatusItemWindowCtrl.handleWindowDidResignKeyNotification(_:)),
            name: NSWindow.didResignKeyNotification,
            object: nil)
     }
    
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Notifications
    /// --------------------------------------------------------------------------------

    //  Hide the Window when loosing focus
    //
    @objc func handleWindowDidResignKeyNotification (_ note : Notification) {
        //print("handleWindowDidResignKeyNotification")
        var noteWindow : NSWindow
        if let letNoteWindow : AnyObject = note.object as AnyObject {
            noteWindow = letNoteWindow as! NSWindow
            
            if ( noteWindow != self.window ) {
                return
            }
            if ( self.windowConfig.isPinned == false ) {
                self.dismissStatusItemWindow()
            }
        } else {
            return
        }
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Handling Status Item window visibility
    /// --------------------------------------------------------------------------------

    // Show the status item window
    //
    func showStatusItemWindow() {

        // Con Window
        // ----------
        if let window = self.window {
            self.updateWindowFrame()
            window.alphaValue = 0.0
            self.showWindow(nil)
            self.animateWindow(window, fadeDirection: eFadeDirection.fadeIn)
        }
    }
    
    // Dismiss the status item window
    //
    func dismissStatusItemWindow() {
        // Dismiss the Window fading out...
        if let window = self.window {
            self.animateWindow(window, fadeDirection: eFadeDirection.fadeOut)
        }
    }
    
    
    // Locate the Window in the right place in screen
    //
    func updateWindowFrame () {
        if let letButton = self.statusItem.statusItem.button {
            let button = letButton
            
            if let letButtonWindow = button.window {
                let statusItemRect = letButtonWindow.frame
                
                if let window = self.window {
                    let windowFrame : NSRect = NSMakeRect(
                        NSMinX(statusItemRect) - (NSWidth(window.frame)/2) + (NSWidth(statusItemRect)/2),
                        NSMinY(statusItemRect) - NSHeight(window.frame) - self.windowConfig.windowToStatusMargin,
                        window.frame.size.width,
                        window.frame.size.height)
                    window.setFrame(windowFrame, display: true)
                    window.appearance = NSAppearance.current
                }
            }
        }
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: Window Animation
    /// --------------------------------------------------------------------------------
    
    // Start the animnation
    //
    func animateWindow ( _ window: NSWindow, fadeDirection: eFadeDirection ) {
        switch self.windowConfig.presentationTransition {
        
        case .transitionNone, .transitionFade:
            self.animateWindow(window, fadeTransitionUsingfadeDirection: fadeDirection)
            break
            
        case .transitionSlideAndFade:
            self.animateWindow(window, slideAndFadeTransitionUsingfadeDirection: fadeDirection)
            break
            
        }
    }

    // Start the animation
    //
    func animateWindow ( _ window: NSWindow, fadeTransitionUsingfadeDirection: eFadeDirection ) {
        
        let notificationName : String = ( fadeTransitionUsingfadeDirection == eFadeDirection.fadeIn ? skStatusItemWindowWillShowNotification : skStatusItemWindowWillDismissNotification)
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: window)
        
        NSAnimationContext.runAnimationGroup(
            { (context) -> Void in

                // My own block
                context.duration = self.windowConfig.animationDuration
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                window.animator().alphaValue = (fadeTransitionUsingfadeDirection == eFadeDirection.fadeIn ? 1.0 : 0.0)
                
            }, completionHandler: {
                self.animationCompletionForWindow(window, fadeDirection: fadeTransitionUsingfadeDirection)
        })
    }
    
    // Start the animnation
    //
    // func animateWindow ( window: LPStatusItemWindow, slideAndFadeTransitionUsingfadeDirection: eFadeDirection ) {
    func animateWindow ( _ window: NSWindow, slideAndFadeTransitionUsingfadeDirection: eFadeDirection ) {
        // ToDO
        // print("Animate using slideAndFadeTransitionUsingfadeDirection")
    }

    
    // End the animantion
    //
    // func animationCompletionForWindow ( window: LPStatusItemWindow, fadeDirection: eFadeDirection ) {
    func animationCompletionForWindow ( _ window: NSWindow, fadeDirection: eFadeDirection ) {
        if ( fadeDirection == eFadeDirection.fadeIn ) {
            if ( isWindowOpen == false ) {
                window.makeMain()
                window.makeKey()
                window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.modalPanelWindow)))
                isWindowOpen=true
            }
        } else {
            if ( isWindowOpen == true ) {
                window.close()
                isWindowOpen=false
            }
        }
    }
}
