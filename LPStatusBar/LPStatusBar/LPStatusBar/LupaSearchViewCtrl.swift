//
//  LupaSearchViewCtrl.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 17/8/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LupaSearchViewCtrl: NSViewController {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    

    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    /// Initalization when created through IB
    ///
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        // print("init?(coder: NSCoder  \(coder))")
    }
    
    /// Initalization when created programatically
    ///
    override init?(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // Log
        //Swift.print("LupaSearchViewCtrl - Initalization when created programatically")
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
        //print("awakeFromNib()")
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
        //print("loadView()")
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
}
