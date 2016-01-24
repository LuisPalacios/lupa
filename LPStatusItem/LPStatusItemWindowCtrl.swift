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
    //  they are optionals and do not need to initialize them here, will do later.
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

    
    //
    //    
    override func windowDidLoad() {
        // Swift.print("windowDidLoad")
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }


    /// --------------------------------------------------------------------------------
    //  MARK: Initialize and Connect
    /// --------------------------------------------------------------------------------
    
//    /// Initialize my own NSWindowController connecting it with both the LPStatusItem
//    /// (statusItem) and the calling App custom NSViewController (contentViewController)
//    ///
//    init?( statusItem statusItemOrNil: LPStatusItem!, contentViewController contentViewControllerOrNil: NSViewController!, windowConfig windowConfigOrNil: LPStatusItemWindowConfig! ) throws {
//
//        // Initialize
//        super.init(window: nil)
//        
//        // If I'm not passed valid arguments return
//        if ( statusItemOrNil == nil ) {
//            throw skStatusItemWindowCtrlNotReady.statusItemIsNil
//        }
//        if ( contentViewControllerOrNil == nil ) {
//            throw skStatusItemWindowCtrlNotReady.contentViewControllerIsNil
//        }
//        if ( windowConfigOrNil == nil ) {
//            throw skStatusItemWindowCtrlNotReady.windowConfigOrNil
//        }
//        
//        // Check the right sizes are set...
//        if ( contentViewControllerOrNil.preferredContentSize.width == 0 &&
//            contentViewControllerOrNil.preferredContentSize.height == 0 ) {
//                throw skStatusItemWindowCtrlNotReady.customViewControllerIncorrectSize
//        }
//        
//        // Store the window configuration
//        windowConfig = windowConfigOrNil
//        
//        // Prepare myself and make all connections
//        self.isWindowOpen   = false
//        self.statusItem     = statusItemOrNil // Connect to LPStatusItem
//        
//        
//        
//        /// !!! CREATE the NSWindow  !!!
//        /// ============================
//        if let letWindow = LPStatusItemWindow(windowConfig: windowConfigOrNil) {
//            self.window = letWindow
//        } else {
//            throw skStatusItemWindowCtrlNotReady.cantCreateCustomWindow
//        }
//        
//        /// !!! REPLACE contentViewController and its contentView !!!
//        /// =========================================================
//        /// Replace the content view controller with the custom NSViewController
//        /// passed by the AppDelegate, it will replace also the contentView
//        //
//        //  I'm replacing here my Window's contentView controller and it
//        //  will automatically change the view (contentView) controlled by him
//        //
//        //  It will automatically call the setContentView under
//        //  LPStatusItemWindow.swift so I can put a background view in
//        //  between to change it's aspect.
//        //
//        self.contentViewController = contentViewControllerOrNil
//
//
//        // Subscribe myself so I'll receive(Get) Notifications
//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector: "handleWindowDidResignKeyNotification:",
//            name: NSWindowDidResignKeyNotification,
//            object: nil)
//        
//        NSDistributedNotificationCenter.defaultCenter().addObserver(self,
//            selector: "handleAppleInterfaceThemeChangedNotification:",
//            name: "AppleInterfaceThemeChangedNotification",
//            object: nil)
//    }

    
    
    
    /// Initialize my own NSWindowController connecting it with both the LPStatusItem
    /// (statusItem) and the calling App custom NSViewController (contentViewController)
    /// (option used by lupa)
    init?( statusItem statusItemOrNil: LPStatusItem!, window windowOrNil: NSWindow!, windowConfig windowConfigOrNil: LPStatusItemWindowConfig! ) throws {
        
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
        
//        // Log contentView constraints
//        if let window = self.window {
//            if let contentView = window.contentView {
//                Swift.print("DESPUES contentView.constraints: \(contentView.constraints)")
//            }
//        }

        // Subscribe myself so I'll receive(Get) Notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleWindowDidResignKeyNotification:",
            name: NSWindowDidResignKeyNotification,
            object: nil)
     }
    
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Notifications
    /// --------------------------------------------------------------------------------

    //  Hide the Window when loosing focus
    //
    func handleWindowDidResignKeyNotification (note : NSNotification) {
        var noteWindow : NSWindow
        if let letNoteWindow : AnyObject = note.object {
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
        // TODO Review
        //if (self.animationIsRunning) return;

        // Dismiss the Window fading out...
//        let window : LPStatusItemWindow = self.window as! LPStatusItemWindow
//        self.animateWindow(window, fadeDirection: eFadeDirection.fadeOut)
        
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
//                    print("Rect: \(windowFrame)")
                    window.setFrame(windowFrame, display: true)
                    window.appearance = NSAppearance.currentAppearance()
                }
            }
        }
    }

    // Locate the Window in the right place in screen
    //
//    func updateContentViewController ( contentViewController contentViewControllerOrNil: NSViewController! ) {
//        
//        /// !!! CHANGE contentViewController and its contentView !!!
//        /// =========================================================
//        //
//        self.contentViewController = nil
//        
//        self.contentViewController = contentViewControllerOrNil
//        
//        self.updateWindowFrame()
//    }
    
    // Locate the Window in the right place in screen
    //
    func refreshContentViewController ( ) {
        
        /// !!! CHANGE contentViewController and its contentView !!!
        /// =========================================================
        //
//        let actualViewController = self.contentViewController
//        self.contentViewController = nil
//        self.contentViewController = actualViewController
//
        let actualView = self.window?.contentView
        self.window?.contentView = nil
        self.window?.contentView = actualView
        
//        self.contentViewController?.view = nil
//        self.contentViewController?.view = actualView
        
        self.showStatusItemWindow()
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Window Animation
    /// --------------------------------------------------------------------------------
    
    // Start the animnation
    //
//    func animateWindow ( window: LPStatusItemWindow, fadeDirection: eFadeDirection ) {
    func animateWindow ( window: NSWindow, fadeDirection: eFadeDirection ) {
        switch self.windowConfig.presentationTransition {
        
        case .transitionNone, .transitionFade:
            self.animateWindow(window, fadeTransitionUsingfadeDirection: fadeDirection)
            break
            
        case .transitionSlideAndFade:
            self.animateWindow(window, slideAndFadeTransitionUsingfadeDirection: fadeDirection)
            break
            
        }
    }

    
    // Start the animnation
    //
    // func animateWindow ( window: LPStatusItemWindow, fadeTransitionUsingfadeDirection: eFadeDirection ) {
    func animateWindow ( window: NSWindow, fadeTransitionUsingfadeDirection: eFadeDirection ) {
        
        let notificationName : String = ( fadeTransitionUsingfadeDirection == eFadeDirection.fadeIn ? skStatusItemWindowWillShowNotification : skStatusItemWindowWillDismissNotification)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: window)
        
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
    func animateWindow ( window: NSWindow, slideAndFadeTransitionUsingfadeDirection: eFadeDirection ) {
        // ToDO
        // print("Animate using slideAndFadeTransitionUsingfadeDirection")
    }

    
    // End the animantion
    //
    // func animationCompletionForWindow ( window: LPStatusItemWindow, fadeDirection: eFadeDirection ) {
    func animationCompletionForWindow ( window: NSWindow, fadeDirection: eFadeDirection ) {
        if ( fadeDirection == eFadeDirection.fadeIn ) {
            if ( isWindowOpen == false ) {
                window.makeMainWindow()
                window.makeKeyWindow()
                window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.ModalPanelWindowLevelKey))
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
