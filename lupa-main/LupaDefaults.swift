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
    

    @IBAction func userChanged(sender: AnyObject) {
        self.updateUI()
    }
    @IBAction func userStoreChanged(sender: AnyObject) {
        self.updateUI()
    }
    func updateUI() {
        var bindUser = ""
        if let letLDAP_Bind_User = self.userDefaults.objectForKey(LUPADefaults.lupa_Bind_User) as? String {
            bindUser = letLDAP_Bind_User
            if let letLDAP_Bind_UserStore = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_UserStore) as? String {
                bindUser = "CN=" + bindUser + "," + letLDAP_Bind_UserStore
            }
        }
        self.bindUserID.stringValue = bindUser
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
    
    
    // CANCEL Button
    //
    @IBAction func doCancel(sender: AnyObject) {

        // Hide the window
        self.window?.orderOut(self)
    }

    // Clean up the fields
    //
    @IBAction func cleanDefaults(sender: AnyObject) {
        // Save defaults from json
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("", forKey: LUPADefaults.lupa_URLPrefix)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_BIND_UserStore)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Command)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_BaseDN)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Host)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Port)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Limit_Results)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Filter_One)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Filter_Two)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Country)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_City)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
        userDefaults.setObject("", forKey: LUPADefaults.lupa_LDAP_Attr_Title)

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
                            // Got the Dictionary on 'json'
                            // print("json: \(json)")

                            // Save defaults from json
                            let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            userDefaults.setObject(json[LUPADefaults.lupa_URLPrefix], forKey: LUPADefaults.lupa_URLPrefix)
                            userDefaults.setObject(json[LUPADefaults.lupa_BIND_UserStore], forKey: LUPADefaults.lupa_BIND_UserStore)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Command], forKey: LUPADefaults.lupa_LDAP_Command)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_BaseDN], forKey: LUPADefaults.lupa_LDAP_BaseDN)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Host], forKey: LUPADefaults.lupa_LDAP_Host)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Port], forKey: LUPADefaults.lupa_LDAP_Port)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Limit_Results], forKey: LUPADefaults.lupa_LDAP_Limit_Results)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Filter_One], forKey: LUPADefaults.lupa_LDAP_Filter_One)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Filter_Two], forKey: LUPADefaults.lupa_LDAP_Filter_Two)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Desc], forKey: LUPADefaults.lupa_LDAP_Attr_Desc)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Country], forKey: LUPADefaults.lupa_LDAP_Attr_Country)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_City], forKey: LUPADefaults.lupa_LDAP_Attr_City)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceLin], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceLin)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceInt], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceInt)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_VoiceMob], forKey: LUPADefaults.lupa_LDAP_Attr_VoiceMob)
                            userDefaults.setObject(json[LUPADefaults.lupa_LDAP_Attr_Title], forKey: LUPADefaults.lupa_LDAP_Attr_Title)
                            
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
    
    
}
