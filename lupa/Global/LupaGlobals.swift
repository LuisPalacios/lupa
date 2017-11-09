//
//  LupaGlobals.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 3/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Foundation
import AppKit



///  Application Contstants
///
struct Constants {
    
    struct SearchCtrl {
        static let SearchCellViewID = "LupaSearchCellView"
    }
    
}

///  Application preferences are stored under:
///
///  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
///
///  To check this content from command line:
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
    static let lupa_HotkeyEnabled           = "lupa_HotkeyEnabled"                  // Bool dictates the usage of keyboard hotkey to launch the search

    static let lupa_LDAP_Support            = "lupa_LDAP_Support"                   // Bool Enable ldapsearch support
    static let lupa_LDAP_Timeout            = "lupa_LDAP_Timeout"                   // Timeout before terminating current ldapsearch command
    static let lupa_BIND_User               = "lupa_BIND_User"                      // ldapsearch -D  CN=<lupa_BIND_User>, <lupa_BIND_UserStore>
    static let lupa_BIND_UserStore          = "lupa_BIND_UserStore"                 // ldapsearch -D  CN=<lupa_BIND_User>, <lupa_BIND_UserStore>
    static let lupa_LDAP_Command            = "lupa_LDAP_Command"                   // ldapsearch -x
    static let lupa_LDAP_BaseDN             = "lupa_LDAP_BaseDN"                    // -b ou=employees,o=company.com
    static let lupa_LDAP_Host               = "lupa_LDAP_Host"                      // -H ldap[s]://ldap.company.com
    static let lupa_LDAP_Port               = "lupa_LDAP_Port"                      // port
    static let lupa_LDAP_SSL                = "lupa_LDAP_SSL"                       // true=ldaps://  false=ldap://

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
    
    static let lupa_LDAP_PictureURLMini      = "lupa_LDAP_PictureURLMini"           // Attribute for the URL pointing to the user picture (small form factor)
    static let lupa_LDAP_PictureURLZoom      = "lupa_LDAP_PictureURLZoom"           // Attribute for the URL pointing to the user picture (zoomed form factor)
    static let lupa_LDAP_Limit_Results       = "lupa_LDAP_Limit_Results"            // Max. num of returned results

    
    // The following attribute has been *DEPRECATED*
    static let lupa_BIND_Password           = "lupa_BIND_Password"                  // ldapsearch -w

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
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}




// --------------------------------------------------------------------------------
//  MARK: Keychain for the Password
// --------------------------------------------------------------------------------
//
// Notice this is my own implementation, but much better framwork here:
//  https://github.com/kishikawakatsumi/KeychainAccess
//

private let Class = String(kSecClass)
private let AttributeAccount = String(kSecAttrAccount)


// Save the Password
//
func setInternetPassword(_ password: String, forServer server: String, account: String, port: Int, secProtocol: SecProtocolType ) {
    let password_ns: NSString = password as NSString
    let server_ns: NSString = server as NSString
    let account_ns: NSString = account as NSString
    
    // Attributes to store the oldPassword, if any
    //
    var oldPasswordPtrLength: UInt32 = 0
    var oldPasswordPtr: UnsafeMutableRawPointer? = nil
    var itemRef : SecKeychainItem? = nil
    
    // First check whether there is already one in the keychain
    //
    let err : OSStatus = SecKeychainFindInternetPassword(
        nil,
        UInt32(server_ns.length), server_ns.utf8String,
        0, nil, /* security domain */
        UInt32(account_ns.length), account_ns.utf8String,
        0, nil, /* path */
        UInt16(port), /* port */
        secProtocol,
        SecAuthenticationType.default,
        &oldPasswordPtrLength, &oldPasswordPtr,
        &itemRef) /* itemRef */
    
    //
    //
    let passwordLength = password.lengthOfBytes(using: String.Encoding.utf8)
    if ( passwordLength > 0 ) {
        
        // Create the new password
        //
        if ( err != 0 ) {
            let addStatus = SecKeychainAddInternetPassword(
                nil, /* default keychain */
                UInt32(server_ns.length), server_ns.utf8String,
                0, nil, /* security domain */
                UInt32(account_ns.length), account_ns.utf8String,
                0, nil, /* path */
                UInt16(port), /* port */
                secProtocol,
                SecAuthenticationType.default,
                UInt32(password_ns.length), password_ns.utf8String!,
                nil)
            
            if addStatus != errSecSuccess {
                // print("Could not save password.")
                let msg = SecCopyErrorMessageString(addStatus, nil)
//                print("\(msg)")
//
                print("\(String(describing: msg))")

            } else {
                // print("Added new Password: \(password)")
            }
            
        } else {
            // Otherwise, modify existing, if different
            //
            var oldPassword = ""
            if let str = NSString(bytes: oldPasswordPtr!, length: Int(oldPasswordPtrLength), encoding: String.Encoding.utf8.rawValue) as String? {
                oldPassword = str
            }
            if ( password != oldPassword ) {
                if let passRef = itemRef  {
                    SecKeychainItemModifyContent(passRef, nil, UInt32(password_ns.length), password_ns.utf8String)
                    // print("Changed Password, old: \(oldPassword)  new: \(password)")
                }
            }
        }
    } else {
        if ( err == 0 ) {
            
            // Asked to removed the password, let's go for it...
            //
            if let passRef = itemRef  {
                SecKeychainItemDelete(passRef)
                // print("Removed Password")
                // The following is not needed under Swift 2.1
                // CFRelease(passRef)
            }
        }
    }
}


// Read the Password
//
func internetPasswordForServer(_ server: String, account: String, port: Int, secProtocol: SecProtocolType) -> String? {
    
    var passwordLength: UInt32 = 0
    var passwordData: UnsafeMutableRawPointer? = nil
    
    let server_ns: NSString = server as NSString
    let account_ns: NSString = account as NSString
    
    let status = SecKeychainFindInternetPassword(nil,
        UInt32(server_ns.length), server_ns.utf8String,
        0, nil, /* security domain */
        UInt32(account_ns.length), account_ns.utf8String,
        0, nil, /* path */
        UInt16(port), /* port */
        secProtocol,
        SecAuthenticationType.default,
        &passwordLength, &passwordData,
        nil) /* itemRef */
    
    if status != errSecSuccess {
        // print("server: \(server). account: \(account). port: \(port). secProtocol: \(secProtocol) ==> Could not find password.")
        return nil
    }
    
    var password = ""
    if let str = NSString(bytes: passwordData!, length: Int(passwordLength), encoding: String.Encoding.utf8.rawValue) as String? {
        SecKeychainItemFreeContent(nil, passwordData);
        password = str
    }
    // print("Found Password: \(password)")
    
    return password
}
