//
//  LPStatusItemWindowConfig.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 17/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LPStatusItemWindowConfig: NSObject {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    var isPinned                : Bool!
    var presentationTransition  : ePresentationTransition = ePresentationTransition.transitionNone
    var backgroundColor         : NSColor!
    
    ///
    var windowToStatusMargin : CGFloat {
        get {
            return LPStatusItem_DefaultStatusItemMargin
        }
    }
    
    ///
    var animationDuration : TimeInterval {
        get {
            return LPStatusItem_DefaultAnimationDuration
        }
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    override init() {
        super.init()
        // print("LPStatusItem - init()")
        
        // Defaults
        self.isPinned = false
        self.presentationTransition = ePresentationTransition.transitionFade
        self.backgroundColor = NSColor.windowBackgroundColor
    }
    
    deinit {
    }
    


}
