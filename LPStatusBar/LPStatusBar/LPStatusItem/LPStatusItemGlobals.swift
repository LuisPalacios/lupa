//
//  LPStatusItemGlobals.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 17/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Foundation


/// Singleton LPStatusItem
///
/// Global (Singleton) variable of my Swift LPStatusItem. This just calls
/// my default init and is threat safedue to all global variables are dispatch_once
/// by default in Swift.
//
/// Reference it from SWIFT:
///  let lpStatusItem : LPStatusItem = LPStatusItem()
///  lpStatusItem.someMethod()
///
///
let lpStatusItem : LPStatusItem = LPStatusItem()


/// ErrorType's 
///
enum skStatusItemWindowCtrlNotReady: ErrorType {
    case statusItemIsNil
    case contentViewControllerIsNil
    case windowConfigOrNil
    case customViewControllerIncorrectSize
    case cantCreateCustomWindow
}
extension skStatusItemWindowCtrlNotReady: CustomStringConvertible {
    var description: String {
        switch self {
        case statusItemIsNil: return "Error: The statusItem is nil"
        case contentViewControllerIsNil: return "Error: The contentViewController is nil"
        case windowConfigOrNil: return "Error: The windowConfigOrNil is nil"
        case customViewControllerIncorrectSize: return "Error: contentSize of the custom NSViewController is wrong (zero)"
        case cantCreateCustomWindow: return "Error: Cannot create the custom NSWindow"
        }
    }
}



// Type of Mouse Action
//
enum eMouseStatusItemAction: Int {
    case actionNone = 0
    case actionPrimary
    case actionSecondary
}

// Defaults
let LPStatusItem_DefaultArrowHeight         : CGFloat        = 11.0
let LPStatusItem_DefaultArrowWidth          : CGFloat        = 42.0
let LPStatusItem_DefaultCornerRadius        : CGFloat        = 5.0
let LPStatusItem_DefaultStatusItemMargin    : CGFloat        = 2.0
let LPStatusItem_DefaultAnimationDuration   : NSTimeInterval = 0.21;

// Window Fade direction
let LPStatusItem_DefaultTransitionDistance : CGFloat = 8.0
enum eFadeDirection: Int {
    case fadeIn = 0
    case fadeOut
}
enum ePresentationTransition: Int {
    case transitionNone = 0
    case transitionFade
    case transitionSlideAndFade
}

let skStatusItemWindowWillShowNotification      = "skStatusItemWindowWillShowNotification";
let skStatusItemWindowDidShowNotification       = "skStatusItemWindowDidShowNotification";
let skStatusItemWindowWillDismissNotification   = "skStatusItemWindowWillDismissNotification";
let skStatusItemWindowDidDismissNotification    = "skStatusItemWindowDidDismissNotification";
let skSystemInterfaceThemeChangedNotification   = "skSystemInterfaceThemeChangedNotification";

