//
//  LupaSearchField.swift
//  lupa
//
//  Created by Luis Palacios on 20/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaSearchField: NSSearchField {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    // Send a doCancelSearch: command to firstResponder
    //
    override func doCommandBySelector(aSelector: Selector) {
        switch aSelector {
        case "cancelOperation:":
            // Send a message to firstResponder
            Swift.print("doCancelSearch:")
            NSApplication.sharedApplication().sendAction("doCancelSearch:", to: nil, from: self)
            return
            
        default:
            break
        }
        super.doCommandBySelector(aSelector)
    }
}
