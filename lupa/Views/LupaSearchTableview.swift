//
//  LupaSearchTableview.swift
//  lupa
//
//  Created by Luis Palacios on 26/1/16.
//  Copyright © 2016 Luis Palacios. All rights reserved.
//

import Cocoa


// Protocol that allows me to call my own delegate
protocol LupaSearchTableviewDelegate {
    func tableView(tableview:NSTableView, clickedRow:NSInteger, clickedColumn:NSInteger, clickedPoint:NSPoint, clickedRect:NSRect)
//    func tableView(tableview:NSTableView, doubleClickedRow:NSInteger, clickedColumn:NSInteger)
}

// My Class
class LupaSearchTableview: NSTableView {
    
    // Delegate I'll call
    var lupaSearchTableviewDelegate:LupaSearchTableviewDelegate?
    
//    // Double click left Mouse
//    //
//    override func mouseDown(theEvent: NSEvent) {
//        // Super's
//        super.mouseDown(theEvent)
//        
//        // If double clicked
//        if (theEvent.clickCount == 2) {
//            
//            let globalLocation  : NSPoint       = theEvent.locationInWindow
//            let clickedPoint    : NSPoint       = self.convertPoint(globalLocation, fromView: nil)
//            let clickedRow      : NSInteger     = self.rowAtPoint(clickedPoint)
//            let clickedColumn   : NSInteger     = self.columnAtPoint(clickedPoint)
//            let clickedRect     : NSRect        = self.frameOfCellAtColumn(clickedColumn, row: clickedRow)
//            
//            
//            // Double Click on the "DID" Column
//            let columnDID : NSInteger = self.columnWithIdentifier("DID")
//            if ( columnDID != -1 ) {
//                if ( columnDID == clickedColumn ) {
//                    let indexSet : NSIndexSet = NSIndexSet(index: clickedRow)
//                    self.selectRowIndexes(indexSet, byExtendingSelection: false)
//                    
//                    // Swift.print("ABTranTableView - Double click! col:%d row:%d indexSet:%d", clickedColumn, clickedRow, indexSet)
//                    
//                    
//                    // Call the delegate
//                    if let delegate = abTranTableViewDelegate {
//                        // delegate.tableView(self, clickedRow: clickedRow, clickedColumn: clickedColumn, clickedPoint: clickedPoint, clickedRect: clickedRect)
//                        delegate.tableView(self, doubleClickedRow: clickedRow, clickedColumn: clickedColumn)
//                    }
//                } else {
//                    
//                    // Simulate a rightMouseDown and show the detailed Transaction information
//                    
//                    // Call the delegate
//                    if let delegate = abTranTableViewDelegate {
//                        
//                        // Show the detailed Transaction information
//                        delegate.tableView(self, clickedRow: clickedRow, clickedColumn: clickedColumn, clickedPoint: clickedPoint, clickedRect: clickedRect)
//                    }
//                    
//                }
//            }
//        }
//    }
//    
    
    // Right Mouse
    //
    override func  rightMouseDown(theEvent: NSEvent) {
        
        // Super's rightMouse
        super.rightMouseDown(theEvent)
        
        let globalLocation  : NSPoint   = theEvent.locationInWindow
        let clickedPoint    : NSPoint   = self.convertPoint(globalLocation, fromView: nil)
        let clickedRow      : NSInteger = self.rowAtPoint(clickedPoint)
        let clickedCol      : NSInteger = self.columnAtPoint(clickedPoint)
        let clickedRect     : NSRect    = self.frameOfCellAtColumn(clickedCol, row: clickedRow)
        
        // Call the delegate
        if ( clickedRow != -1 ) {
            if let delegate = lupaSearchTableviewDelegate {
                delegate.tableView(self, clickedRow: clickedRow, clickedColumn: clickedColumn, clickedPoint: clickedPoint, clickedRect: clickedRect)
            }
        }
    }
    
}
