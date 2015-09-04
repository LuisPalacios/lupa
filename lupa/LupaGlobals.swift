//
//  LupaGlobals.swift
//  LPStatusBar
//
//  Created by Luis Palacios on 3/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Foundation
import AppKit

///  Application preferences are stored under:
///
///  /Users/<your_user>/Library/Preferences/parchis.org.lupa.plist
///
///  To check that file's content from command line:
///
///  defaults read parchis.org.lupa.plist
///

// LupaDefaults: Key's for storing User defaults
//
struct LUPADefaults {
    static let lupa_URLPrefix       = "lupa_URLPrefix"
    static let lupa_SearchSeparator = "lupa_SearchSeparator"                    // Character to use to separate te words in the search field (byDefault space)
    static let lupa_SearchSeparatorEnabled = "lupa_SearchSeparatorEnabled"      // Use the separator
    static let lupa_StatusBarMode   = "lupa_StatusBarMode"
    static let lupa_TestMode        = "lupa_TestMode"           // Doesn't call the Browser, just logs the URL
    static let lupa_Hotkey          = "lupa_Hotkey"
    static let lupa_HotkeyEnabled   = "lupa_HotkeyEnabled"
}

// Type of Mouse Action
//
enum LUPAStatusItemType: Int {
    case LUPAStatusItemActionNone = 0
    case LUPAStatusItemActionPrimary
    case LUPAStatusItemActionSecondary
}


/// Returns the program long name, based on constans found in "AbacoVersion.swift"
/// automatically generated from custom Xcode->Project->Build Phase script, which
/// analises the GIT information and creates version information
func programLongName() -> String
{
    let myProgramLongName : String = "Lupa \(skPROGRAM_DISPLAY_VERSION)-\(ikPROGRAM_VERSION)(\(skPROGRAM_BUILD))"
    return myProgramLongName;
}


/// MARK: NSView Extensions

/// Replace an NSView with another NSView
///
/// This method allows to replace the called view with the new passed
/// view, maintaining the constraints.
///
/// 1. Create this extension in a Global.swift file
///
/// 2. Create a custom NSViewController class (i.e. "searchBoxViewCtrl"
///    2.1 With its own XIB and final real View.
///    2.2 Create an IBOutlet and control var
///        var firstAwakeFromNib: Bool = false
///        @IBOutlet var viewToReplace: NSView!
///    2.3 Execute the replace i.e. awakeFromNib
///        override func awakeFromNib() {
///            if self.firstAwakeFromNib == true {
///                self.firstAwakeFromNib = false
///                self.viewToReplace.replaceWithView(self.view)
///            }
///        }
///
///
/// 3. In the Calling View XIB file (i.e. searchBox.xib),
///    1.1 create an object
///        NSViewController -> assign class i.e. "searchBoxViewCtrl"
///    1.2 create an NSView
///    1.3 Ctrl-Drag from the NSViewController object into the view
///    1.4 Connect with viewToReplace
///
///
/// :params: newView is the new NSView replacing the old view
///
extension NSView {
    
    func replaceWithView(newView: NSView) {
        // println("Me piden que reemplace con nueva vista")
        
        //        // I assume the content view comes with constraints
        //        var contentViewHasConstraints : Bool = true
        
        // I'm the old view
        let oldView : NSView = self
        
        // Copiar los parámetros relevantes del placeholder a la vista
        newView.frame = oldView.frame
        newView.autoresizingMask = oldView.autoresizingMask
        
        // Puntero al Contenedor que contiene la vista a reemplazar
        var contentView : NSView
        if let letContentView : NSView = oldView.superview {
            contentView = letContentView as NSView
        } else {
            return
        }
        
        // Si hay constraints, los gestiono...
        if contentView.constraints.count > 0 {
            
            // Copio y traspaso las Constraints que tiene el contentView
            // de la vista antigua hacia la vista nueva
            let contentViewConstraints : [AnyObject] = contentView.constraints
            
            // Log
            // LPLog("constraints del contentView antes del cambio: \(contentViewConstraints)")
            
            // Añado la nueva vista al contentView para que no haya problemas al
            // añadirle las constraints
            contentView.addSubview(newView)
            
            
            // Traspaso las constraints
            for constraint in contentViewConstraints {
                
                let firstItem : AnyObject = constraint.firstItem
                if let secondItem : AnyObject = constraint.secondItem {
                    
                    // var secondItem : AnyObject = constraint.secondItem
                    var newFirstItem : AnyObject = firstItem
                    var newSecondItem : AnyObject = secondItem
                    
                    if firstItem as! NSView == oldView {
                        //LPLog("Constraint a guardar: \(constraint)")
                        newFirstItem = newView
                    }
                    if secondItem as! NSView == oldView {
                        //LPLog("Constraint a guardar: \(constraint)")
                        newSecondItem = newView
                    }
                    
                    contentView.removeConstraint(constraint as! NSLayoutConstraint)
                    
                    let newConstraint : NSLayoutConstraint = NSLayoutConstraint(item: newFirstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: newSecondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
                    newConstraint.shouldBeArchived = constraint.shouldBeArchived
                    contentView.addConstraint(newConstraint)
                }
                
            }
            //        } else {
            //            // LPLog("Content view has no constraints");
            //            contentViewHasConstraints = false
        }
        
        
        //        if ( animated ) {
        //            NSAnimationContext.runAnimationGroup({ context in
        //                // Customize the animation parameters.
        //                context.duration = 1.25
        //                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        //                contentView.replaceSubview(oldView, with: newView)
        //                }, completionHandler: {
        //            })
        //        } else {
        //          contentView.replaceSubview(oldView, with: newView)
        //        }
        
        // Reemplazo la vista antigua con la nueva
        contentView.replaceSubview(oldView, with: newView)
        
        // Just in case content view didn't have constraints... let's add them
        //        if contentViewHasConstraints == false {
        //            [newView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //            [[self class] addEdgeConstraint:NSLayoutAttributeLeft superview:contentView subview:newView];
        //            [[self class] addEdgeConstraint:NSLayoutAttributeRight superview:contentView subview:newView];
        //            [[self class] addEdgeConstraint:NSLayoutAttributeTop superview:contentView subview:newView];
        //            [[self class] addEdgeConstraint:NSLayoutAttributeBottom superview:contentView subview:newView];
        //        }
    }
}
