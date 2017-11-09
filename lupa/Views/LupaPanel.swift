//
//  LupaPanel.swift
//  lupa
//
//  Created by Luis Palacios on 20/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa
// NSPanel {

class LupaPanel: NSPanel {
    
    // Accept to become key window so it can activate and also detect ESC key
    //
    override var canBecomeKey: Bool {
        return true
    }
    
    // Accept to become main window
    //
    override var canBecomeMain: Bool {
        return true
    }
    
    // Handle ESCAPE Key when the focus is on the window itself
    //
    override func cancelOperation(_ sender: Any?) {
        // Close the Window
        lpStatusItem.dismissStatusItemWindow()
    }
}
