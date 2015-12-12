//
//  LupaSearchViewCtrl.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 17/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//
//

import Cocoa

class LupaSearchViewCtrl: NSViewController, NSTextFieldDelegate {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    @IBOutlet weak var searchField: LupaSearchTextField!
    
    //  In order to work with the user defaults, stored under:
    //  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
    //  $ defaults read parchis.org.XX.plist
    let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    //  Vars that I need to be initialized
    var textDidChangeInterval : NSTimeInterval = 0.0    //!< Time interval to calculate text did change trigger action
    var timerTextDidChange    : NSTimer!             //!< Timer that triggers action after text did change
    

    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    /// Initalization when created through IB
    ///
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        print("init?(coder: NSCoder  \(coder))")
    }
    
    /// Initalization when created programatically
    ///
    override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // Log
        // Swift.print("LupaSearchViewCtrl - Initalization when created programatically")
        //Swift.print("    \(self) init?(nibName: \(nibNameOrNil), bundle: \(nibBundleOrNil))")
        //Swift.print("    self.preferredContentSize.width : \(self.preferredContentSize.width)")
        //Swift.print("    self.preferredContentSize.height: \(self.preferredContentSize.height)")
        //Swift.print("    self.view: \(self.view)")
        
    }
    
    /// awakeFromNib()
    //
    //  Prepares the receiver for service after it has been loaded from
    //  an Interface Builder archive, or nib file
    //  It is guaranteed to have all its outlet instance variables set.
    //
    override func awakeFromNib() {
        // print("awakeFromNib()")
    }
    
    
    /// loadView()
    //
    //  This method connects an instantiated view from a nib file to the
    //  view property of the view controller. This method is called by
    //  the system, and is exposed in this class so you can override it to
    //  add behavior immediately before or after nib loading
    //
    override func loadView() {
        super.loadView()
        print("loadView()")
        
        // Tell the searchField I'm his delegate
        self.searchField.delegate = self
    }


    /// viewDidLoad()  *new in 10.10*
    //
    //  Called after the view controller’s view has been loaded into memory.
    //  For a view controller originating in a nib file, this method is called 
    //  immediately after the view property is set. For a view controller 
    //  created programmatically, this method is called immediately after 
    //  the loadView method completes.
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //print("viewDidLoad()")
    }
    
    // Fuerzo que mi preferredContentSize sea mi tamaño actual
    //
    override var preferredContentSize : NSSize {
        get {
            return self.view.frame.size
        }
        set {
            super.preferredContentSize = newValue
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

    
    
    /// --------------------------------------------------------------------------------
    //  MARK: Execute the search when user pressed ENTER
    /// --------------------------------------------------------------------------------
    
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
                    if ( testMode ) {
                        print("TEST MODE - Browser URL: \(searchURLString)")
                    } else {
                        // Production mode, fix spaces
                        let myUrlString : String = searchURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        let theURL : NSURL? = NSURL (string: myUrlString)
                        // print("theURL: \(theURL?.path)")
                        NSWorkspace.sharedWorkspace().openURL(theURL!)
                    }

                    
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
        if let window = self.view.window {
            window.close()
        }
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: Execute something when user modifies the search field
    /// --------------------------------------------------------------------------------
    
    // Called when user modify the nstextfield
    //
    override func controlTextDidChange(notification: NSNotification?) {
        if notification?.object as? NSTextField == self.searchField {
            self.textDidChangeInterval = 0.0
            print("Algo pasa con Mary")
            self.startTimerTextDidChange()
        }
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: Timer to show the Menu
    /// --------------------------------------------------------------------------------
    
    // Start a timer to show the Menu
    //
    func startTimerTextDidChange() {
        print("startTimerTextDidChange()")
        self.stopTimerTextDidChange()
        timerTextDidChange = NSTimer.scheduledTimerWithTimeInterval(0.5,
            target: self,
            selector: Selector("actionTimerTextDidChange"),
            userInfo: nil,
            repeats: false)
        
    }
    
    // Stop the timer (not used, but comes with my template :-))
    //
    func stopTimerTextDidChange() {
        if ( timerTextDidChange != nil ) {
            if (  timerTextDidChange.valid ) {
                print("stopTimerTextDidChange()")
                timerTextDidChange.invalidate()
            }
            timerTextDidChange = nil
        }
    }
    
    // Action to execute when the timer finishes
    //
    func actionTimerTextDidChange() {
        
        // Start the menu
//        print("Launching the action")
//        var frame = self.view.frame
//        frame.size.height = frame.size.height + 20.0
//        self.view.frame = frame
//        if let window = lpStatusItem.statusItemWindowController.window {
//            window.contentView = self.view
//        }
        
//        lpStatusItem.statusItemWindowController.refreshContentViewController()
        
        
//        lpStatusItem.statusItemWindowController.window?.contentView = self.view
        
        

//        if let letSuperview = self.view.superview {
//            let superview = letSuperview
//            var frame = superview.frame
//            frame.size.height = frame.size.height + 20.0
//            superview.frame = frame
//        }
//        
//        print("self.view: \(self.view)")
//        print("self.view.superview: \(self.view.superview)")

        //
//        self.view.translatesAutoresizingMaskIntoConstraints = false
//        let viewsDict = ["subView" : self.view]
//        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
//        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
//        self.view.addConstraints(verticalConstraints)
//        self.view.addConstraints(horizontalConstraints)
        

        if let window = lpStatusItem.statusItemWindowController.window {
            
            print("window.contentView: \(window.contentView)")
            let frame = window.frame
            var newSize = frame.size
            newSize.height = newSize.height + 20.0
            
            // Opción 1
            //self.resizeWindowForContentSize(window, size: newSize)
            
            // Opción 2
            window.setContentSize(newSize)

        }
    }
    
    func resizeWindowForContentSize ( window : NSWindow, size : NSSize ) {
        let windowFrame = window.contentRectForFrameRect(window.frame)
        let newWindowFrame = window.frameRectForContentRect(NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - size.height, size.width, size.height))
        window.setFrame(newWindowFrame, display: true, animate: window.visible)
    }
}
