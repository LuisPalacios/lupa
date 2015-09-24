//
//  LupaSearchWinCtrl.swift
//  lupa
//
//  Created by Luis Palacios on 20/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaSearchWinCtrl: NSWindowController, NSWindowDelegate, NSSearchFieldDelegate { // , NSSearchFieldDelegate {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    @IBOutlet weak var searchField: LupaSearchField!
    @IBOutlet weak var textLabel: NSTextField!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
        
    
    //  In order to work with the user defaults, stored under:
    //  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
    //  $ defaults read parchis.org.XX.plist
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
        
        // Work in Progress
        //
        WiP
        //
        // Lo ideal sería hacer lo anterior en la clase LPStatusItemWindowCtrl.
        // durante su inicalización y recibir esta nswindow, que le cambiase la 
        // clase de su contentview a LPStatusitembacgroundview
        // pero sin tocarle absolutamente nada más... :-)
        //        // Show the Window fading in...
        //        let window : LPStatusItemWindow = self.window as! LPStatusItemWindow

    }
    
    /// awakeFromNib()
    //
    //  Prepares the receiver for service after it has been loaded from
    //  an Interface Builder archive, or nib file. It is guaranteed to 
    //  have all its outlet instance variables set.
    //
    override func awakeFromNib() {
        print("awakeFromNib()")
        
        // Tell the searchField I'm his delegate
        // self.searchField.delegate = self

        // Follow search string modifications
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("doSearch:"), name: NSControlTextDidChangeNotification, object: self.searchField)

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
            Swift.print("insertNewline")
            self.startBrowserSearch()

            // retval = true causes Apple to NOT fire the default enter action
            // so if true, searchFieldModified() will NOT be called
            retValue = true
    
        case "cancelOperation:":
            // CANCEL Search Window -
            //
            lpStatusItem.dismissStatusItemWindow()

            // retval = true causes Apple to NOT fire the default enter action
            // so if true, searchFieldModified() will NOT be called
            retValue = true
            
        default:
            Swift.print("Llegó otro comando, deconozco cual: \(commandSelector)")
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
        
        print("startBrowserSearch()")

        // Cancel the automated LDAP search if pending...
        self.stopTimerTextDidChange()
        
        // Read userDefaults (String) and convert into NSURL
        if let letURLString = self.userDefaults.objectForKey(LUPADefaults.lupa_URLPrefix) as? String {
            print("lupa_URLPrefix: \(letURLString)")
            
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
                    print("searchURLString: \(searchURLString)")
                    
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
                        print("theURL: \(theURL?.path)")
                        NSWorkspace.sharedWorkspace().openURL(theURL!)
                    }
                    browserSearchIsRunning = false
                    
                } else {
                    print ("Search string empty, ignore it...")
                }
            } else {
                print ("URL Prefix is empty, you should set something like doDefaults...")
                // statusbarController.showPreferences()
            }
        } else {
            print("Prefix is not an string object, ignore it....")
        }
        
        // Close the Window
        lpStatusItem.dismissStatusItemWindow()
    }
    
    // Try to stop the Browser search
    func stopBrowserSearch() {
        print("stopBrowserSearch(): ToDo")
        
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
        print("startLDAPSearch(): ToDo")
        
        // Log
        let leftLDAPString : String  = "ldapsearch -x -b \"ou=active,ou=employees,ou=people,o=cisco.com\" -h ldap.cisco.com uid="
        let searchString : String = searchField.stringValue
        let commandString : String = leftLDAPString + searchString
        print("LDAP: \(commandString)")
        self.textLabel.stringValue = "Searching...: " + searchField.stringValue

        // ToDo
        ldapSearchIsRunning = true

        // Resize my window
        if let letMyWindow = self.window {
            let myWindow = letMyWindow
            let frame = myWindow.frame
            var newSize = frame.size
            newSize.height = newSize.height + 20.0
            myWindow.setContentSize(newSize)  // Only available under 10.10
        }
        
        // LDAP Search. Now it's just a simulated delay
        NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: Selector("stopLDAPSearch"),
            userInfo: nil,
            repeats: false)

        // Future:
        // self.stopLDAPSearch()
    }

    // Stop the Browser search
    //
    func stopLDAPSearch() {
        print("stopLDAPSearch(): ToDo")
        
        // Send a signal indicating that search was cancel
        ldapSearchIsRunning = false
        
        // ToDo
        self.textLabel.stringValue = ""

    }
    

    /// --------------------------------------------------------------------------------
    //  MARK: Timer to show the Menu
    /// --------------------------------------------------------------------------------
    
    // Start a timer to show the Menu
    //
    func startTimerTextDidChange() {
        // print("entered startTimerTextDidChange()")
        // Always cancel any pending search
        self.stopTimerTextDidChange()

        // Check if we've got something decent to search
        if !searchField.stringValue.isEmpty {

            // Start timer that may trigger the search
            print("Starting timer that may trigger the search")
            timerTextDidChange = NSTimer.scheduledTimerWithTimeInterval(0.8,
                target: self,
                selector: Selector("actionTimerTextDidChange"),
                userInfo: nil,
                repeats: false)
        }
    }
    
    // Stop the timer (not used, but comes with my template :-))
    //
    func stopTimerTextDidChange() {
        if ( timerTextDidChange != nil ) {
            if (  timerTextDidChange.valid ) {
                // print("stopTimerTextDidChange()")
                timerTextDidChange.invalidate()
                
                if ( ldapSearchIsRunning ) {
                    print("stopSearching()")
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

}
