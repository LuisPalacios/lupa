//
//  LPStatusItemWindow.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 18/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa
import QuartzCore

class LPStatusItemWindow: NSWindow {

    
    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    var statusItem      : LPStatusItem!
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
//        super.init(contentRect: NSZeroRect, styleMask: NSNonactivatingPanelMask, backing: NSBackingStoreType.Buffered, `defer`: true)

        super.init(contentRect: NSMakeRect(0, 0, 100, 100), styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask | NSTexturedBackgroundWindowMask, backing: NSBackingStoreType.Buffered, `defer`: true)
        
        // Setup the window class
        self.opaque     = false
        self.hasShadow  = true
        self.level      = Int(CGWindowLevelForKey(CGWindowLevelKey.StatusWindowLevelKey))
        //
        Swift.print("LUIS BACKGROUND COLOR")
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
            return super.contentView
            
            
            // Log
            //Swift.print ("contentView GET")
            return self.userContentView
        }
        set {

            Swift.print("searchViewCtrl.view (CHECK): \(newValue)")

            // Log ANTES
            if let letTheContentView = super.contentView {
                let theContentView = letTheContentView
                Swift.print("ANTES: super.contentView.constraints: \(theContentView.constraints)")
            }

            if ( super.contentView == newValue ) {
                super.contentView = nil
            }
            super.contentView = newValue
            super.contentView!.translatesAutoresizingMaskIntoConstraints = false
//            Swift.print("translatesAutoresizingMaskIntoConstraints: \(super.contentView!.translatesAutoresizingMaskIntoConstraints)")
            
            // Log DESPUES
            if let letTheContentView = super.contentView {
                let theContentView = letTheContentView
                if theContentView.constraints.count > 0 {
                    // Remove all constraints
                    //theContentView.removeConstraints(theContentView.constraints)
                    
                    // Log
                    Swift.print("DESPUES: super.contentView.constraints: \(theContentView.constraints)")
                }
            }
            
            return
            
            // Log
            // Swift.print ("contentView SET - ENTRADA newValue : \(newValue)")
            
            // if already using my userContentView return
            if ( self.userContentView == newValue ) {
                return
            }

            // Prepare the passed new NSView
            let newUserContentView : NSView = newValue!
            let bounds           : NSRect = newUserContentView.bounds
            let antialiasingMask : CAEdgeAntialiasingMask = [CAEdgeAntialiasingMask.LayerLeftEdge,  CAEdgeAntialiasingMask.LayerRightEdge, CAEdgeAntialiasingMask.LayerBottomEdge, CAEdgeAntialiasingMask.LayerTopEdge]

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

                //super.contentView!.translatesAutoresizingMaskIntoConstraints = true
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
            //self.addSubView(self.userContentView, containerView: self.backgroundView)
            
            //super.contentView = newValue
            //Swift.print ("contentView SET - SALIDA self.contentView : \(self.contentView)")
        }
    }
  
    func addSubView ( insertedView: NSView, containerView: NSView  ) {
        
        Swift.print("containerView.constraints: \(containerView.constraints)")
        
        containerView.addSubview(insertedView)
        //insertedView.translatesAutoresizingMaskIntoConstraints = false
        let viewsDict = ["insertedView" : insertedView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[insertedView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[insertedView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        containerView.addConstraints(horizontalConstraints)
        containerView.addConstraints(verticalConstraints)
        Swift.print("PUSE EL TEMITA EN MARCHA")
        // containerView.layoutSubtreeIfNeeded()
        Swift.print("containerView.constraints: \(containerView.constraints)")
    }
    
}


