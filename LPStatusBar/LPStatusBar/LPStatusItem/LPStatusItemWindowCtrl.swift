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
    
    /// Initialize my own NSWindowController connecting it with both the LPStatusItem
    /// (statusItem) and the calling App custom NSViewController (contentViewController)
    ///
    init?( statusItem statusItemOrNil: LPStatusItem!, contentViewController contentViewControllerOrNil: NSViewController!, windowConfig windowConfigOrNil: LPStatusItemWindowConfig! ) throws {

        // Initialize
        super.init(window: nil)
        
        // If I'm not passed valid arguments return
        if ( statusItemOrNil == nil ) {
            throw skStatusItemWindowCtrlNotReady.statusItemIsNil
        }
        if ( contentViewControllerOrNil == nil ) {
            throw skStatusItemWindowCtrlNotReady.contentViewControllerIsNil
        }
        if ( windowConfigOrNil == nil ) {
            throw skStatusItemWindowCtrlNotReady.windowConfigOrNil
        }
        
        // Check the right sizes are set...
        if ( contentViewControllerOrNil.preferredContentSize.width == 0 &&
            contentViewControllerOrNil.preferredContentSize.height == 0 ) {
                throw skStatusItemWindowCtrlNotReady.customViewControllerIncorrectSize
        }
        
        // Store the window configuration
        windowConfig = windowConfigOrNil
        
        // Prepare myself and make all connections
        self.isWindowOpen   = false
        self.statusItem     = statusItemOrNil // Connect to LPStatusItem
        
        /// Create my custom NSWindow
        /// =========================
        if let letWindow = LPStatusItemWindow(windowConfig: windowConfigOrNil) {
            self.window = letWindow
        } else {
            throw skStatusItemWindowCtrlNotReady.cantCreateCustomWindow
        }
        
        /// Replace my content view controller with the custom NSViewController
        /// passed by the AppDelegate
        /// ===================================================================
        self.contentViewController = contentViewControllerOrNil

        // Subscribe myself so I'll receive(Get) Notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleWindowDidResignKeyNotification:",
            name: NSWindowDidResignKeyNotification,
            object: nil)
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleAppleInterfaceThemeChangedNotification:",
            name: "AppleInterfaceThemeChangedNotification",
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
    
    // LUIS - ToDo !!!!
    //
    func handleAppleInterfaceThemeChangedNotification (note : NSNotification) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:CCNSystemInterfaceThemeChangedNotification object:nil];
        print("handleAppleInterfaceThemeChangedNotification")
    }

    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Handling Status Item window visibility
    /// --------------------------------------------------------------------------------

    // Show the status item window
    //
    func showStatusItemWindow() {

        // Refresh where and how to show the window
        self.updateWindowFrame()
        self.window?.alphaValue = 0.0
        self.showWindow(nil)
        
        // Show the Window fading in...
        let window : LPStatusItemWindow = self.window as! LPStatusItemWindow
        self.animateWindow(window, fadeDirection: eFadeDirection.fadeIn)
    }
    
    // Dismiss the status item window
    //
    func dismissStatusItemWindow() {
        // TODO Review
        //if (self.animationIsRunning) return;

        // Dismiss the Window fading out...
        let window : LPStatusItemWindow = self.window as! LPStatusItemWindow
        self.animateWindow(window, fadeDirection: eFadeDirection.fadeOut)
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
                    window.appearance = NSAppearance.currentAppearance()
                }
            }
        }
    }
    
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Window Animation
    /// --------------------------------------------------------------------------------
    
    // Start the animnation
    //
    func animateWindow ( window: LPStatusItemWindow, fadeDirection: eFadeDirection ) {
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
    func animateWindow ( window: LPStatusItemWindow, fadeTransitionUsingfadeDirection: eFadeDirection ) {
        
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
    func animateWindow ( window: LPStatusItemWindow, slideAndFadeTransitionUsingfadeDirection: eFadeDirection ) {
        // ToDO
        // print("Animate using slideAndFadeTransitionUsingfadeDirection")
    }
    
    
    /*
    - (void)animateWindow:(CCNStatusItemWindow *)window withSlideAndFadeTransitionUsingFadeDirection:(CCNFadeDirection)fadeDirection {
    NSString *notificationName = (fadeDirection == CCNFadeDirectionFadeIn ? CCNStatusItemWindowWillShowNotification : CCNStatusItemWindowWillDismissNotification);
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:window];
    
    CGRect windowStartFrame, windowEndFrame;
    CGRect calculatedFrame = NSMakeRect(NSMinX(window.frame), NSMinY(window.frame) + CCNTransitionDistance, NSWidth(window.frame), NSHeight(window.frame));
    
    switch (fadeDirection) {
    case CCNFadeDirectionFadeIn: {
    windowStartFrame = calculatedFrame;
    windowEndFrame = window.frame;
    break;
    }
    case CCNFadeDirectionFadeOut: {
    windowStartFrame = window.frame;
    windowEndFrame = calculatedFrame;
    break;
    }
    }
    [window setFrame:windowStartFrame display:NO];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    context.duration = self.windowConfiguration.animationDuration;
    context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [[window animator] setFrame:windowEndFrame display:NO];
    [[window animator] setAlphaValue:(fadeDirection == CCNFadeDirectionFadeIn ? 1.0 : 0.0)];
    
    } completionHandler:[self animationCompletionForWindow:window fadeDirection:fadeDirection]];
    }
    
    - (CCNStatusItemWindowAnimationCompletion)animationCompletionForWindow:(CCNStatusItemWindow *)window fadeDirection:(CCNFadeDirection)fadeDirection {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    __weak typeof(self) wSelf = self;
    
    return ^{
    wSelf.animationIsRunning = NO;
    wSelf.windowIsOpen = (fadeDirection == CCNFadeDirectionFadeIn);
    
    if (fadeDirection == CCNFadeDirectionFadeIn) {
    [window makeKeyWindow];
    [nc postNotificationName:CCNStatusItemWindowDidShowNotification object:window];
    }
    else {
    [window orderOut:wSelf];
    [window close];
    [nc postNotificationName:CCNStatusItemWindowDidDismissNotification object:window];
    }
    };
    }

*/
    // End the animantion
    //
    func animationCompletionForWindow ( window: LPStatusItemWindow, fadeDirection: eFadeDirection ) {
        // let nc : NSNotificationCenter = NSNotificationCenter.defaultCenter()
        if ( fadeDirection == eFadeDirection.fadeIn ) {
            // window.makeKeyAndOrderFront(self)
            window.makeKeyWindow()
        } else {
            window.close()
        }
    }
}
