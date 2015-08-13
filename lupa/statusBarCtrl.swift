//
//  statusBarCtrl.swift
//  lupa
//
//  Created by Luis Palacios on 12/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class statusBarCtrl: NSObject, NSMenuDelegate {

    // ------------------------------------------------------------------
    // MARK: Attributes
    // ------------------------------------------------------------------

    var statusItem : NSStatusItem!
    var button: NSStatusBarButton!

    var statusItemView : statusBarView!
    
    var statusImageOn : NSImage!
    var statusImageOff : NSImage!
    var statusImageOnNeg : NSImage!
    var statusImageOffNeg : NSImage!


    // --------------------------------------------------------------------------------
    // MARK: Init / Deinit
    
    override init() {
        super.init()
    }
    
    deinit {
    }

    // --------------------------------------------------------------------------------
    // MARK: Init with Status menu
    
    convenience init(_ statusMenu: NSMenu) {
        self.init()
        
        print("Me han pasado un statusMenu")

        // Let's "insert" myself into the status bar
        
        // 1. Create an statusItem inside the status bar
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        // 
        self.button = self.statusItem?.button
        self.button?.title = "Start"
        self.button?.action = "start:"
        self.button?.target = self

        
        // 2. Create the "image" objetcs to be able to set the right icon
        //    based on status (On/Off) and (Pressed=Negative/Unpressed=Normal)
        let bundle : NSBundle = NSBundle.mainBundle()
        self.statusImageOn = NSImage(contentsOfFile: bundle.pathForResource("LupaOn_18x18", ofType: "png")!)
        self.statusImageOff = NSImage(contentsOfFile: bundle.pathForResource("LupaOff_18x18", ofType: "png")!)
        self.statusImageOnNeg = NSImage(contentsOfFile: bundle.pathForResource("LupaOnNeg_18x18", ofType: "png")!)
        self.statusImageOffNeg = NSImage(contentsOfFile: bundle.pathForResource("LupaOffNeg_18x18", ofType: "png")!)
//        self.statusImageOn = NSImage(named: "LupaOn_18x18" )
//        self.statusImageOff = NSImage(named: "LupaOff_18x18" )
//        self.statusImageOnNeg = NSImage(named: "LupaOnNeg_18x18" )
//        self.statusImageOffNeg = NSImage(named: "LupaOffNeg_18x18" )
        
//        // 3. Create a custome NSView to handle what's seen and be able to capture the mouse hover
//        self.statusItemView = statusBarView(self.statusItem)
//        
//        // 4. Bind the custom menu I've been given through the init
//        statusMenu.delegate = self              // Set myself as delegate
//        self.statusItem.menu = statusMenu       // Assign the menu
//
//        // 5. Set the image, initially normal unpressed
//        showStandardImage(true)
        
        // LUIS AQUI
    }
    
    // Function to set the image based on the passed argument
    //
    // statusFlag: true  = Normal image
    // statusFlag: false = Negative image
    //
    func showStandardImage(statusFlag: Bool) {
        if ( statusFlag == true ) {
            self.statusItemView.image = self.statusImageOn
            self.statusItemView.imageNeg = self.statusImageOnNeg
        } else {
            self.statusItemView.image = self.statusImageOff
            self.statusItemView.imageNeg = self.statusImageOffNeg
        }
    }
    
    
    func start(sender : AnyObject) {
        button?.title = "Stop"
        button?.action = "stop:"
        print("Pulsaron en Start")
    }
    
    
    func stop(sender : AnyObject) {
        button?.title = "Start"
        button?.action = "start:"
        print("Pulsaron en Stop")
    }
    
    

}
