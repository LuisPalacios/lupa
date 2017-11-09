//
//  LupaDefaultsView.swift
//  lupa
//
//  Created by Luis Palacios on 28/1/16.
//  Copyright © 2016 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaDefaultsView: NSView {

    /// Overridden to draw a custom Rect
    override func draw ( _ dirtyRect: NSRect ) {
        
        // Clear the drawing rect.
        NSColor.clear.set()
        self.frame.fill()
    }
}

