//
//  LupaDefaults.swift
//  lupa
//
//  Created by Luis Palacios on 11/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaDefaults: NSWindowController, NSTextViewDelegate {

    // --------------------------------------------------------------------------------
    // MARK: Attributes
    // --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!)
    //  they are optionals and no need to initialize them here, will do later.


    @IBOutlet weak var searchSeparator: NSTextField!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var customShortcutView: MASShortcutView!
    @IBOutlet weak var bindUserID: NSTextField!
    @IBOutlet weak var fullURL: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var passwdTextField: NSSecureTextField!
    
    // Dynamic resizing
    @IBOutlet weak var disclosureLDAP: NSButton!
    @IBOutlet weak var stackViewLDAP: NSStackView!
    @IBOutlet weak var stackViewHeightLDAP: NSLayoutConstraint!
    
    
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

        var intLDAP_Port = 636
        if let letLDAP_Bind_Port = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Port) as? String {
            if let num = Int(letLDAP_Bind_Port) {
                intLDAP_Port = num
            }
        } else {
            print("WARNING, port empty or invalid, I'll use port number 636")
        }

        
        if let server = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String {
            if ( !server.isEmpty ) {
        
                if let user = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_User) as? String {
                    if ( !user.isEmpty ) {
                
                        setInternetPassword(pass, forServer: server, account: user, port: intLDAP_Port, secProtocol: SecProtocolType.LDAPS)
                    
                        // Log to touble check it was correctly saved
                        //
                        // if let thePassword = internetPasswordForServer(server, account: user, port: intLDAP_Port, secProtocol: SecProtocolType.LDAPS) {
                        //     print("Password in keychain = '\(thePassword)'")
                        // } else {
                        //     print("Password in keychain is EMPTY")
                        // }

                    
                    } else {
                        print("ERROR: User field is empty")
                    }
                } else {
                    print("ERROR: user field doesn't exist")
                }
            } else {
                print("ERROR: server field is empty")
            }
        } else {
            print("ERROR, server field doesn't exist")
        }
        
        // Update the UI
        self.updateUI()
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: UI
    /// --------------------------------------------------------------------------------
    
    
    // Update UI components that need same kind of intelligence
    //
    func updateUI() {
        
        // PASSWORD
        if ( self.passwdTextField != nil ) {
            
            self.passwdTextField.stringValue = self.getCurrentPassword()
            
            
            // FULL BIND USER
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
            
            // FULL URL
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
        
        
        // Clean the Password
        if let server = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String {
            if ( !server.isEmpty ) {
                if let sPort = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Port) as? String {
                    var port = 636
                    if let num = Int(sPort) {
                        port = num
                    }
                    if let user = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_User) as? String {
                        if ( !user.isEmpty ) {
                            setInternetPassword("", forServer: server, account: user, port: port, secProtocol: SecProtocolType.LDAPS)
                        }
                    }
                }
            }
        }

        // Clean everything else...
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("", forKey: LUPADefaults.lupa_BIND_User)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_URLPrefix)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_BIND_UserStore)
        userDefaults.setBool(false, forKey: LUPADefaults.lupa_LDAP_Support)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Command)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_BaseDN)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Host)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Port)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Timeout)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Limit_Results)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_CN)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Country)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_City)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Title)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_PictureURLMini)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_PictureURLZoom)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_CN)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_Desc)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceLin)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceInt)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceMob)
        
        // The following attribute has been *DEPRECATED*
        userDefaults.removeObjectForKey(LUPADefaults.lupa_BIND_Password)

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
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Timeout], forKey: LUPADefaults.lupa_LDAP_Timeout)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Limit_Results], forKey: LUPADefaults.lupa_LDAP_Limit_Results)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_CN], forKey: LUPADefaults.lupa_LDAP_Attr_CN)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Desc], forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Country], forKey: LUPADefaults.lupa_LDAP_Attr_Country)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_City], forKey: LUPADefaults.lupa_LDAP_Attr_City)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceLin], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceInt], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceMob], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Title], forKey: LUPADefaults.lupa_LDAP_Attr_Title)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_PictureURLMini], forKey: LUPADefaults.lupa_LDAP_PictureURLMini)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_PictureURLZoom], forKey: LUPADefaults.lupa_LDAP_PictureURLZoom)
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
    // MARK: Password
    // --------------------------------------------------------------------------------
    

    // Get current password from the Keychain
    //
    func getCurrentPassword() -> String {
        var password = ""
        // Get current password
        //
        guard let letLDAP_Host = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String else {
            return ""
        }
        var letLDAP_Port = ""
        if let letLDAP_Bind_Port = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Port) as? String {
            letLDAP_Port = letLDAP_Bind_Port
        }
        var intLDAP_Port = 0
        if let num = Int(letLDAP_Port) {
            intLDAP_Port = num
        }
        if let user = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_User) as? String {
            if !user.isEmpty {
                guard let pass = internetPasswordForServer(letLDAP_Host, account: user, port: intLDAP_Port, secProtocol: SecProtocolType.LDAPS) else {
                    return ""
                }
                password = pass
            }
        }
        return password
    }
    
    
    // --------------------------------------------------------------------------------
    // MARK: Resizings
    // --------------------------------------------------------------------------------
    
    @IBAction func actionDisclosureDAP(sender: AnyObject) {
        print("PipPop")
        if self.disclosureLDAP.state == NSOnState {
            
            // ON
            self.stackViewLDAP.hidden = false
//            self.stackViewHeightLDAP.constant = 468
            
            
        } else {
            
            // OFF
            self.stackViewLDAP.hidden = true
//            self.stackViewHeightLDAP.constant = 0
            
        }
        
    }
    

}






















