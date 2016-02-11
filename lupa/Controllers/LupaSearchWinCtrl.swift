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


class LupaSearchWinCtrl: NSWindowController, NSWindowDelegate, NSSearchFieldDelegate, NSTableViewDataSource, NSTableViewDelegate, LupaSearchTableviewDelegate, LupaPopoverDetailViewDelegate {
    
    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    @IBOutlet weak var searchField: LupaSearchField!
    @IBOutlet weak var searchFieldCell: NSSearchFieldCell!
    
    @IBOutlet weak var spinningLDAP: NSProgressIndicator!

    @IBOutlet weak var msgStackView: NSStackView!
    @IBOutlet var msgTextView: NSTextView!
    var timerHideAlert : NSTimer!                //!< Timer that the alert to be hidden
    
    @IBOutlet weak var ldapResultStackView: NSStackView!
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var searchStackView: NSStackView!
    
    // TableView
    @IBOutlet weak var ldapResultTableView: LupaSearchTableview!    // Tableview for the Search results
    var ldapResultCellViewHeight : CGFloat = 17.0           // Tableview's cell height (notice it'll be calculated)
    
    // Popover with ldap result detail (right click)
    @IBOutlet var popoverDetail: NSPopover!
    @IBOutlet var lupaPopoverDetailView: LupaPopoverDetailView!

    
    
    
    //  In order to work with the user defaults, stored under:
    //  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
    //  $ defaults read parchis.org.lupa.plist
    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()

    //  Class attributes
    var stringToSearch = ""
    dynamic var ldapSearchResults = ""
    var observableKeys_LDAPSearchResults = [ "self.ldapSearchHasFinished" ]
    dynamic var ldapSearchHasFinished : Bool = false
    dynamic var users = [LPLdapUser]()
    dynamic var tmpUsers = [LPLdapUser]()
    dynamic var popoverSelectedUser : LPLdapUser!
    var tmpErrors : [String] = []
    
    // More attributes
    var textDidChangeInterval : NSTimeInterval = 0.0    //!< Time interval to calculate text did change trigger action
    var previousSearchString : String = ""              //!< Control if I'm asked to search the same string as before
    var timerTextDidChange    : NSTimer!                //!< Timer that triggers action after text did change
    var browserSearchIsRunning : Bool = false
    var ldapSearchIsRunning : Bool = false
    var postfix_searchString = ""
    var minHeight = ikWINDOW_MIN_HEIGHT

    
    // Commander
    let cmd = LPCommand()
    var timerCmdTerminate : NSTimer!    //!< Ldap terminate timer
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    /// Sent after the window owned by the receiver has been loaded.
    ///
    override func windowDidLoad() {
        super.windowDidLoad()

        // Register the Cell View nib file so that the ldapResultTableView
        // can use it to render cells,
        if let nib = NSNib(nibNamed: Constants.SearchCtrl.SearchCellViewID, bundle: NSBundle.mainBundle()) {
            
            
            // Change searchField UX
//            searchField.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
            self.searchField.appearance = NSAppearance(named: NSAppearanceNameAqua)
            
            // Register the Cell
            self.ldapResultTableView.registerNib(nib, forIdentifier: Constants.SearchCtrl.SearchCellViewID)
            
            // Find out Tableview's Cell height
            var optViewArray:NSArray?
            if nib.instantiateWithOwner(self, topLevelObjects: &optViewArray) {
                if let viewArray = optViewArray {
                    for view in viewArray {
                        if view.isKindOfClass(LupaSearchCellView) {
                            if let frame = view.frame {
                                self.ldapResultCellViewHeight = frame.height
                            }
                        }
                    }
                }
            }
        }
        
        // Register as delegate to capture right click on ldap results
        self.ldapResultTableView.lupaSearchTableviewDelegate = self
        
        // Register as delegate so I can exit detail ldap view when clicked
        self.lupaPopoverDetailView.lupaPopoverDetailViewDelegate = self
    
        
        // Setup the window class
        if let letMyWindow = self.window {
            let myWindow = letMyWindow
            myWindow.opaque = false
            myWindow.hasShadow = true
            myWindow.backgroundColor = NSColor.clearColor()
        }
        
        // Calc the minimum Height possible for the
        // search window. It's exactly without the
        // message and ldap results stackviews
        if let window = self.window {
            self.minHeight = window.frame.size.height - self.mainStackView.frame.size.height + self.searchStackView.frame.size.height
        }

        // Now I can hide both msg/ldap stackviews
        self.msgStackView.hidden = true
        self.ldapResultStackView.hidden = true
        self.updateWindowFrame()
        
        
        // Subscribe myself so I'll receive(Get) Notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleWindowDidBecomeActiveNotification:",
            name: NSWindowDidBecomeKeyNotification,
            object: nil)

