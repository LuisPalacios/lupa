//
//  LPStatusItem.swift
//  lupa
//
//  Created by Luis Palacios on 14/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

/// Singleton LPStatusItem
///
/// Global (Singleton) variable of my Swift LPStatusItem. This just calls
/// my default init and is threat safedue to all global variables are dispatch_once
/// by default in Swift.
//
/// Reference it from SWIFT:
///  var reference : LPStatusItem = lpStatusItem
///  lpStatusItem.someMethod()
///
///
@objc class LPStatusItem: NSObject {
    
    // --------------------------------------------------------------------------------
    // MARK: Singleton
    // --------------------------------------------------------------------------------
    //
    class var sharedInstance: LPStatusItem {
        return lpStatusItem
    }
    
    
    // --------------------------------------------------------------------------------
    // MARK: Attributes - Global variables and constants
    // --------------------------------------------------------------------------------
    
    // Class attributes
    var name: String            = "LPStatusItem"

    // --------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------
    //
    // CLASS METHODS
    //
    // --------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------
    // MARK: Init / Deinit
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
  
}


/// DRAFT... FUTURE Singleton
