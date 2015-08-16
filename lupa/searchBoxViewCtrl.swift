//
//  searchBoxViewCtrl.swift
//  lupa
//
//  Created by Luis Palacios on 13/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class searchBoxViewCtrl: NSViewController {

    // MARK: Global variables and constants
    // --------------------------------------------------------------------------------
    
    // This class variables
    var firstAwakeFromNib: Bool = false
    
    // --------------------------------------------------------------------------------
    // MARK: IBOutlets
    
    @IBOutlet weak var searchField: NSTextField!
    @IBOutlet var viewToReplace: NSView!
    
    //  In order to work with the user defaults
    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    // --------------------------------------------------------------------------------
    // MARK: Init
    
    /// Initalization when created through IB
    ///
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        // So viewToReplace knows we are starting...
        self.firstAwakeFromNib = true
    }
    
    /// Initalization when created programatically
    ///
    override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // So viewToReplace knows we are starting...
        self.firstAwakeFromNib = true
    }
    
    /// NIB is ready, from here we can access outlets, actions, etc
    ///
    override func awakeFromNib() {
        if self.firstAwakeFromNib == true {
            self.firstAwakeFromNib = false
            if ( self.viewToReplace != nil ) {
                self.viewToReplace.replaceWithView(self.view)
            }
        }
    }
    
    /// --------------------------------------------------------------------------------
    //  MARK: IBActions through First Responder
    /// --------------------------------------------------------------------------------
    
    //
    // Capture firstResponder "doCancelSearch:" command. 
    //
    // This is not connected through IBN but is a message sent from the 
    // searchTextField subclass when user presse ESCAPE in the searchBox
    //
    @IBAction func doCancelSearch(sender: AnyObject) {
        // Simply close the search box window
        if let window = self.view.window {
            window.close()
        }
    }

    
    // --------------------------------------------------------------------------------
    // MARK: Gestión del view load
    
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {

    }

    
    // Call default browser with full URL from the prefix + search_field
    //

    @IBAction func doSearch(sender: AnyObject) {
    
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
                    
                    // Let's go rock and roll
                    // 
                    // Note: I'm leaving here a way to activate a "Testing" mode logging into screen instead
                    // of launching the default browser. To activate it though, needs to be done from Terminal: 
                    //
                    //  $ defaults write parchis.org.lupa lupa_TestMode -bool YES
                    //
                    if let letTestMode = self.userDefaults.objectForKey(LUPADefaults.lupa_TestMode) as? Bool {
                        let testMode = letTestMode
                        if ( testMode ) {
                            // Test, developer mode
                            print("Browser URL: \(searchURLString)")
                        } else {
                            // Production mode, fix spaces
                            let myUrlString : String = searchURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                            let theURL : NSURL? = NSURL (string: myUrlString)
                            NSWorkspace.sharedWorkspace().openURL(theURL!)
                        }
                    }
                } else {
                    // print ("Search string empty, ignore it...")
                }
            } else {
                // print ("URL Prefix is empty, call doDefaults...")
                // statusbarController.showPreferences()
            }
        } else {
            // print("Prefix is not an string object, ignore it....")
        }
        
        // Close the Window
        if let window = self.view.window {
            window.close()
        }
    }

}
