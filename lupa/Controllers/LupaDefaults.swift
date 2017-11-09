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
    @IBOutlet weak var disclosurePref: NSButton!
    @IBOutlet weak var stackViewPref: NSStackView!
    @IBOutlet weak var sslButton: NSButton!
    
    
    //  In order to work with the user defaults, stored under:
    let userDefaults : UserDefaults = UserDefaults.standard

    
    /// --------------------------------------------------------------------------------
    //  MARK: Init
    /// --------------------------------------------------------------------------------

    override func windowDidLoad() {
        super.windowDidLoad()

        self.actionDisclosureLDAP(self)
        self.actionDisclosurePref(self)

        // Set the version
        self.version.stringValue = programLongName()
        
        
        // Bind the shortcut hotkey to user defaults.
        customShortcutView.setAssociatedUserDefaultsKey(LUPADefaults.lupa_Hotkey, withTransformerName: NSValueTransformerName.keyedUnarchiveFromDataTransformerName.rawValue)
        
        // Enable or disable the view according to checkbox state
        customShortcutView.bind(NSBindingName(rawValue: "enabled"), to: userDefaults, withKeyPath: LUPADefaults.lupa_HotkeyEnabled, options: nil)
 
        // Change ssl Button color to white
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        sslButton.attributedTitle = NSAttributedString(string: "SSL", attributes: [ NSAttributedStringKey.foregroundColor : NSColor.white ])
        
        // Settle down ui
        self.updateUI()
        
        // Future ToDo - place it as a popover
        //        if let window = self.window {
        //            var point = lpStatusItem.getPositioningPoint()
        //            let width = window.frame.size.width
        //            point.x = point.x - (width/2)
        //            window.setFrameOrigin(point)
        //        }
    }

 
    /// --------------------------------------------------------------------------------
    //  MARK: User changes
    /// --------------------------------------------------------------------------------
    
    // Update UI when any field ends editing
    //
    @IBAction func fieldChanged(_ sender: AnyObject) {
        
        // Deprecated: Remove focus ring from any textfield
        // if let window = self.window {
        //     window.makeFirstResponder(self)
        // }
        
        // Update the UI
        self.updateUI()
    }
    
    // *NEW* Version will save into Keychain. NOTICE: Still not fully implemented (21/1/16@)
    //
    @IBAction func passwordChanged(_ sender: AnyObject) {

        
        // Password special case:
        let pass = self.passwdTextField.stringValue

        // Get the default LDAP Port
        var intLDAP_Port = 0
        var sslOption = false
        let userDefaults : UserDefaults = UserDefaults.standard
        if let active = userDefaults.object(forKey: LUPADefaults.lupa_LDAP_SSL) as? Bool {
            if active == true {
                sslOption = true
            }
        }
        if sslOption == true {
            intLDAP_Port = 636
        } else {
            intLDAP_Port = 389
        }
        // Set the LDAP Port from user defaults, or previous numbers otherwise
        if let letLDAP_Bind_Port = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Port) as? String {
            if let num = Int(letLDAP_Bind_Port) {
                intLDAP_Port = num
            }
        } else {
            print("WARNING, 'userDefaults' value for the ldap port was missing, so I'll use the default value")
        }

        
        if let server = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Host) as? String {
            if ( !server.isEmpty ) {
        
                if let user = self.userDefaults.object(forKey: LUPADefaults.lupa_BIND_User) as? String {
                    if ( !user.isEmpty ) {
                
                        setInternetPassword(pass, forServer: server, account: user, port: intLDAP_Port, secProtocol: SecProtocolType.LDAPS)
                        
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
            if let letLDAP_Bind_User = self.userDefaults.object(forKey: LUPADefaults.lupa_BIND_User) as? String {
                bindUser = letLDAP_Bind_User
                if ( !bindUser.isEmpty ) {
                    if let letLDAP_Bind_UserStore = self.userDefaults.object(forKey: LUPADefaults.lupa_BIND_UserStore) as? String {
                        bindUser = "CN=" + bindUser + "," + letLDAP_Bind_UserStore
                    }
                }
            }
            self.bindUserID.stringValue = bindUser
            
            // FULL URL
            var fullURL = ""
            if let letLDAP_Host = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Host) as? String {
                if ( !letLDAP_Host.isEmpty ) {
                    
                    var ldapURI = "ldap"
                    if let sslCheckboxState = userDefaults.object(forKey: LUPADefaults.lupa_LDAP_SSL) as? Bool {
                        if sslCheckboxState == true {
                            ldapURI = "ldaps"
                        }
                    }
                    
                    fullURL = ldapURI + "://" + letLDAP_Host
                    if let letLDAP_Port = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Port) as? String {
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
    @IBAction func ok(_ sender: AnyObject) {
        
        // Hide the window
        self.window?.orderOut(self)
    }
    
    
    // Clean up the fields
    //
    @IBAction func cleanDefaults(_ sender: AnyObject) {
        
        
        // Clean the Password
        if let server = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Host) as? String {
            if ( !server.isEmpty ) {
                if let sPort = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Port) as? String {
                    var port = 389
                    if let num = Int(sPort) {
                        port = num
                    }
                    if let user = self.userDefaults.object(forKey: LUPADefaults.lupa_BIND_User) as? String {
                        if ( !user.isEmpty ) {
                            setInternetPassword("", forServer: server, account: user, port: port, secProtocol: SecProtocolType.LDAPS)
                        }
                    }
                }
            }
        }

        // Clean everything else...
        let userDefaults : UserDefaults = UserDefaults.standard
        userDefaults.set("", forKey: LUPADefaults.lupa_BIND_User)
        userDefaults.set("", forKey: LUPADefaults.lupa_URLPrefix)
        userDefaults.set("", forKey: LUPADefaults.lupa_BIND_UserStore)
        userDefaults.set(false, forKey: LUPADefaults.lupa_LDAP_Support)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Command)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_BaseDN)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Host)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Port)
        userDefaults.set(false, forKey: LUPADefaults.lupa_LDAP_Port)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Timeout)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Limit_Results)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_CN)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_Country)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_City)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Attr_Title)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_PictureURLMini)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_PictureURLZoom)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Search_CN)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Search_Desc)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceLin)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceInt)
        userDefaults.set("", forKey: LUPADefaults.lupa_LDAP_Search_VoiceMob)
        
        // The following attribute has been *DEPRECATED*
        userDefaults.removeObject(forKey: LUPADefaults.lupa_BIND_Password)

        self.updateUI()
    }

    // Import from jSON
    //
    enum JSONError: String, Error {
        case ConversionToDictionaryFailed = "JSONError: source is not a json with a Dictionary"
    }
    @IBAction func importFromJSON(_ sender: AnyObject) {
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.prompt = "Open JSON file"
        openPanel.resolvesAliases = true
        openPanel.allowedFileTypes = ["json", "JSON"]
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
                if let fileURL = openPanel.url {
                    do {
                        if let jsonData = try? Data(contentsOf: fileURL) {
                            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [AnyHashable: Any] else {
                                throw JSONError.ConversionToDictionaryFailed
                            }
                            // Save defaults from data received from json file
                            let userDefaults : UserDefaults = UserDefaults.standard
                            userDefaults.set(json[LUPADefaults.lupa_URLPrefix], forKey: LUPADefaults.lupa_URLPrefix)
                            userDefaults.set(json[LUPADefaults.lupa_BIND_UserStore], forKey: LUPADefaults.lupa_BIND_UserStore)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Command], forKey: LUPADefaults.lupa_LDAP_Command)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_BaseDN], forKey: LUPADefaults.lupa_LDAP_BaseDN)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Host], forKey: LUPADefaults.lupa_LDAP_Host)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Port], forKey: LUPADefaults.lupa_LDAP_Port)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_SSL], forKey: LUPADefaults.lupa_LDAP_SSL)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Timeout], forKey: LUPADefaults.lupa_LDAP_Timeout)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Limit_Results], forKey: LUPADefaults.lupa_LDAP_Limit_Results)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_CN], forKey: LUPADefaults.lupa_LDAP_Attr_CN)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_Desc], forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_Country], forKey: LUPADefaults.lupa_LDAP_Attr_Country)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_City], forKey: LUPADefaults.lupa_LDAP_Attr_City)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_VoiceLin], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_VoiceInt], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_VoiceMob], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Attr_Title], forKey: LUPADefaults.lupa_LDAP_Attr_Title)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_PictureURLMini], forKey: LUPADefaults.lupa_LDAP_PictureURLMini)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_PictureURLZoom], forKey: LUPADefaults.lupa_LDAP_PictureURLZoom)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Search_CN], forKey: LUPADefaults.lupa_LDAP_Search_CN)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Search_Desc], forKey: LUPADefaults.lupa_LDAP_Search_Desc)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Search_VoiceLin], forKey: LUPADefaults.lupa_LDAP_Search_VoiceLin)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Search_VoiceInt], forKey: LUPADefaults.lupa_LDAP_Search_VoiceInt)
                            userDefaults.set(json[LUPADefaults.lupa_LDAP_Search_VoiceMob], forKey: LUPADefaults.lupa_LDAP_Search_VoiceMob)
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
    
    
    @IBAction func exportFromJSON(_ sender: AnyObject) {
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = false
        savePanel.prompt = "Save to JSON file"
        savePanel.allowedFileTypes = ["json", "JSON"]
        savePanel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
                if let fileURL = savePanel.url {
                    do {
                        let json : [String:AnyObject] = [
                            LUPADefaults.lupa_URLPrefix : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_URLPrefix) as AnyObject,
                            LUPADefaults.lupa_BIND_UserStore : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_BIND_UserStore) as AnyObject,
                            LUPADefaults.lupa_LDAP_Command : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Command) as AnyObject,
                            LUPADefaults.lupa_LDAP_BaseDN : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_BaseDN) as AnyObject,
                            LUPADefaults.lupa_LDAP_Host : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Host) as AnyObject,
                            LUPADefaults.lupa_LDAP_Port : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Port) as AnyObject,
                            LUPADefaults.lupa_LDAP_SSL : self.LUPADefaultsValueForKeyAsBool(LUPADefaults.lupa_LDAP_SSL) as AnyObject,
                            LUPADefaults.lupa_LDAP_Timeout : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Timeout) as AnyObject,
                            LUPADefaults.lupa_LDAP_Limit_Results : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Limit_Results) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_CN : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_CN) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_Desc : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_Desc) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_Country : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_Country) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_City : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_City) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_VoiceLin : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_VoiceLin) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_VoiceInt : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_VoiceInt) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_VoiceMob : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_VoiceMob) as AnyObject,
                            LUPADefaults.lupa_LDAP_Attr_Title : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Attr_Title) as AnyObject,
                            LUPADefaults.lupa_LDAP_PictureURLMini : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_PictureURLMini) as AnyObject,
                            LUPADefaults.lupa_LDAP_PictureURLZoom : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_PictureURLZoom) as AnyObject,
                            LUPADefaults.lupa_LDAP_Search_CN : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Search_CN) as AnyObject,
                            LUPADefaults.lupa_LDAP_Search_Desc : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Search_Desc) as AnyObject,
                            LUPADefaults.lupa_LDAP_Search_VoiceLin : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Search_VoiceLin) as AnyObject,
                            LUPADefaults.lupa_LDAP_Search_VoiceInt : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Search_VoiceInt) as AnyObject,
                            LUPADefaults.lupa_LDAP_Search_VoiceMob : self.LUPADefaultsValueForKeyAsString(LUPADefaults.lupa_LDAP_Search_VoiceMob) as AnyObject
                        ]

                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let success = (try? jsonData.write(to: fileURL, options: [.atomic])) != nil
                        guard success == true else {
                            throw JSONError.ConversionToDictionaryFailed
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
    func LUPADefaultsValueForKeyAsString(_ key: String) -> String {
        var value = ""
        let userDefaults : UserDefaults = UserDefaults.standard
        if let hasValue = userDefaults.object(forKey: key) as? String {
            value = hasValue
        }
        return value
    }
    func LUPADefaultsValueForKeyAsBool(_ key: String) -> Bool {
        var value = false
        let userDefaults : UserDefaults = UserDefaults.standard
        if let hasValue = userDefaults.object(forKey: key) as? Bool {
            value = hasValue
        }
        return value
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
        guard let letLDAP_Host = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Host) as? String else {
            return ""
        }
        var letLDAP_Port = ""
        if let letLDAP_Bind_Port = self.userDefaults.object(forKey: LUPADefaults.lupa_LDAP_Port) as? String {
            letLDAP_Port = letLDAP_Bind_Port
        }
        var intLDAP_Port = 0
        if let num = Int(letLDAP_Port) {
            intLDAP_Port = num
        }
        if let user = self.userDefaults.object(forKey: LUPADefaults.lupa_BIND_User) as? String {
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
    
    @IBAction func actionDisclosureLDAP(_ sender: AnyObject) {
        if self.disclosureLDAP.state == NSControl.StateValue.on {
            // ON
            self.stackViewLDAP.isHidden = false
        } else {
            // OFF
            self.stackViewLDAP.isHidden = true
        }

    }

    @IBAction func actionDisclosurePref(_ sender: AnyObject) {
        if self.disclosurePref.state == NSControl.StateValue.on {
            // ON
            self.stackViewPref.isHidden = false
        } else {
            // OFF
            self.stackViewPref.isHidden = true
        }
    }
    
    @IBAction func actionSSLOnOff(_ sender: AnyObject) {
        if self.sslButton.state == NSControl.StateValue.on {
            userDefaults.set("636", forKey: LUPADefaults.lupa_LDAP_Port)
        } else {
            userDefaults.set("389", forKey: LUPADefaults.lupa_LDAP_Port)
        }
        // Update the UI
        self.updateUI()
    }

}






















