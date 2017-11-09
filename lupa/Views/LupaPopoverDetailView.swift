//
//  LupaPopoverDetailView.swift
//  lupa
//
//  Created by Luis Palacios on 26/1/16.
//  Copyright © 2016 Luis Palacios. All rights reserved.
//

import Cocoa

// Protocol, callback communicates user mouse clicked the popover detail view
protocol LupaPopoverDetailViewDelegate {
    func popoverDetailViewClicked()
    func popoverDetailViewRightClicked()
}


class LupaPopoverDetailView: NSView {

    // Delegate attribute
    var lupaPopoverDetailViewDelegate:LupaPopoverDetailViewDelegate?


    // Left mouse
    //
    override func mouseDown(with theEvent: NSEvent) {

        // Super's
        super.mouseDown(with: theEvent)

        // Tell the delegate mouse was clicked
        if let delegate = lupaPopoverDetailViewDelegate {
            delegate.popoverDetailViewClicked()
        }
        
    }
    
    
    
    // Right Mouse
    //
    override func  rightMouseDown(with theEvent: NSEvent) {
        
        // Super's rightMouse
        super.rightMouseDown(with: theEvent)
        
        
        // Tell the delegate mouse was right clicked
        if let delegate = lupaPopoverDetailViewDelegate {
            delegate.popoverDetailViewRightClicked()
        }

    }

}
