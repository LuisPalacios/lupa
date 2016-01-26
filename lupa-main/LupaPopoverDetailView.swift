//
//  LupaPopoverDetailView.swift
//  lupa
//
//  Created by Luis Palacios on 26/1/16.
//  Copyright © 2016 Luis Palacios. All rights reserved.
//

import Cocoa

// Protocol that allows me to call my own delegate
protocol LupaPopoverDetailViewDelegate {
    func popoverClicked()
}


class LupaPopoverDetailView: NSView {

    // Delegate I'll call
    var lupaPopoverDetailViewDelegate:LupaPopoverDetailViewDelegate?

    override func mouseDown(theEvent: NSEvent) {

        // Super's
        super.mouseDown(theEvent)

        if let delegate = lupaPopoverDetailViewDelegate {
            delegate.popoverClicked()
        }
    }    
}
