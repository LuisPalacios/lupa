//
//  LupaDefaults.swift
//  lupa
//
//  Created by Luis Palacios on 11/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaDefaults: NSWindowController, NSTextViewDelegate {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!)
    //  they are optionals and no need to initialize them here, will do later.


    @IBOutlet weak var searchSeparator: NSTextField!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var customShortcutView: MASShortcutView!
    @IBOutlet weak var bindUserID: NSTextField!
    @IBOutlet weak var fullURL: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var passwdTextField: NSSecureTextField!
    
    //  In order to work with the user defaults, stored under:
    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()

    
    /// --------------------------------------------------------------------------------
    //  MARK: Init
    /// --------------------------------------------------------------------------------

    override func windowDidLoad() {
        super.windowDidLoad()

        // Set the version
        self.version.stringValue = programLongName()
        
        
        // Bind the shortcut hotkey to user defaults.
        customShortcutView.setAssociatedUserDefaultsKey(LUPADefaults.lupa_Hotkey, withTransformerName: NSKeyedUnarchiveFromDataTransformerName)
        
        // Enable or disable the view according to checkbox state
        customShortcutView.bind("enabled", toObject: userDefaults, withKeyPath: LUPADefaults.lupa_HotkeyEnabled, options: nil)
 
        //
        self.updateUI()
    }

    /// --------------------------------------------------------------------------------
    //  MARK: User changes
    /// --------------------------------------------------------------------------------
    
    // Update UI when any field ends editing
    //
    @IBAction func fieldChanged(sender: AnyObject) {
        
        // Deprecated: Remove focus ring from any textfield
        // if let window = self.window {
        //     window.makeFirstResponder(self)
        // }
        
        // Update the UI
        self.updateUI()
    }
    
    // *NEW* Version will save into Keychain. NOTICE: Still not fully implemented (21/1/16@)
    //
    @IBAction func passwordChanged(sender: AnyObject) {
        
        // Password special case:
        let pass = self.passwdTextField.stringValue

        if let server = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String {
            if ( !server.isEmpty ) {
        
                if let user = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_User) as? String {
                    if ( !user.isEmpty ) {
                
                    
                        
                        
                        //self.setKeychainPassword(pass, forServer: server, withUsername: user)
                    
                        // Asking for a password set (or change)
                        self.setInternetPassword(pass, forServer: server, account: user, port: 0, secProtocol: SecProtocolType.LDAPS)
                    
                    } else {
                        print("ERROR: El campo usuario está vacío")
                    }
                } else {
                    print("ERROR: El campo usuario no existe...")
                }
            }
        } else {
            print("ERROR, por favor pon antes el HOST !!!! ")
        }

        
        if let server = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String {
            if ( !server.isEmpty ) {
                if let user = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_User) as? String {
                    if ( !user.isEmpty ) {

                        if let thePassword = self.internetPasswordForServer(server, account: user, port: 0, secProtocol: SecProtocolType.LDAPS) {
                            print("Password in keychain = '\(thePassword)'")
                        } else {
                            print("Password in keychain is EMPTY")
                        }

                    } else {
                        print("ERROR: El campo usuario está vacío")
                    }
                } else {
                    print("ERROR: El campo usuario no existe...")
                }
            } else {
                print("ERROR: El campo server está vacío...")
            }
        } else {
            print("ERROR, por favor pon antes el HOST !!!! ")
        }
        
        // Update the UI
        self.updateUI()
    }
    
    
    // Update UI components that need same kind of intelligence
    //
    func updateUI() {
        var bindUser = ""
        if let letLDAP_Bind_User = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_User) as? String {
            bindUser = letLDAP_Bind_User
            if ( !bindUser.isEmpty ) {
                if let letLDAP_Bind_UserStore = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_UserStore) as? String {
                    bindUser = "CN=" + bindUser + "," + letLDAP_Bind_UserStore
                }
            }
        }
        self.bindUserID.stringValue = bindUser
        
        var fullURL = ""
        if let letLDAP_Host = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String {
            if ( !letLDAP_Host.isEmpty ) {                
                fullURL = "ldaps://" + letLDAP_Host
                if let letLDAP_Port = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Port) as? String {
                    fullURL = fullURL + ":" + letLDAP_Port
                }
            }
        }
        self.fullURL.stringValue = fullURL

        // Remove the focus ring from where it's now and 
        // pass it to the OK button (activates with space)
        if let window = self.window {
            window.makeFirstResponder(self.okButton)
        }
    }

    /// --------------------------------------------------------------------------------
    //  MARK: Actions
    /// --------------------------------------------------------------------------------
    
    // OK Button
    //
    @IBAction func ok(sender: AnyObject) {
        
        // Hide the window
        self.window?.orderOut(self)
    }
    
    
    // Clean up the fields
    //
    @IBAction func cleanDefaults(sender: AnyObject) {
        // Save defaults from json
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject("", forKey: LUPADefaults.lupa_BIND_User)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_BIND_Password)

        userDefaults.setObject("", forKey: LUPADefaults.lupa_URLPrefix)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_BIND_UserStore)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Command)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_BaseDN)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Host)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Port)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Limit_Results)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_CN)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Country)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_City)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Title)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_PictureURL)

        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_CN)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_Desc)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceLin)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceInt)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceMob)

        self.updateUI()
    }

    // Import from jSON
    //
    enum JSONError: String, ErrorType {
        case ConversionToDictionaryFailed = "JSONError: source is not a json with a Dictionary"
    }
    @IBAction func importFromJSON(sender: AnyObject) {
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.prompt = "Open JSON file"
        openPanel.resolvesAliases = true
        openPanel.allowedFileTypes = ["json", "JSON"]
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
                if let fileURL = openPanel.URL {
                    do {
                        if let jsonData = NSData(contentsOfURL: fileURL) {
                            guard let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [NSObject:AnyObject] else {
                                throw JSONError.ConversionToDictionaryFailed
                            }
                            // Save defaults from data received from json file
                            let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            userDefaults.setObject(json[LUPADefaults.lupa_URLPrefix], forKey: LUPADefaults.lupa_URLPrefix)
                            userDefaults.setObject(json[LUPADefaults.lupa_BIND_UserStore], forKey: LUPADefaults.lupa_BIND_UserStore)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Command], forKey: LUPADefaults.lupa_LDAP_Command)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_BaseDN], forKey: LUPADefaults.lupa_LDAP_BaseDN)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Host], forKey: LUPADefaults.lupa_LDAP_Host)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Port], forKey: LUPADefaults.lupa_LDAP_Port)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Limit_Results], forKey: LUPADefaults.lupa_LDAP_Limit_Results)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_CN], forKey: LUPADefaults.lupa_LDAP_Attr_CN)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Desc], forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Country], forKey: LUPADefaults.lupa_LDAP_Attr_Country)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_City], forKey: LUPADefaults.lupa_LDAP_Attr_City)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceLin], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceInt], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceMob], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Title], forKey: LUPADefaults.lupa_LDAP_Attr_Title)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_PictureURL], forKey: LUPADefaults.lupa_LDAP_PictureURL)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Search_CN], forKey: LUPADefaults.lupa_LDAP_Search_CN)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Search_Desc], forKey: LUPADefaults.lupa_LDAP_Search_Desc)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Search_VoiceLin], forKey: LUPADefaults.lupa_LDAP_Search_VoiceLin)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Search_VoiceInt], forKey: LUPADefaults.lupa_LDAP_Search_VoiceInt)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Search_VoiceMob], forKey: LUPADefaults.lupa_LDAP_Search_VoiceMob)
                            self.updateUI()
                        }
                    } catch let error as JSONError {
                        print("ERROR: \(error.rawValue)")
                    } catch let error as NSError {
                        print("ERROR: \(error.localizedDescription)")
                    }
                }
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
    func setInternetPassword(password: String, forServer server: String, account: String, port: Int, secProtocol: SecProtocolType ) {
        let password_ns: NSString = password
        let server_ns: NSString = server
        let account_ns: NSString = account

        // Attributes to store the oldPassword, if any
        //
        var oldPasswordPtrLength: UInt32 = 0
        var oldPasswordPtr: UnsafeMutablePointer<Void> = nil
        var itemRef : SecKeychainItemRef? = nil
        
        // First check whether there is already one in the keychain
        //
        let err : OSStatus = SecKeychainFindInternetPassword(
            nil,
            UInt32(server_ns.length), server_ns.UTF8String,
            0, nil, /* security domain */
            UInt32(account_ns.length), account_ns.UTF8String,
            0, nil, /* path */
            UInt16(port), /* port */
            secProtocol,
            SecAuthenticationType.Default,
            &oldPasswordPtrLength, &oldPasswordPtr,
            &itemRef) /* itemRef */

        //
        //
        let passwordLength = password.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if ( passwordLength > 0 ) {
            
            // Create the new password
            //
            if ( err != 0 ) {
                let addStatus = SecKeychainAddInternetPassword(
                    nil, /* default keychain */
                    UInt32(server_ns.length), server_ns.UTF8String,
                    0, nil, /* security domain */
                    UInt32(account_ns.length), account_ns.UTF8String,
                    0, nil, /* path */
                    UInt16(port), /* port */
                    secProtocol,
                    SecAuthenticationType.Default,
                    UInt32(password_ns.length), password_ns.UTF8String,
                    nil)
                
                if addStatus != errSecSuccess {
                    // print("Could not save password.")
                    let msg = SecCopyErrorMessageString(addStatus, nil)
                    print("\(msg)")
                } else {
                    // print("Added new Password: \(password)")
                }

            } else {
                // Otherwise, modify existing, if different
                //
                var oldPassword = ""
                if let str = NSString(bytes: oldPasswordPtr, length: Int(oldPasswordPtrLength), encoding: NSUTF8StringEncoding) as? String {
                    oldPassword = str
                }
                if ( password != oldPassword ) {
                    if let passRef = itemRef  {
                        SecKeychainItemModifyContent(passRef, nil, UInt32(password_ns.length), password_ns.UTF8String)
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
    func internetPasswordForServer(server: String, account: String, port: Int, secProtocol: SecProtocolType) -> String? {
        var passwordLength: UInt32 = 0
        var passwordData: UnsafeMutablePointer<Void> = nil
        
        let server_ns: NSString = server
        let account_ns: NSString = account
        
        let status = SecKeychainFindInternetPassword(nil,
            UInt32(server_ns.length), server_ns.UTF8String,
            0, nil, /* security domain */
            UInt32(account_ns.length), account_ns.UTF8String,
            0, nil, /* path */
            UInt16(port), /* port */
            secProtocol,
            SecAuthenticationType.Default,
            &passwordLength, &passwordData,
            nil) /* itemRef */
        
        if status != errSecSuccess {
            // print("Could not find password.")
            return nil
        }
        
        var password = ""
        if let str = NSString(bytes: passwordData, length: Int(passwordLength), encoding: NSUTF8StringEncoding) as? String {
            SecKeychainItemFreeContent(nil, passwordData);
            password = str
        }
        // print("Found Password: \(password)")

        return password
    }

    
}






















