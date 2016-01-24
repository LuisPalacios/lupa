//
//  LPCommand.swift
//  lupa
//
//  Created by Luis Palacios on 27/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//
import Foundation

class LPCommand : NSObject {
    
    // --------------------------------------------------------------------------------
    // MARK: Attributes
    // --------------------------------------------------------------------------------
    
    // Attributes
    var task : NSTask!
    private var _nextinput_: ReadableStreamType?
    var cmdState     : Bool = false
    
    // --------------------------------------------------------------------------------
    // MARK: Execute
    // --------------------------------------------------------------------------------
    
    // Create a new task
    //
    private func newtask (shellcommand: String) -> NSTask {
        let ntask = NSTask()
        ntask.arguments = ["-c", shellcommand]
        ntask.launchPath = "/bin/bash"
        
        return ntask
    }
    
 
    
    // --------------------------------------------------------------------------------
    // MARK: Run...
    // --------------------------------------------------------------------------------
    
    /// Go ahead and run the command...
    ///
    func run( shellcommand: String,
        completionHandler: ( success: Bool, output: [String] ) -> Void ) {
    
            self.cmdState = false
            
            // Go for it
            if shellcommand != "" {
                
                // Create a new task
                self.task = newtask(shellcommand)
                
                // Pipe the standard out to an NSPipe, and set it to notify us when it gets data
                let pipe = NSPipe()
                task.standardOutput = pipe
                let fh = pipe.fileHandleForReading
                fh.waitForDataInBackgroundAndNotify()
                
                // Set up the observer function
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.addObserverForName(NSFileHandleDataAvailableNotification,
                    object: nil,
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: { ( theNotification ) -> Void in
                        
                        // Block to execute when pipe finishes
                        // print("Block inside notification: Removing observer")
                        
                        // Clean up the observer function
                        let notificationCenter = NSNotificationCenter.defaultCenter()
                        notificationCenter.removeObserver(self)
                        
                        // Unpack the FileHandle from the notification
                        if let fh:NSFileHandle = theNotification.object as? NSFileHandle {
                            
                            
                            // Get the data from the FileHandle
                            let data = fh.availableData
                            // Only deal with the data if it actually exists
                            if data.length > 1 {
                                
                                // We got something so change state
                                self.cmdState = true
                                
                                // Since we just got the notification from fh, we must tell it to notify us again when it gets more data
                                fh.waitForDataInBackgroundAndNotify()
                                
                                // Convert the data into a string
                                let nsstring = NSString(data: data, encoding: NSASCIIStringEncoding)
                                
                                if let str = nsstring as? String {
                                    
                                    // Prepare the array of lines to return...
                                    let lines = str.characters.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
                                    completionHandler(success: self.cmdState, output: lines )
                                    
                                }
                                
                            }
                        }
                })
                
                // Fire the following when task terminates
                //
                task.terminationHandler = {task -> Void in
                    
                    // print("Handling the task ending here")
                    
                    // Handle the task ending here
                    // print("TASK terminationHandler: Removing observer")
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.removeObserver(self)
                    
                    
                }
                
                // print("Launching...")
                task.launch()
                
            }
    }
    

    // --------------------------------------------------------------------------------
    // MARK: Signaling
    // --------------------------------------------------------------------------------
    
    // interrupt() SIGINT  = Signal 2  (Ctrl+C)
    // terminate() SIGTERM = Signal 15
    // SIGKILL = Signal 9
    
    // Interrupt running command sending SIGTERM (aka kill -15)
    func terminate () {
        print("ME PIDEN QUE TERMINE !!!!!")
        if ( self.task != nil ) {
            self.task.terminate()
        }
    }
    
    // Interrupt running command sending CTRL-C (aka kill -2)
    func interrupt () {
        print("ME PIDEN QUE INTERRUMPAAAAAAA !!!!!")
        if ( self.task != nil ) {
            self.task.interrupt()
        }
    }
    
    
    

}
