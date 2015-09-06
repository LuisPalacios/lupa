//
//  searchTextField.swift
//  lupa
//
//  Created by Luis Palacios on 16/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class searchTextField: NSTextField {

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
            // searchBoxViewCtrl.swift will capture it and close the search window
            NSApplication.sharedApplication().sendAction("doCancelSearch:", to: nil, from: self)
            return
 
        default:
            break
        }
        super.doCommandBySelector(aSelector)
    }
}
