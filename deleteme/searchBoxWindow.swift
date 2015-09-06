//
//  searchBoxWindow.swift
//  lupa
//
//  Created by Luis Palacios on 14/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class searchBoxWindow: NSWindow {


    /*
    In Interface Builder, the class for the window is set to this subclass. Overriding the initializer
    provides a mechanism for controlling how objects of this class are created.
    */
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, `defer` flag: Bool) {
        
        // I do use a custom setup with: 
        //      NSBorderlessWindowMask results in a window without a title bar.
        //      NSBackingStoreType.Buffered
        super.init(contentRect: contentRect, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.Buffered, `defer`: false)
        
        // More customization
        self.alphaValue = 1.0
        self.opaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    Custom windows that use the NSBorderlessWindowMask can't become key by default. Override this method
    so that controls in this window will be enabled.
    */
    override var canBecomeKeyWindow: Bool { get { return true } }

}
