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


    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var searchSeparator: NSTextField!
    @IBOutlet weak var urlScroll: NSScrollView!
    @IBOutlet var urlView: NSTextView!
    @IBOutlet weak var version: NSTextField!
    
    @IBOutlet weak var customShortcutView: MASShortcutView!
    
    //  In order to work with the user defaults, stored under:
    //  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
    //  $ defaults read parchis.org.XX.plist
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
        
        // Clean the URL scrollview background
        urlScroll.backgroundColor = NSColor.clearColor()
        urlScroll.drawsBackground = false
        
        // Prepare the data entry content
        textView.delegate = self
        textView.textStorage?.setAttributedString(NSAttributedString(string: ""))
        
        // Set content to defaults
        setTextViewFromDefaults()

    }

    /// --------------------------------------------------------------------------------
    //  MARK: TextView changes
    /// --------------------------------------------------------------------------------
    
    // Sync urlView with textView
    //
    func textDidChange(notification: NSNotification) {
        syncURLView()
    }
    func syncURLView() {
        let thePrefix : String = textView.textStorage!.string + "<search contents>"
        urlView.textStorage?.setAttributedString(NSAttributedString(string: thePrefix))
    }
    

    /// --------------------------------------------------------------------------------
    //  MARK: Actions
    /// --------------------------------------------------------------------------------
    
    // OK Button
    //
    @IBAction func doSetURLPrefix(sender: AnyObject) {
        
        // Save the content of the nstextview as the URLPrefix
        //
        let thePrefix : String = textView.textStorage!.string
        
        // Allways save the absolute string (not the URL)
        //
        // print("OK, save to defaults URL Prefix: \(thePrefix)")
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(thePrefix, forKey: LUPADefaults.lupa_URLPrefix)
        
        // Hide the window
        self.window?.orderOut(self)
    }
    
    
    // CANCEL Button
    //
    @IBAction func doCancel(sender: AnyObject) {
        // print("CANCEL")

        // Hide the window
        self.window?.orderOut(self)

        // Set content to defaults
        setTextViewFromDefaults()
    }
    
    // RESET DEFAULTS
    // Function to reset textview contents to defaults
    //
    func setTextViewFromDefaults() {
        
        // Read userDefaults (String) 
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let letTheString = userDefaults.objectForKey(LUPADefaults.lupa_URLPrefix) as? String {
            // print("lupa_URLPrefix: \(letTheString)")
            textView.textStorage?.setAttributedString(NSAttributedString(string: letTheString))
        } else {
            // print("Not a String object, reset to a sample")
            setSampleDefault()
        }
        // Show URL View
        syncURLView()
        
    }

    // SAMPLE CONTENT
    // Function to set some sample text when textView is empty
    //
    func setSampleDefault() {
        // Set a sample value or empty
        // let thePrefix : String = "http://www.sample.com/query.cgi?user="
        let thePrefix : String = ""
        // print("OK, saving URL Prefix: \(thePrefix)")
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(thePrefix, forKey: LUPADefaults.lupa_URLPrefix)
    }

}