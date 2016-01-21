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
    static let lupa_URLPrefix               = "lupa_URLPrefix"
    static let lupa_SearchSeparator         = "lupa_SearchSeparator"                // Character to use to separate words in search field
    static let lupa_SearchSeparatorEnabled  = "lupa_SearchSeparatorEnabled"         // Use the separator
    static let lupa_StatusBarMode           = "lupa_StatusBarMode"                  //
    static let lupa_TestMode                = "lupa_TestMode"                       // Doesn't call the Browser, just logs the URL
    static let lupa_Hotkey                  = "lupa_Hotkey"                         //
    static let lupa_HotkeyEnabled           = "lupa_HotkeyEnabled"                  //

    static let lupa_BIND_User               = "lupa_BIND_User"                      // ldapsearch -D  CN=<lupa_BIND_User>, <lupa_BIND_UserStore>
    static let lupa_BIND_UserStore          = "lupa_BIND_UserStore"                 // ldapsearch -D  CN=<lupa_BIND_User>, <lupa_BIND_UserStore>
    static let lupa_BIND_Password           = "lupa_BIND_Password"                  // ldapsearch -w

    static let lupa_LDAP_Command            = "lupa_LDAP_Command"                   // ldapsearch -x
    static let lupa_LDAP_BaseDN             = "lupa_LDAP_BaseDN"                    // -b ou=employees,o=company.com
    static let lupa_LDAP_Host               = "lupa_LDAP_Host"                      // -H ldaps://ldap.company.com
    static let lupa_LDAP_Port               = "lupa_LDAP_Port"                      // port

    // LDAP attributes that will be retrieved. 
    static let lupa_LDAP_Attr_DN            = "lupa_LDAP_Attr_DN"                   // Attribute for the distinguished name (fixed to "dn:")
    static let lupa_LDAP_Attr_CN            = "lupa_LDAP_Attr_CN"                   // Attribute for the common name (fixed to "cn:")
    static let lupa_LDAP_Attr_UID           = "lupa_LDAP_Attr_UID"                  // Attribute for the user id (fixed to "uid:")
    static let lupa_LDAP_Attr_Desc          = "lupa_LDAP_Attr_Desc"                 // Attribute for the description
    static let lupa_LDAP_Attr_Country       = "lupa_LDAP_Attr_Country"              // Attribute for the country
    static let lupa_LDAP_Attr_City          = "lupa_LDAP_Attr_City"                 // Attribute for the city
    static let lupa_LDAP_Attr_VoiceLin      = "lupa_LDAP_Attr_VoiceLin"             // Attribute for the Voice telephone line
    static let lupa_LDAP_Attr_VoiceInt      = "lupa_LDAP_Attr_VoiceInt"             // Attribute for the Voice internal telephone line
    static let lupa_LDAP_Attr_VoiceMob      = "lupa_LDAP_Attr_VoiceMob"             // Attribute for the Voice mobile telephone
    static let lupa_LDAP_Attr_HasPict       = "lupa_LDAP_Attr_HasPict"              // Attribute for the y/n value indicating if the user has a picture
    static let lupa_LDAP_Attr_Title         = "lupa_LDAP_Attr_Title"                // Attribute for the user's job title

    // Fields where ldapsarch will look for the searched content
    static let lupa_LDAP_Search_CN            = "lupa_LDAP_Search_CN"               // Include the CN as a field where we'll search in the ldapsearch
    static let lupa_LDAP_Search_Desc          = "lupa_LDAP_Search_Desc"             // Include the Description
    static let lupa_LDAP_Search_VoiceLin      = "lupa_LDAP_Search_VoiceLin"         // Include the fixed thelephone line
    static let lupa_LDAP_Search_VoiceInt      = "lupa_LDAP_Search_VoiceInt"         // Include the voice mail 
    static let lupa_LDAP_Search_VoiceMob      = "lupa_LDAP_Search_VoiceMob"         // Include the mobile
    
    static let lupa_LDAP_PictureURL         = "lupa_LDAP_PictureURL"                // Attribute for the URL pointing to the user picture
    static let lupa_LDAP_Limit_Results       = "lupa_LDAP_Limit_Results"              // Max. num of returned results

    static let keychain_BIND_Password        = "lupa_BIND_Password"

}

/// Returns the program long name, based on constans found in "AbacoVersion.swift"
/// automatically generated from custom Xcode->Project->Build Phase script, which
/// analises the GIT information and creates version information
func programLongName() -> String
{
    let myProgramLongName : String = "Lupa \(skPROGRAM_DISPLAY_VERSION)-\(ikPROGRAM_VERSION)(\(skPROGRAM_BUILD))"
    return myProgramLongName;
}

extension NSView {
    
    var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(CGColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.CGColor
        }
    }
}