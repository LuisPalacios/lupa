//
//  LPStatusItemBackgroundView.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 26/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LPStatusItemBackgroundView: NSView {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    
    var windowConfig    : LPStatusItemWindowConfig!

    
    /// --------------------------------------------------------------------------------
    //  MARK: Custom accesors
    /// --------------------------------------------------------------------------------
    
    // The receiver’s frame rectangle
    //
    override var frame : NSRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.needsDisplay = true
        }
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Init
    /// --------------------------------------------------------------------------------
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initAttributes()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initAttributes()
    }
    
    // Custom init by LuisPa
    //
    convenience init(frame frameRect: NSRect, windowConfiguration windowConfig: LPStatusItemWindowConfig) {
        
        // Call super
        //
        self.init(frame: frameRect)
        
        // Store the window configuration
        //
        self.windowConfig = windowConfig
    }
    
    // Common attribute initialization
    //
    private func initAttributes() {
        // 
    }
    
    // Draw
    //
    override func drawRect(dirtyRect: NSRect) {

        // Own drawing code...
        
        let arrowHeight         = LPStatusItem_DefaultArrowHeight
        let arrowWidth          = LPStatusItem_DefaultArrowWidth
        let cornerRadius        = LPStatusItem_DefaultCornerRadius
        let backgroundRect      = NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), NSHeight(self.bounds) - arrowHeight)
        let windowPath          = NSBezierPath()
        let arrowPath           = NSBezierPath()
        let backgroundPath      = NSBezierPath(roundedRect: backgroundRect, xRadius: cornerRadius, yRadius: cornerRadius)
        
        let leftPoint           = NSPoint(x: (NSWidth(backgroundRect)/2) - arrowWidth, y: NSMaxY(backgroundRect))
        let topPoint            = NSPoint(x: (NSWidth(backgroundRect)/2), y: NSMaxY(backgroundRect) + arrowHeight)
        let rightPoint          = NSPoint(x: (NSWidth(backgroundRect)/2) + arrowWidth, y: NSMaxY(backgroundRect))
        
        arrowPath.moveToPoint(leftPoint)
        arrowPath.curveToPoint(topPoint,
            controlPoint1: NSMakePoint(NSWidth(backgroundRect)/2 - arrowWidth/4, NSMaxY(backgroundRect)),
            controlPoint2: NSMakePoint(NSWidth(backgroundRect)/2 - arrowWidth/7, NSMaxY(backgroundRect) + arrowHeight))
        arrowPath.curveToPoint(rightPoint,
            controlPoint1: NSMakePoint(NSWidth(backgroundRect)/2 + arrowWidth/7, NSMaxY(backgroundRect) + arrowHeight),
            controlPoint2: NSMakePoint(NSWidth(backgroundRect)/2 + arrowWidth/4, NSMaxY(backgroundRect)))
        arrowPath.moveToPoint(leftPoint)
        arrowPath.closePath()
        
        windowPath.appendBezierPath(arrowPath)
        windowPath.appendBezierPath(backgroundPath)
        
        NSColor.windowBackgroundColor().setFill()
        //self.windowConfig.backgroundColor.setFill()
        windowPath.fill()
        
    }
    
}
