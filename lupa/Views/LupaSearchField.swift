//
//  LupaSearchField.swift
//  lupa
//
//  Created by Luis Palacios on 20/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaSearchField: NSSearchField {

    // Send a doCancelSearch: command to firstResponder
    //
    override func doCommand(by aSelector: Selector) {
        switch aSelector {
        case #selector(NSResponder.cancelOperation(_:)):
            // Send a message to firstResponder
            Swift.print("doCancelSearch:")
            NSApplication.shared.sendAction("doCancelSearch:", to: nil, from: self)
            return
            
        default:
            break
        }
        super.doCommand(by: aSelector)
    }
    
    
}
