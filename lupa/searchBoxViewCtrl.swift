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
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_URLPrefix) as? String {
            // print("lupa_URLPrefix: \(letTheString)")
            
            if !letTheString.isEmpty {
                if !searchField.stringValue.isEmpty {
                    let searchURLString : String = letTheString + searchField.stringValue
                    
                    // Let's go rock and roll
                    // Read userDefaults (String)
                    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    if let letTestMode = userDefaults.objectForKey(LUPADefaults.lupa_TestMode) as? Bool {
                        let testMode = letTestMode
                        if ( testMode ) {
                            // Test, developer mode
                            print("Browser URL: \(searchURLString)")
                        } else {
                            // Production mode
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
