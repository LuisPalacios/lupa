//
//  LupaSearchWinCtrl.swift
//  lupa
//
//  Created by Luis Palacios on 20/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa
import Foundation

let ikWINDOW_MIN_HEIGHT : CGFloat = 77.0

class LupaSearchWinCtrl: NSWindowController, NSWindowDelegate, NSSearchFieldDelegate { // , NSSearchFieldDelegate {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    @IBOutlet weak var searchField: LupaSearchField!
    @IBOutlet weak var searchFieldCell: NSSearchFieldCell!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var spinningLDAP: NSProgressIndicator!
        
    
    //  Placeholder for the ldap searches, which is also observed for changes
    dynamic var ldapSearchResults = ""
    var observableKeys_LDAPSearchResults = [ "self.ldapSearchFinished" ]
    dynamic var ldapSearchFinished : Bool = false
    dynamic var users = [LPLdapUser]()
    dynamic var tmpUsers = [LPLdapUser]()

    //  In order to work with the user defaults, stored under:
    //  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
    //  $ defaults read parchis.org.lupa.plist
    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    //  Vars that I need to be initialized
    var textDidChangeInterval : NSTimeInterval = 0.0    //!< Time interval to calculate text did change trigger action
    var previousSearchString : String = ""              //!< Control if I'm asked to search the same string as before
    var timerTextDidChange    : NSTimer!                //!< Timer that triggers action after text did change
    var browserSearchIsRunning : Bool = false
    var ldapSearchIsRunning : Bool = false
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    /// Sent after the window owned by the receiver has been loaded.
    ///
    override func windowDidLoad() {
        super.windowDidLoad()

        // Setup the window class
        if let letMyWindow = self.window {
            let myWindow = letMyWindow
            myWindow.opaque = false
            myWindow.hasShadow = true
            myWindow.backgroundColor = NSColor.clearColor()
        }
        
        //
        self.loadKVO()
        
        // Work in Progress
        //
        //WiP
        //
        // Lo ideal sería hacer lo anterior en la clase LPStatusItemWindowCtrl.
        // durante su inicalización y recibir esta nswindow, que le cambiase la 
        // clase de su contentview a LPStatusitembacgroundview
        // pero sin tocarle absolutamente nada más... :-)
        //        // Show the Window fading in...
        //        let window : LPStatusItemWindow = self.window as! LPStatusItemWindow

        // Resize my window
        if let letMyWindow = self.window {
            let myWindow = letMyWindow
            let frame = myWindow.frame
            var newSize = frame.size
            newSize.height = ikWINDOW_MIN_HEIGHT
            myWindow.setContentSize(newSize)  // Only available under 10.10
        }
        
        // Subscribe myself so I'll receive(Get) Notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleWindowDidBecomeActiveNotification:",
            name: NSWindowDidBecomeKeyNotification,
            object: nil)

        
    }
    
    /// awakeFromNib()
    //
    //  Prepares the receiver for service after it has been loaded from
    //  an Interface Builder archive, or nib file. It is guaranteed to 
    //  have all its outlet instance variables set.
    //
    override func awakeFromNib() {
        // print("awakeFromNib()")
        
        // Tell the searchField I'm his delegate
        // self.searchField.delegate = self

        // Follow search string modifications
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("doSearch:"), name: NSControlTextDidChangeNotification, object: self.searchField)

        // Remove the "cancel button" from the Search Field
        // so I keep the focus on the search field "always"
        self.searchFieldCell.cancelButtonCell = nil
        
    }
    
    
    //  What to do when the Window is shown, well... select the whole nssearchfield :)
    //  so the user can start typing a new search text (deleting the old one)
    //
    func handleWindowDidBecomeActiveNotification (note : NSNotification) {
        self.searchField.selectText(self)
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: Actions when user modifies searchField or presses Enter
    /// --------------------------------------------------------------------------------
    
    // Bound to the NSSearchField. Called every time the search field content is modified.
    //
    @IBAction func searchFieldModified(sender: AnyObject) {
        self.textDidChangeInterval = 0.0
        self.startTimerTextDidChange()
    }
    
    // Handle ESCAPE Key when focus is on an object differnt to the NSSearchField
    //
    override func cancelOperation(sender: AnyObject?) {
        // Close the Window
        lpStatusItem.dismissStatusItemWindow()
    }
    
    
    // Bound thanks to NSSearchFieldDelegate
    //
    // From IB connect NSSearchField with File's Owner->Delegate
    //
    func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {

        // If I return false then the default will happen, 
        // searchFieldModified() will be called
        var retValue : Bool = false //
        
        switch commandSelector {
        case "insertNewline:":
            // BROWSER Search -
            //
            self.startBrowserSearch()

            // retval = true causes Apple to NOT fire the default enter action
            // so if true, searchFieldModified() will NOT be called
            retValue = true
    
        case "cancelOperation:":
            // Handle ESCAPE Key when pressed from the NSSearchField
            //
            lpStatusItem.dismissStatusItemWindow()

            // retval = true causes Apple to NOT fire the default enter action
            // so if true, searchFieldModified() will NOT be called
            retValue = true
            
        default:
            //Swift.print("Llegó otro comando y lo ignoro: \(commandSelector)")
            break
        }

        // Return
        return retValue
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: Browser search
    /// --------------------------------------------------------------------------------

    // Call default browser with full URL from the prefix + search_field
    //
    func startBrowserSearch() {
        
        //print("startBrowserSearch()")

        // Cancel the automated LDAP search if pending...
        self.stopTimerTextDidChange()
        
        // Read userDefaults (String) and convert into NSURL
        if let letURLString = self.userDefaults.objectForKey(LUPADefaults.lupa_URLPrefix) as? String {
            // print("lupa_URLPrefix: \(letURLString)")
            
            if !letURLString.isEmpty {
                
                if !searchField.stringValue.isEmpty {
                    var searchString : String = searchField.stringValue
                    
                    if let letSearchSeparatorEnabled = self.userDefaults.objectForKey(LUPADefaults.lupa_SearchSeparatorEnabled) as? Bool {
                        let searchSeparatorEnabled = letSearchSeparatorEnabled
                        if ( searchSeparatorEnabled ) {
                            if let letSearchSeparator = self.userDefaults.objectForKey(LUPADefaults.lupa_SearchSeparator) as? String {
                                let searchSeparator = letSearchSeparator
                                searchString = searchField.stringValue.stringByReplacingOccurrencesOfString(" ", withString: searchSeparator, options: NSStringCompareOptions.LiteralSearch, range: nil)
                            }
                        }
                    }
                    
                    // Setup the final string
                    let searchURLString : String = letURLString + searchString
                    // print("searchURLString: \(searchURLString)")
                    
                    // Let's go rock and roll
                    //
                    // Note: I'm leaving here a way to activate a "Testing" mode logging into screen instead
                    // of launching the default browser. To activate it though, needs to be done from Terminal:
                    //
                    //  $ defaults write parchis.org.lupa lupa_TestMode -bool YES
                    //
                    var testMode: Bool = false
                    if let letTestMode = self.userDefaults.objectForKey(LUPADefaults.lupa_TestMode) as? Bool {
                        testMode = letTestMode
                    }
                    
                    // Let's go for it
                    browserSearchIsRunning = true
                    if ( testMode ) {
                        print("TEST MODE - Browser URL: \(searchURLString)")
                    } else {
                        // Production mode, fix spaces
                        let myUrlString : String = searchURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        let theURL : NSURL? = NSURL (string: myUrlString)
                        // print("theURL: \(theURL?.path)")
                        NSWorkspace.sharedWorkspace().openURL(theURL!)
                    }
                    browserSearchIsRunning = false
                    
                } else {
                    // print ("Search string empty, ignore it...")
                }
            } else {
                // print ("URL Prefix is empty, you should set something like doDefaults...")
                // statusbarController.showPreferences()
            }
        } else {
            // print("Prefix is not an string object, ignore it....")
        }
        
        // Close the Window
        lpStatusItem.dismissStatusItemWindow()
    }
    
    // Try to stop the Browser search
    func stopBrowserSearch() {
        // print("stopBrowserSearch(): ToDo")
        
        // Send a signal indicating that search was cancel
        browserSearchIsRunning = false
        
        // ToDo
        
    }


    /// --------------------------------------------------------------------------------
    //  MARK: LDAP search
    /// --------------------------------------------------------------------------------
    
    // Call default browser with full URL from the prefix + search_field
    //
    func startLDAPSearch() {


        // Read the search string
        let searchString : String = searchField.stringValue
        let searchWords = searchString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Read userDefaults (String) and convert into NSURL
        var commandString : String  = ""
        if let letLDAP_Command = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Command) as? String {
            
            commandString = letLDAP_Command

            if let letLDAP_Host = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String {
                
                commandString = commandString + " -h " + letLDAP_Host
                
                if let letLDAP_BaseDN = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_BaseDN) as? String {

                    commandString = commandString + " -x -b \"" + letLDAP_BaseDN + "\""

                    if ( searchWords.count == 1 ) {
                        if let letLDAP_Filter_One = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Filter_One) as? String {

                            let mutableString = NSMutableString(string: letLDAP_Filter_One)
                            let regex = try! NSRegularExpression(pattern: "\\bWORD1\\b",
                                options: [.CaseInsensitive])
                            regex.replaceMatchesInString(mutableString, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, mutableString.length), withTemplate: searchWords.first!)
                            if let mySwiftString : String = mutableString as String {
                               
                                commandString = commandString + " '" + mySwiftString as String  + "'"

                            }

                        }
                    } else {
                        if ( searchWords.count > 1 ) {
                            if let letLDAP_Filter_Two = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Filter_Two) as? String {
                                
                                let mutableString = NSMutableString(string: letLDAP_Filter_Two)

                                let regex1 = try! NSRegularExpression(pattern: "\\bWORD1\\b",
                                    options: [.CaseInsensitive])
                                regex1.replaceMatchesInString(mutableString, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, mutableString.length), withTemplate: searchWords.first!)
                                
                                let regex2 = try! NSRegularExpression(pattern: "\\bWORD2\\b",
                                    options: [.CaseInsensitive])
                                regex2.replaceMatchesInString(mutableString, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, mutableString.length), withTemplate: searchWords[1])
                                
                                if let mySwiftString : String = mutableString as String {
                                    
                                    commandString = commandString + " '" + mySwiftString as String  + "'"
                                    
                                }
                            }
                        }
                    }
                    
                    // Prepare the attributes to recover
                    commandString = commandString + " dn cn uid "
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Desc) as? String {
                        commandString = commandString + letTheString + " "
                    }
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Country) as? String {
                        commandString = commandString + letTheString + " "
                    }
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_City) as? String {
                        commandString = commandString + letTheString + " "
                    }
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceLin) as? String {
                        commandString = commandString + letTheString + " "
                    }
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceInt) as? String {
                        commandString = commandString + letTheString + " "
                    }
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceMob) as? String {
                        commandString = commandString + letTheString + " "
                    }
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_HasPict) as? String {
                        commandString = commandString + letTheString + " "
                    }
                    if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Title) as? String {
                        commandString = commandString + letTheString
                    }
                 }
            }
        }

        // Log
        print("commandString: \(commandString)")
        
        // Let's go for it...
        //
        let defaultPriority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(defaultPriority, 0)) {
            
            // Update UI
            dispatch_async(dispatch_get_main_queue()) {
                self.startUI_LDAPsearchInProgress()
            }
            
            // Launch the ldapsearch
            self.ldapSearchIsRunning = true
            self.execcmdAndParse(commandString)
            self.ldapSearchIsRunning = false
        }
        

    }

    // Stop the Browser search
    //
    func stopLDAPSearch() {
        // print("stopLDAPSearch(): FINISHED LDAP SEARCH <<<<<<<<-------------------")

        // Stop visual UI
        //  self.textLabel.stringValue = ""
        self.stopUI_LDAPsearchInProgress()

        // Post process the list of users
        for user in tmpUsers {
            if ( user.haspict == "y" ) {
                
                if let letLupa_LDAP_PictureURL = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_PictureURL) as? String {
                    
                    let mutableString = NSMutableString(string: letLupa_LDAP_PictureURL)
                    let regex = try! NSRegularExpression(pattern: "<UID>",
                        options: [.CaseInsensitive])
                    regex.replaceMatchesInString(mutableString, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, mutableString.length), withTemplate: user.uid)
                    if let mySwiftString : String = mutableString as String {
                        if let letURL = NSURL(string: mySwiftString) {
                            user.picturl = letURL
                        }
                    }
                }
                print("\(user.uid) Photo: \(user.picturl)")
            } else {
                print("\(user.uid) Photo: NO PICTURE !!!!")
            }
        }
        
        // Fill up the tableview
        users = tmpUsers

        // The search finished
        var windowHeight = ikWINDOW_MIN_HEIGHT
        if ( tmpUsers.count != 0 ) {
            var max : CGFloat = 5.0
            if ( tmpUsers.count < 5 ) {
                max = CGFloat ( tmpUsers.count )
            }
            windowHeight = ikWINDOW_MIN_HEIGHT + ( 57.0 * max )
//            windowHeight = ikWINDOW_MIN_HEIGHT + ( 57.0 * 4.0 )
        }
        // Resize my window
        if let letMyWindow = self.window {
            let myWindow = letMyWindow
            let frame = myWindow.frame
            var newSize = frame.size
            newSize.height = windowHeight
            myWindow.setContentSize(newSize)  // Only available under 10.10
            // Ask the LPStatusItem to manifest
//            lpStatusItem.showStatusItemWindow()
            lpStatusItem.updateFrameStatusItemWindow()
        }
