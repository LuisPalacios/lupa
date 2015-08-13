//
//  Globals.swift
//  lupa
//
//  Created by Luis Palacios on 11/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Foundation


///  Application preferences are stored under:
///
///  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
///
///  To check that file's content from command line:
///
///  defaults read parchis.org.lupa.plist
///

// LupaDefaults: Key's for storing User defaults
// 
struct LUPADefaults {
    static let lupa_URLPrefix     = "lupa_URLPrefix"
    static let lupa_StatusBarMode = "lupa_StatusBarMode"
}

