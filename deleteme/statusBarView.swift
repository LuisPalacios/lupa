//
//  statusBarView.swift
//  lupa
//
//  Created by Luis Palacios on 12/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class statusBarView: NSView {
    

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so 
    //  they are optionals and do not need to initialize them here, will do later.

    var normalImage     : NSImage!      // Conditional, will initialize later
    var negativeImage   : NSImage!      
    var statusItem      : NSStatusItem!
    
    //  The following attributes can't be optionals due to how I use them, so they
    //  need to be initialized here
    
    var isHighlighted   : Bool = false  // Can't be conditional so needs initialization
    var isMenuVisible   : Bool = false  // Can't be conditional so needs initialization
    

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
    convenience init(_ statusItem: NSStatusItem) {
        
        let itemWidth  : CGFloat = statusItem.length
        let itemHeight : CGFloat = NSStatusBar.systemStatusBar().thickness
        let frame      : NSRect = NSMakeRect( 0.0, 0.0, itemWidth, itemHeight)

        self.init(frame: frame)
 
        // Store pointer to the statusItem
        self.statusItem = statusItem
        
        // Tell statusItem that it has a new View (myself), by calling this
        // we are changing the default statusBar view by myself (custom)
        self.statusItem.view = self
 
        // Preparo que se detecte bien el tema del mouse sobre mi custom view
//        [self.window setIgnoresMouseEvents:NO];
//        [self.window setAcceptsMouseMovedEvents:YES];

        
    }
    
    // Common attribute initialization
    //
    private func initAttributes() {
        // 
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Icon
    /// --------------------------------------------------------------------------------
    
    // Get/Set the main image
    //
    var image : NSImage? {
        get {
            return self.normalImage
        }
        set {
            if ( self.normalImage != newValue )  {
                Swift.print("set image")
                self.normalImage = newValue
                
                let iconSize    : NSSize  = self.normalImage.size
                self.statusItem.length = iconSize.width
                self.needsDisplay = true
 //               self.display()
            }
        }
    }
    
    // Get/Set the negative image
    //
    var imageNeg : NSImage? {
        get {
            return self.negativeImage
        }
        set {
            if ( self.negativeImage != newValue )  {
                Swift.print("set imageNeg")
                self.negativeImage = newValue

                let iconSize    : NSSize  = self.negativeImage.size
                self.statusItem.length = iconSize.width
                self.needsDisplay = true
//                self.display()
            }
        }
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: drawRect the title and icon
    /// --------------------------------------------------------------------------------
    
    override func drawRect(dirtyRect: NSRect) {

        // Call super's
        super.drawRect(dirtyRect)

        // Drawing code here.
        statusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: self.isHighlighted)
        
        // Select the appropiate image
        let icon        : NSImage = ( self.isHighlighted ? self.negativeImage : self.normalImage )
        let iconSize    : NSSize = icon.size

        // It's important the the statusItem has the right size
        self.statusItem.length = iconSize.width

        // Draw the icon at the right point
        let iconX : CGFloat = CGFloat( roundf( Float((NSWidth(self.bounds) - iconSize.width) / 2) ) )
        let iconY : CGFloat = CGFloat( roundf( Float((NSWidth(self.bounds) - iconSize.height) / 2) ) )
        let iconPoint : NSPoint = NSMakePoint(iconX, iconY)
        icon.drawAtPoint(iconPoint, fromRect: dirtyRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
        
        
        //self.normalImage.drawAtPoint(iconPoint, fromRect: dirtyRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
    }
    
    override func keyDown(theEvent: NSEvent) {
        Swift.print ("Key down")
//        let s   =   theEvent.charactersIgnoringModifiers!
//        let s1  =   s.unicodeScalars
//        let s2  =   s1[s1.startIndex].value
//        let s3  =   Int(s2)
//        switch s3 {
//        case NSUpArrowFunctionKey:
//            wc1.navigateUp()
//            return
//        case NSDownArrowFunctionKey:
//            wc1.navigateDown()
//            return
//        default:
//            break
//        }
        super.keyDown(theEvent)
    }
    
//    - (void)keyDown:(NSEvent *)theEvent
//    {
//    switch([theEvent keyCode]) {
//    
//    case 53: // Tecla de escape: ESC
//    
//    // Log
//    // NSLog(@"ESC pulsado en el View ABHUDPopUpView");
//    
//    // Notifico al window controller que han pulsado ESC
//    if ( [self hudPopUpWinCtrl]!=nil ) {
//    
//    
//    // Callback to the window controller
//    //
//    // Notice that I was getting the WARNING "Undeclared selector 'processESCKey'" when I migrated to XCode6
//    // So I'm using the same trick as when I changed to ARC and hitted the warning "performSelector may cause
//    // a leak because its selector is unknown"
//    // See: http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
//    //
//    // The new warning (undeclared selector) appears when using the following:
//    //
//    //    if([[self hudPopUpWinCtrl] respondsToSelector:@selector(processESCKey)]) {
//    //        [[self hudPopUpWinCtrl] performSelector:@selector(processESCKey)];
//    //    }
//    //
//    SEL selector = NSSelectorFromString(@"processESCKey");
//    IMP imp = [self.hudPopUpWinCtrl methodForSelector:selector];
//    if ( imp ) {
//    LPLog(@"");
//    void (*func)(id, SEL, id) = (void *)imp;
//    func(self.hudPopUpWinCtrl, selector, self);
//    }
//    }
//    
//    break;
//    default:
//    [super keyDown:theEvent];
//    }
//    }
}
