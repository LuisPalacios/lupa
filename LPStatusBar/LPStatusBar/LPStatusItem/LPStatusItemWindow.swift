//
//  LPStatusItemWindow.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 18/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa
import QuartzCore

class LPStatusItemWindow: NSPanel {

    
    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    var statusItem      : LPStatusItem!
    var contentViewCtr  : NSViewController!
    var windowConfig    : LPStatusItemWindowConfig!

    var backgroundView  : LPStatusItemBackgroundView!
    var userContentView : NSView!
    
    var isWindowOpen    : Bool!
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    /// Initalization when created through IB
    ///
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        // Log
        // Swift.print("init?(coder: \(coder))")
    }
    
    /// Initialize my custom NSPanel with the passed window configuration
    ///
    init?(windowConfig windowConfigOrNil: LPStatusItemWindowConfig!) {
        // Log
        // Swift.print("init windowConfig")

        // Store the window configuration
        windowConfig = windowConfigOrNil
        
        // Super Initialize
        //
        //  Note: During super.init() the contentView SET is called
        //
        super.init(contentRect: NSZeroRect, styleMask: NSNonactivatingPanelMask, backing: NSBackingStoreType.Buffered, `defer`: true)
        
        // Setup the window class
        self.opaque     = false
        self.hasShadow  = true
        self.level      = Int(CGWindowLevelForKey(CGWindowLevelKey.StatusWindowLevelKey))
        self.backgroundColor    = NSColor.clearColor()
        self.collectionBehavior = [NSWindowCollectionBehavior.Stationary , NSWindowCollectionBehavior.IgnoresCycle]
        self.appearance = NSAppearance.currentAppearance()
        
        
        // Log
        // Swift.print("LPStatusItemWindow - Initialized my own NSWindow")
    }
    

    /// --------------------------------------------------------------------------------
    //  MARK: Window behaviour
    /// --------------------------------------------------------------------------------
    
    // Say always "true" to canBecomeKeyWindow
    //
    override var canBecomeKeyWindow: Bool {
        get {
            return true
        }
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: contentView
    /// --------------------------------------------------------------------------------
    
    // Custom handling of the contentView
    //
    override var contentView : NSView? {
        get {
            Swift.print ("contentView GET")
            //return super.contentView
            return self.userContentView
        }
        set {
            // Swift.print ("contentView SET - ENTRADA self.contentView : \(self.contentView)")
            Swift.print ("contentView SET - ENTRADA newValue : \(newValue)")
            
            // if already using my userContentView return
            if ( self.userContentView == newValue ) {
                return
            }

            // Prepare the passed new NSView
            let newUserContentView : NSView = newValue!
            let bounds           : NSRect = newUserContentView.bounds
            let antialiasingMask : CAEdgeAntialiasingMask = [CAEdgeAntialiasingMask.LayerLeftEdge,  CAEdgeAntialiasingMask.LayerLeftEdge, CAEdgeAntialiasingMask.LayerLeftEdge, CAEdgeAntialiasingMask.LayerLeftEdge]
            
            //
            if let letBackgroundView = super.contentView {
                self.backgroundView = letBackgroundView as! LPStatusItemBackgroundView
            } else {
                self.backgroundView = LPStatusItemBackgroundView(frame: bounds, windowConfiguration: self.windowConfig)
                self.backgroundView.wantsLayer = true
                self.backgroundView.layer?.frame = bounds
                self.backgroundView.layer?.cornerRadius = LPStatusItem_DefaultCornerRadius
                self.backgroundView.layer?.masksToBounds = true
                self.backgroundView.layer?.edgeAntialiasingMask = antialiasingMask
                super.contentView   = self.backgroundView
                //Swift.print("let No-OK. super.contentView value: \(super.contentView)")
            }
            
            //
            if self.userContentView != nil {
                self.userContentView.removeFromSuperview()
            }
            self.userContentView = newUserContentView
            self.userContentView.frame = self.contentRectForFrameRect(bounds)
            self.userContentView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
            self.userContentView.wantsLayer = true
            self.userContentView.layer?.frame = bounds
            self.userContentView.layer?.cornerRadius = LPStatusItem_DefaultCornerRadius
            self.userContentView.layer?.masksToBounds = true
            self.userContentView.layer?.edgeAntialiasingMask = antialiasingMask
            
            //
            self.backgroundView.addSubview(self.userContentView)

            //super.contentView = newValue
            //Swift.print ("contentView SET - SALIDA self.contentView : \(self.contentView)")
        }
    }
}