//        for user in users {
//            print("dn: \(user.dn)")
//            print("cn: \(user.cn)")
//            print("uid: \(user.uid)")
//            print("description: \(user.desc)")
//            print("country: \(user.country)")
//            print("city: \(user.city)")
//            print("voicetel: \(user.voicetel)")
//            print("voiceint: \(user.voiceint)")
//            print("voicemob: \(user.voicemob)")
//            print("haspict: \(user.haspict)")
//            print("title: \(user.title)")
//        }

        // Send a signal indicating that search was cancel
        self.ldapSearchIsRunning = false
        
    }
    
    /** @brief Gestión del Spinning wheel que indica que Abaco está trabajando
    *
    */
    func startUI_LDAPsearchInProgress () {
        // self.spinningLDAP.lay
        self.spinningLDAP.startAnimation(self)
        self.spinningLDAP.hidden = false
    }
    func stopUI_LDAPsearchInProgress () {
        self.spinningLDAP.stopAnimation(self)
        self.spinningLDAP.hidden = true
    }

    //[[[self out_SpinningCAView] progressIndicatorLayer] setColor:[NSColor blackColor]];
    
    

    
    /// --------------------------------------------------------------------------------
    //  MARK: Execute command from shell
    /// --------------------------------------------------------------------------------

    // Execute shell command and parse its output
    //
    func execcmdAndParse(cmdname: String)
    {
        var newUser: Bool = false
        let myAttributes = ["cn: ", "uid: ", "description: ", "co: ", "state: ", "telephoneNumber: ", "voicemail: ", "mobile: ", "publishpicture: ", "title: "]
        var user : LPLdapUser!

        // I'll use userDefaults, however I'm setting even more defaults :)
        var description: String = "description: "
        var country: String = "c: "
        var city: String = "city: "
        var voicelin: String = "telephoneNumber: "
        var voiceint: String = "telephoneInternal: "
        var voicemob: String = "mobile: "
        var haspict: String = "haspict: "
        var title: String = "title: "
        
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Desc) as? String {
            description = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Country) as? String {
            country = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_City) as? String {
            city = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceLin) as? String {
            voicelin = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceInt) as? String {
            voiceint = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceMob) as? String {
            voicemob = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_HasPict) as? String {
            haspict = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Title) as? String {
            title = letTheString + ": "
        }

        
        // Clean start
        tmpUsers.removeAll()
        
        // Analyses of every line
        //
        for line in run(cmdname).lines() {
        //for line in open("/Users/luis/fichero.ldapsearch").lines() {

            // Do something with each line
            if !line.hasPrefix("#") {

                // DN
                if line.hasPrefix("dn: ") {
                    newUser = true
                    
                    var token = line.componentsSeparatedByString("dn: ")
                    user = LPLdapUser()
                    user.dn = token[1]
                    tmpUsers.append(user)
                } else {
                    if ( newUser ) {
                        for attr in myAttributes {
                            if line.hasPrefix(attr) {
                                var token = line.componentsSeparatedByString(attr)
                                switch attr {

                                case "cn: ":
                                    user.cn = token[1]
                                    break
                                    
                                case "uid: ":
                                    user.uid = token[1]
                                    break
                                    
                                case description:
                                    user.desc = token[1]
                                    break

                                case country:
                                    user.country = token[1]
                                    break
                                    
                                case city:
                                    user.city = token[1]
                                    break
                                    
                                case voicelin:
                                    user.voicetel = token[1]
                                    break
                                    
                                case voiceint:
                                    user.voiceint = token[1]
                                    break
                                    
                                case voicemob:
                                    user.voicemob = token[1]
                                    break
                                    
                                case haspict:
                                    user.haspict = token[1]
                                    break
                                    
                                case title:
                                    user.title = token[1]
                                    break
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }

        ldapSearchFinished = true
    }
    

    /// --------------------------------------------------------------------------------
    //  MARK: Timer when search text changes
    /// --------------------------------------------------------------------------------
    
    // Start a timer when text changes in the search box
    //
    func startTimerTextDidChange() {
        // print("entered startTimerTextDidChange()")
        // Always cancel any pending search
        self.stopTimerTextDidChange()

        // Check if we've got something decent to search
        if !searchField.stringValue.isEmpty {

            // Start timer that may trigger the search
            timerTextDidChange = NSTimer.scheduledTimerWithTimeInterval(0.6,
                target: self,
                selector: Selector("actionTimerTextDidChange"),
                userInfo: nil,
                repeats: false)
        } else {
            if let letMyWindow = self.window {
                let myWindow = letMyWindow
                myWindow.orderBack(self)
            }
        }
    }
    
    // Stop the timer 
    //
    func stopTimerTextDidChange() {
        // print("entered stopTimerTextDidChange()")
        if ( timerTextDidChange != nil ) {
            if (  timerTextDidChange.valid ) {
                // print("stopTimerTextDidChange()")
                timerTextDidChange.invalidate()
                
                if ( self.ldapSearchIsRunning ) {
                    print("FIX ME ... !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   <=== !!!!*****!!!!!   stopLDAPSearch()")
                    self.stopLDAPSearch()
                }
            }
            timerTextDidChange = nil
        }
    }
    
    // Action to execute when the timer finishes
    //
    func actionTimerTextDidChange() {

        // Check if I'm asked to search the same
        if (  previousSearchString == searchField.stringValue ) {
            // print("Me piden buscar el mismo string que la vez anterior, lo ingnoro")
        } else {
            
            // LDAP Search -
            // Check if I'm asked for quick dirty ldap search
            //
            self.startLDAPSearch()
            
        }
        previousSearchString=searchField.stringValue
    }
    
    
    // Sets the size of the window’s content to a given size,
    // 
    // Note: This method is NOT used because I'm using:
    //       myWindow.setContentSize(newSize)
    //
    //       However, it's only available in 10.10, so I leave
    //       the following just in case I develop a <10.10 version
    //
    func resizeWindowForContentSize ( window : NSWindow, size : NSSize ) {
        let windowFrame = window.contentRectForFrameRect(window.frame)
        let newWindowFrame = window.frameRectForContentRect(NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - size.height, size.width, size.height))
        window.setFrame(newWindowFrame, display: true, animate: window.visible)
    }

    
    
    /// --------------------------------------------------------------------------------
    //  MARK: KVO - Key Value Observing activation, de-activation and action
    /// --------------------------------------------------------------------------------
    
    // Context (up=unsafe pointer)
    private var up_LupaSearchWinCtrl_KVOContext_LDAPSearchResult = 0
    
    // Load and activate the Key Value Observing
    //
    func loadKVO () {
        self.onObserver()
    }
    
    // Activate the observer
    //
    func onObserver () {
        for item in self.observableKeys_LDAPSearchResults {
            self.addObserver(self, forKeyPath: item, options: [], context: &up_LupaSearchWinCtrl_KVOContext_LDAPSearchResult)
        }
    }
    
    // Deactivate and unload the Key Value Observing
    //
    func unloadKVO () {
        self.offObserver()
    }
    
    // Deactivate the observer
    //
    func offObserver () {
        for item in self.observableKeys_LDAPSearchResults {
            self.removeObserver(self, forKeyPath: item)
        }
    }
    
    // Actions when a change comes...
    //
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        
        // Act on the appropiate context
        if context == &up_LupaSearchWinCtrl_KVOContext_LDAPSearchResult {
            

            //	New guard statement to return early if there's no change.
            guard let change = change else {
                // print("No change, return")
                return
            }
            
            //  Identify the kind of change
            //
            if let rv = change[NSKeyValueChangeKindKey] as? UInt,
                kind = NSKeyValueChange(rawValue: rv) {
                    // print("Tipo de cambio: \(kind)")
                    switch kind {
                    case .Setting:
                        // print(".Setting -> \(change[NSKeyValueChangeKindKey]) ")
                        if ( keyPath == "self.ldapSearchFinished" ) {
                            // Update UI
                            dispatch_async(dispatch_get_main_queue()) {
                                self.stopLDAPSearch()
                                self.offObserver()
                                self.ldapSearchFinished = false
                                self.onObserver()
                            }
                        }
                    case .Insertion:
                        // print(".Insertion -> \(change[NSKeyValueChangeNewKey]) ")
                        break
                    case .Removal:
                        // print(".Removal -> \(change[NSKeyValueChangeOldKey]) ")
                        break
                    case .Replacement:
                        // print(".Replacement -> \(change[NSKeyValueChangeOldKey]) ")
                        break
                    }

                    // Debug purposes
                    //print("change[NSKeyValueChangeNewKey] -> \(change[NSKeyValueChangeNewKey]) ")
                    //print("change[NSKeyValueChangeOldKey] -> \(change[NSKeyValueChangeOldKey]) ")
                    //print("change[NSKeyValueChangeIndexesKey] -> \(change[NSKeyValueChangeIndexesKey]) ")
                    //print("change[NSKeyValueChangeNotificationIsPriorKey] -> \(change[NSKeyValueChangeNotificationIsPriorKey]) ")
            }
            
        } else {
            // Defaults...
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
}
