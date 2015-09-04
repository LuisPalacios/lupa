//
//  LupaGlobals.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 3/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Foundation
import AppKit

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
    static let lupa_URLPrefix       = "lupa_URLPrefix"
    static let lupa_SearchSeparator = "lupa_SearchSeparator"                    // Character to use to separate te words in the search field (byDefault space)
    static let lupa_SearchSeparatorEnabled = "lupa_SearchSeparatorEnabled"      // Use the separator
    static let lupa_StatusBarMode   = "lupa_StatusBarMode"
    static let lupa_TestMode        = "lupa_TestMode"           // Doesn't call the Browser, just logs the URL
    static let lupa_Hotkey          = "lupa_Hotkey"
    static let lupa_HotkeyEnabled   = "lupa_HotkeyEnabled"
}

// Type of Mouse Action
//
enum LUPAStatusItemType: Int {
    case LUPAStatusItemActionNone = 0
    case LUPAStatusItemActionPrimary
    case LUPAStatusItemActionSecondary
}


/// Returns the program long name, based on constans found in "AbacoVersion.swift"
/// automatically generated from custom Xcode->Project->Build Phase script, which
/// analises the GIT information and creates version information
func programLongName() -> String
{
    // let myProgramLongName : String = "Lupa \(skPROGRAM_DISPLAY_VERSION)-\(ikPROGRAM_VERSION)(\(skPROGRAM_BUILD))"
    let myProgramLongName : String = "Lupa Alfa 1"
    return myProgramLongName;
}

