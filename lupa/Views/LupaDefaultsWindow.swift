//
//  LupaDefaultsWindow.swift
//  lupa
//
//  Created by Luis Palacios on 28/1/16.
//  Copyright © 2016 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaDefaultsWindow: NSWindow {
   
    /// Overridden init so the WINDOW is TRANSPARENT
    override init(contentRect: NSRect, styleMask aStyle: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        self.alphaValue = 1.0
        self.isOpaque = false
    }
    
//    /// Initalization when created through IB
//    ///
//    required init?(coder: NSCoder)
//    {
//        super.init(coder: coder)
//        self.alphaValue = 1.0
//        self.isOpaque = false
//    }
    
}
