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
///  var reference : LPStatusItem = lpStatusItem
///  lpStatusItem.someMethod()
///
///
let lpStatusItem : LPStatusItem = LPStatusItem()



/// DRAFT... FUTURE Singleton