        // Hide spinning
        self.spinningLDAP.hidden = true
        
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
        // Everytime I do appear select the text
        self.searchField.selectText(self)
    }

    
    
    /// --------------------------------------------------------------------------------
    //  MARK: TableView NSSearchFieldDelegate, NSTableViewDataSource
    /// --------------------------------------------------------------------------------
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return self.ldapResultCellViewHeight
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cell = tableView.makeViewWithIdentifier(Constants.SearchCtrl.SearchCellViewID, owner: self) as? LupaSearchCellView else {
            return nil
        }

        let user = self.users[row]
        cell.itemName.stringValue = user.desc
        cell.itemUID.stringValue = user.cn
        cell.itemMobile.stringValue = user.voicemob
        cell.itemJobTitle.stringValue = user.title
        cell.itemImage.image = nil
        let q = LPQueue()
        q.async { () -> () in
            if let url = user.picturlMini {
                cell.itemImage.image = NSImage(contentsOfURL: url)
            }
        }
        
        return cell
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: UI
    /// --------------------------------------------------------------------------------
    
    // Show the ldap results stack view
    //
    func showLdapResultsStackView() {
        self.ldapResultStackView.hidden = false
        self.updateWindowFrame()
    }

    // Hide the ldap results stack view
    //
    func hideLdapResultsStackView() {
        self.ldapResultStackView.hidden = true
        self.updateWindowFrame()
    }

    // Show Alert stack view
    func showMessage(msg: String) {
        self.msgTextView.string = msg
        self.msgStackView.hidden = false
        self.startTimerHideAlert()
    }
    
    func hideMessage() {
        self.msgStackView.hidden = true
        self.updateWindowFrame()
    }
    
    // Start a timer that will hide the Alert information
    //
    func startTimerHideAlert() {
        self.stopTimerHideAlert()

        self.timerHideAlert = NSTimer.scheduledTimerWithTimeInterval(4,
                target: self,
                selector: Selector("actionTimerHideAlert"),
                userInfo: nil,
                repeats: false)
    }
    
    // Stop the timer that will hide the Alert information
    //
    func stopTimerHideAlert() {
        if ( timerHideAlert != nil ) {
            if (  self.timerHideAlert.valid ) {
                self.timerHideAlert.invalidate()
                
            }
            self.timerHideAlert = nil
        }
    }
    
    // Action to execute when the timer finishes
    //
    func actionTimerHideAlert() {
        self.hideMessage()
    }
    
    
    // Update the Window Frame, basically resize
    // its height based on what I'm showing...
    func updateWindowFrame() {
        
        if ( self.ldapResultStackView.hidden == true ) {
            
            // LDAP RESULT's VIEW INACTIVE
            if let window = self.window {
                var newSize = window.frame.size
                newSize.height = self.minHeight
                window.setContentSize(newSize)  // Only available under 10.10
            }

        } else {
            
            // LDAP RESULT's VIEW ACTIVE
            var windowHeight = self.minHeight
            if ( self.users.count != 0 ) {
                var max : CGFloat = 5.0
                if ( self.users.count < 5 ) {
                    max = CGFloat ( self.users.count )
                }
                windowHeight = self.minHeight + ( (self.ldapResultCellViewHeight + 2.0) * max ) + 12.0
            }
            if let window = self.window {
                var newSize = window.frame.size
                newSize.height = windowHeight
                window.setContentSize(newSize)  // Only available under 10.10
            }
        }
        lpStatusItem.updateFrameStatusItemWindow()
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
            self.stringToSearch = searchField.stringValue.trim()
            if !self.stringToSearch.isEmptyOrWhitespace() {
                self.postfix_searchString = self.stringToSearch
                self.startBrowserSearch()
            } else {
                // print ("Search string empty, ignore it...")
            }
            self.previousSearchString=self.stringToSearch

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
                
                // I spect self.postfix_searchString with the string
                // to be added at the end of the url
                var searchString = self.postfix_searchString
                
                if let letSearchSeparatorEnabled = self.userDefaults.objectForKey(LUPADefaults.lupa_SearchSeparatorEnabled) as? Bool {
                    let searchSeparatorEnabled = letSearchSeparatorEnabled
                    if ( searchSeparatorEnabled ) {
                        if let letSearchSeparator = self.userDefaults.objectForKey(LUPADefaults.lupa_SearchSeparator) as? String {
                            let searchSeparator = letSearchSeparator
                            searchString = self.stringToSearch.stringByReplacingOccurrencesOfString(" ", withString: searchSeparator, options: NSStringCompareOptions.LiteralSearch, range: nil)
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
    
    // A row from the search ldap search results has been selected so
    // I have to go for the browser thing...
    @IBAction func rowSelected(sender: AnyObject) {
        
        let selectedRow = self.ldapResultTableView.selectedRow
        if ( selectedRow != -1 && selectedRow < self.users.count ) {
            let user = self.users[selectedRow]
            if !user.cn.isEmpty {
                self.postfix_searchString = user.cn
                self.startBrowserSearch()
            } else {
                print ("ERROR: user cn is empty")
            }
        }
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: TableView LupaSearchTableviewDelegate (POPOVER with detail)
    /// --------------------------------------------------------------------------------

    // Right Clicked a row to show details
    //
    func tableView(tableview: NSTableView, clickedRow: NSInteger, clickedColumn: NSInteger, clickedPoint: NSPoint, clickedRect: NSRect) {
        self.popoverSelectedUser = nil
        self.popoverDetail.showRelativeToRect(clickedRect, ofView: tableview, preferredEdge: NSRectEdge.MinY)
        let q = LPQueue()
        q.async { () -> () in
            self.popoverSelectedUser = self.users[clickedRow]
        }
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: LupaPopoverDetailViewDelegate
    /// --------------------------------------------------------------------------------
    
    // Mouse left click on top of the Popover Detail View
    //
    func popoverDetailViewClicked() {
        
        // Rule is: Dismiss and Browse the user
        self.popoverDetail.close()
        let user = self.popoverSelectedUser
        if !user.cn.isEmpty {
            self.postfix_searchString = user.cn
            self.startBrowserSearch()
        } else {
            print ("ERROR: user cn is empty")
        }
    }
    
    // Mouse right click on top of the Popover Detail View
    //
    func popoverDetailViewRightClicked() {
        
        // Rule is: Dismiss the view
        self.popoverDetail.close()
    }
    
    
    /// --------------------------------------------------------------------------------
    //  MARK: LDAP search
    /// --------------------------------------------------------------------------------
    
    // Start the ldap search
    // Prepare the command....
    //
    func ldapsearchStart(timeout : Int) {

        // search string
        let searchString : String = self.stringToSearch
        let searchWords = searchString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        

        // Continue analysing each of the arguments...
        var commandString : String  = ""
        
        // CLI Command (LDAPTLS_REQCERT=allow /usr/bin/ldapsearch)
        //
        guard let letLDAP_Command = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Command) as? String else {
            self.showMessage("ERROR: Missing LDAP command")
            return
        }
        commandString = letLDAP_Command
        
        // Host and port URL (-H ldaps://myhost.domain.com:636)
        //
        guard let letLDAP_Host = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Host) as? String else {
            self.showMessage("ERROR: Missing Host")
            return
        }
        var letLDAP_Port = "636" // Default
        if let letLDAP_Bind_Port = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Port) as? String {
            letLDAP_Port = letLDAP_Bind_Port
        }
        var intLDAP_Port = 0
        if let num = Int(letLDAP_Port) {
            intLDAP_Port = num
        }
        commandString = commandString + " -H ldaps://" + letLDAP_Host + ":" + letLDAP_Port

        // Limit search (-z 'n')
        //
        var limitResults = 20
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Limit_Results) as? String {
            if ( !letTheString.isEmpty ) {
                if let theLimit = Int(letTheString) {
                    limitResults = theLimit
                    commandString = commandString + " -z \(limitResults)"
                }
            }
        }
        
        // Binding information -D user,usrestore -w Password
        //
        if let letLDAP_Bind_User = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_User) as? String {
            var bindUser = letLDAP_Bind_User
            guard let letLDAP_Bind_UserStore = self.userDefaults.objectForKey(LUPADefaults.lupa_BIND_UserStore) as? String else {
                self.showMessage("ERROR: Missing User store")
                return
            }
            bindUser = "CN=" + bindUser + "," + letLDAP_Bind_UserStore
            commandString = commandString + " -D \"" + bindUser + "\""
            
            
            guard let letLDAP_Bind_Password = internetPasswordForServer(letLDAP_Host, account: letLDAP_Bind_User, port: intLDAP_Port, secProtocol: SecProtocolType.LDAPS) else {
                self.showMessage("ERROR: Password is missing")
                return
            }
            commandString = commandString + " -w \"" + letLDAP_Bind_Password + "\""
        }
        

        // Search base (-x -b basedn)
        //
        guard let letLDAP_BaseDN = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_BaseDN) as? String else {
            self.showMessage("ERROR: Base DN is missing")
            return
        }
        commandString = commandString + " -x -b \"" + letLDAP_BaseDN + "\""

        // Here we go...
        self.ldapSearchIsRunning = true

        // Prepare the Filters
        //
        // ( | (description=*W1*W2*W3*...*Wn*) (cn=*W1*W2*W3*...*Wn*) )
        //
        var gotFilter = false
        var wordRegex = "*"
        for word in searchWords {
            if ( word.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ) {
                wordRegex = wordRegex + "\(word)*"
            }
        }
        let search_CN = self.userDefaults.boolForKey(LUPADefaults.lupa_LDAP_Search_CN)
        let search_Desc = self.userDefaults.boolForKey(LUPADefaults.lupa_LDAP_Search_Desc)
        let search_VoiceLin = self.userDefaults.boolForKey(LUPADefaults.lupa_LDAP_Search_VoiceLin)
        let search_VoiceInt = self.userDefaults.boolForKey(LUPADefaults.lupa_LDAP_Search_VoiceInt)
        let search_VoiceMob = self.userDefaults.boolForKey(LUPADefaults.lupa_LDAP_Search_VoiceMob)
        
        var filter = "( |"
        if search_CN {
            if let str = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_CN) as? String {
                filter = filter + " (\(str)=\(wordRegex))"
                gotFilter=true
            }
        }
        if search_Desc {
            if let str = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Desc) as? String {
                filter = filter + " (\(str)=\(wordRegex))"
                gotFilter=true
            }
        }
        if search_VoiceLin {
            if let str = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceLin) as? String {
                filter = filter + " (\(str)=\(wordRegex))"
                gotFilter=true
            }
        }
        if search_VoiceInt {
            if let str = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceInt) as? String {
                filter = filter + " (\(str)=\(wordRegex))"
                gotFilter=true
            }
        }
        if search_VoiceMob {
            if let str = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceMob) as? String {
                filter = filter + " (\(str)=\(wordRegex))"
                gotFilter=true
            }
        }
        filter = filter + " )"
        if ( gotFilter == true ) {
            commandString = commandString + " '" + filter as String  + "'"
        }
        
        // Prepare the attributes to fetch
        //
        commandString = commandString + " dn cn uid "
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_City) as? String {
            commandString = commandString + letTheString + " "
        }
        
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Title) as? String {
            commandString = commandString + letTheString + " "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Desc) as? String {
            commandString = commandString + letTheString + " "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceLin) as? String {
            commandString = commandString + letTheString + " "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceInt) as? String {
            commandString = commandString + letTheString + " "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Country) as? String {
            commandString = commandString + letTheString + " "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_VoiceMob) as? String {
            commandString = commandString + letTheString
        }
        
        // Start the spinning...
        let mainQueue = LPQueue.Main
        mainQueue.async { () -> () in
            self.startUI_LDAPsearchInProgress()
        }
        
        // Launch the ldapsearch, will be an async thread
        self.execCmdAndParse(commandString)
        
        // Launch ldapsearch execution timeout. If program doesn't return
        // after timeout seconds, send him a terminate signal
        if ( timeout != 0 ) {
            self.startTimerCmdTerminate(timeout)
        }
        
    }

    // Command execution timer --------------------------------------------------
    //
    func startTimerCmdTerminate(timeout : Int) {
        self.stopTimerCmdTerminate()
        let dTimeout = Double(timeout)
        self.timerCmdTerminate = NSTimer.scheduledTimerWithTimeInterval(dTimeout,
            target: self,
            selector: Selector("actionTimerCmdTerminate"),
            userInfo: nil,
            repeats: false)
    }
    func stopTimerCmdTerminate() {
        if ( timerCmdTerminate != nil ) {
            if (  self.timerCmdTerminate.valid ) {
                self.timerCmdTerminate.invalidate()
                
            }
            self.timerCmdTerminate = nil
        }
    }
    func actionTimerCmdTerminate() {
        // Ask current cmd to stop
        self.showMessage("'ldapsearch' or network timeout!")
        self.cmd.terminate()
    }
    // --------------------------------------------------------------------------

    
    // search has Finished
    //
    func ldapsearchFinished(exit: Int) {
        
        // Stop timers and visual UI
        self.stopTimerCmdTerminate()
        self.stopUI_LDAPsearchInProgress()

        // Go for it...
        if ( exit == 0 && tmpErrors.count == 0 ) {
            
            // Get the new list of users
            self.users = self.tmpUsers
            
            // Show (or hide) the results view
            if ( self.users.count != 0 ) {
                self.showLdapResultsStackView()
            } else {
                self.hideLdapResultsStackView()
            }
            
            
            // Post process the list of users
            print("ldapsearchFinished. Found \(self.users.count) users.\n")
            for user in self.users {
                
                if let pict = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_PictureURLMini) as? String {
                    let mutableString = NSMutableString(string: pict)
                    let regex = try! NSRegularExpression(pattern: "<CN>",
                        options: [.CaseInsensitive])
                    regex.replaceMatchesInString(mutableString, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, mutableString.length), withTemplate: user.cn)
                    if let mySwiftString : String = mutableString as String {
                        if let letURL = NSURL(string: mySwiftString) {
                            user.picturlMini = letURL
                        }
                    }
                }
                if let pict = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_PictureURLZoom) as? String {
                    let mutableString = NSMutableString(string: pict)
                    let regex = try! NSRegularExpression(pattern: "<CN>",
                        options: [.CaseInsensitive])
                    regex.replaceMatchesInString(mutableString, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, mutableString.length), withTemplate: user.cn)
                    if let mySwiftString : String = mutableString as String {
                        if let letURL = NSURL(string: mySwiftString) {
                            user.picturlZoom = letURL
                        }
                    }
                }
            }
            
            self.ldapResultTableView.reloadData()
            
            
        } else {
            // print("ldapsearchFinished didn't succeed. Exit: \(exit)\nErrors: \(self.tmpErrors)")
            if ( self.tmpErrors.count > 0 ) {
                self.showMessage(self.tmpErrors[0])
            }
            self.hideLdapResultsStackView()
        }
        
        // Send a signal indicating that search was cancel
        self.ldapSearchIsRunning = false
        
    }
    
    
    // Stop the search
    //
    func ldapsearchStop() {
        
        // Stop timers and visual UI
        self.stopTimerCmdTerminate()
        self.stopUI_LDAPsearchInProgress()
        
        // Ask current cmd to stop
        self.cmd.terminate()
        
        // Search has been cancel
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

    // Execute a cli command
    //
    func execCmdAndParse(commandString: String) {
        
       
        var newUser: Bool = false
        var user : LPLdapUser!
        
        // I'll use userDefaults, however I'm setting even more defaults :)
        var cn: String = "cn: "
        var description: String = "description: "
        var country: String = "c: "
        var city: String = "city: "
        var voicelin: String = "telephoneNumber: "
        var voiceint: String = "telephoneInternal: "
        var voicemob: String = "mobile: "
        var title: String = "title: "

        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Desc) as? String {
            description = letTheString + ": "
        }
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_CN) as? String {
            cn = letTheString + ": "
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
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Attr_Title) as? String {
            title = letTheString + ": "
        }
        

        let myAttributes = [cn, "uid: ", description, country, city, voicelin, voicemob, voiceint, title]

        
        // Clean start
        self.tmpUsers.removeAll()
        
        
        // Got a command, lets log it. Notice that I REMOVE THE PASSWORD
        //  print("Command: \(commandString)")
        //  ToDO - investigate: if someone is looking at the process list (difficult I know)...
        //  they will see the password while the command is being executed
        var logString = ""
        if let rangeBeforePassword = commandString.rangeOfString("-w", options: .BackwardsSearch) {
            let index = rangeBeforePassword.startIndex
            let stringBeforePassword = commandString.substringToIndex(index)
            logString = stringBeforePassword
        }
        logString = logString + "-w \"PASSWORD_HIDDEN\" "
        if let rangeAfterPassword = commandString.rangeOfString("-x", options: .BackwardsSearch) {
            let index = rangeAfterPassword.startIndex
            let stringAfterPassword = commandString.substringFromIndex(index)
            logString = logString + stringAfterPassword
        }
        print("Command: \(logString)")
        

        // DELETE ME !!!!
        // let cmdDebugString = "/usr/local/duermeyhabla.sh"
        // print("Command: \(cmdDebugString)")

        // Ahí que vamos... 
        self.cmd.run(commandString) { (exit, stdout, stderr) -> Void in

            // Just for Logging
            //            print("---------------------------------- STANDARD OUTPUT -------- STAR")
            //            for line in stdout {
            //                print(line)
            //            }
            //            print("---------------------------------- STANDARD OUTPUT -------- END")
            //            print("---------------------------------- STANDARD ERROR  -------- START")
            //            for line in stderr {
            //                print(line)
            //            }
            //            print("---------------------------------- STANDARD ERROR  -------- END")
            //            print("exit: \(exit)")
            //            print("")

            // Clean up future buffers
            self.tmpErrors.removeAll()

            // Let's see if we end up without errors
            if ( exit == 0 && stderr.count == 0 ) {
                
                // Work the lines
                for line in stdout {
                    // print("completionHandler - LINE: \(line)")
                    
                    // Do something with each line
                    if !line.hasPrefix("#") {
                        
                        // DN
                        if line.hasPrefix("dn: ") {
                            newUser = true
                            
                            var token = line.componentsSeparatedByString("dn: ")
                            user = LPLdapUser()
                            user.dn = token[1]
                            self.tmpUsers.append(user)
                        } else {
                            if ( newUser ) {
                                for attr in myAttributes {
                                    if line.hasPrefix(attr) {
                                        var token = line.componentsSeparatedByString(attr)
                                        switch attr {
                                            
                                        case cn:
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
            } else {
                for line in stderr {
                    self.tmpErrors.append(line)
                }
            }
            
            // Say it, we finished
            // print("TERMINÓ EL COMANDO, cambio self.ldapSearchHasFinished = true ")
            let mainQueue = LPQueue.Main
            mainQueue.async { () -> () in
                self.ldapsearchFinished(exit)
            }
        }
    }
    

    /// --------------------------------------------------------------------------------
    //  MARK: Timer when search text changes
    /// --------------------------------------------------------------------------------
    
    // Start a timer when text changes in the search box
    //
    func startTimerTextDidChange() {
        self.stringToSearch = searchField.stringValue.trim()

        // Always cancel any pending search
        self.stopTimerTextDidChange()
        
        // Check if we've got something decent to search
        if self.stringToSearch.isEmptyOrWhitespace() {
            self.hideLdapResultsStackView()
        } else {
            timerTextDidChange = NSTimer.scheduledTimerWithTimeInterval(0.6,
                target: self,
                selector: Selector("actionTimerTextDidChange"),
                userInfo: nil,
                repeats: false)
        }
    }
    
    // Stop the timer 
    //
    func stopTimerTextDidChange() {
        if ( timerTextDidChange != nil ) {
            if (  timerTextDidChange.valid ) {
                timerTextDidChange.invalidate()
            }
            if ( self.ldapSearchIsRunning ) {
                self.ldapsearchStop()
            }
            timerTextDidChange = nil
        }
    }
    
    // Action to execute when the timer finishes
    //
    func actionTimerTextDidChange() {
        if let ldapSupport = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Support) as? Bool {
            if ldapSupport {
                
                // Prepare the ldapsearch command timeout
                var timeout = 10
                if let str = self.userDefaults.objectForKey(LUPADefaults.lupa_LDAP_Timeout) as? String {
                    if ( !str.isEmpty ) {
                        if let theTimeout = Int(str) {
                            timeout = theTimeout
                        }
                    }
                }
                
                // Call command
                self.ldapsearchStart(timeout)
            }
        }
        self.previousSearchString=self.stringToSearch
    }

}
