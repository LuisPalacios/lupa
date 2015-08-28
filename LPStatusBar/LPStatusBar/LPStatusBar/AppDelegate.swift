//
//  AppDelegate.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 17/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

// ErroType's
enum skViewControllerNotReady: ErrorType {
    case cannotActivate
    case cannotCreate
    case cannotAccessIconImage
}
extension skViewControllerNotReady: CustomStringConvertible {
    var description: String {
        switch self {
        case cannotActivate: return "Attention! can't activate the custom NSViewController"
        case cannotCreate: return "Attention! can't create the custom NSViewController"
        case cannotAccessIconImage : return "Attention! can't access the Icon Image"
        }
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    var searchViewCtrl : LupaSearchViewCtrl!
    
    //  Connected to MainMenu.xib objects through the Interface Builder
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!


    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // Temporal variables
        var success: Bool = false
        
        /// Create my custom View Controller
        ///
        success = false
        do {
            try createCustomViewController()
            do {
                /// Activate the status bar and make all connections
                /// 
                try activateStatusBar()
                success = true
            } catch let error as skViewControllerNotReady {
                print(error.description)
            } catch {
                print ("Undefinded error")
            }
        } catch let error as skViewControllerNotReady {
            print(error.description)
        } catch {
            print ("Undefinded error")
        }
        
        // Show result
        if success {
            print("AppDelegate: Everything WENT WELL!!!")
        } else {
            print("AppDelegate: VAYA CAGADA!!!!!")
        }
    }


    // What to do when we finish...
    //
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    
    /// --------------------------------------------------------------------------------
    //  MARK: Handling of the custom view controller and status bar
    /// --------------------------------------------------------------------------------
    
    // Create my custom View Controller
    //
    func createCustomViewController () throws {
        
        // Prepare the name of the NIB = name of the class
        let sNibName = NSStringFromClass(LupaSearchViewCtrl).componentsSeparatedByString(".").last!
        
        // Create custom View Controller
        if let letSearchViewCtrl = LupaSearchViewCtrl(nibName: sNibName, bundle: nil) {
            searchViewCtrl = letSearchViewCtrl
            
        } else {
            throw skViewControllerNotReady.cannotCreate
        }
    }
    
    // Activate status bar and make connections
    //
    func activateStatusBar () throws {
        // Activate my (singleton) "Status Bar Item" with the custom view controller
        if ( searchViewCtrl != nil ) {
            if let letItemImage = NSImage(named: "statusbar-icon") {
                let itemImage = letItemImage
                lpStatusItem.activateStatusItemWithImage(self.statusMenu, itemImage: itemImage, contentViewController: searchViewCtrl)
            } else {
                throw skViewControllerNotReady.cannotAccessIconImage
            }

        } else {
            throw skViewControllerNotReady.cannotActivate
        }
    }
    
}


