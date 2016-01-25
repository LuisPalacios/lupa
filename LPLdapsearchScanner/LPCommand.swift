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
//    var cmdState     : Bool = false
    
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
    
            //
            var lines : [String] = []
            
            // Go for it
            if shellcommand != "" {
                
                // Create a new task
                self.task = newtask(shellcommand)
                
                // Pipe the standard out to an NSPipe, and set it to notify us when it gets data
                let pipe = NSPipe()
                task.standardOutput = pipe
                let outHandle = pipe.fileHandleForReading
                outHandle.waitForDataInBackgroundAndNotify()
                
                // Shortcut to notification center
                let notifCenter = NSNotificationCenter.defaultCenter()
                
                // Observe for PIPE DATA
                var obsrvData : NSObjectProtocol!
                obsrvData = notifCenter.addObserverForName(NSFileHandleDataAvailableNotification,
                    object: outHandle,
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: { ( notification ) -> Void in
                        
//                        print("----------------------------------------- PIPE DATA")
                        let data = outHandle.availableData
                        if data.length > 0 {
                            if let nsstr = NSString(data: data, encoding: NSUTF8StringEncoding) {
                                // Store the new lines
//                                print("\(nsstr)")
                                let str : String = nsstr as String
                                let newLines = str.characters.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
                                lines.appendContentsOf(newLines)
                            }
                            outHandle.waitForDataInBackgroundAndNotify()
                        } else {
                            // We are done!, call notification handler
//                            print("----------------------------------------- PIPE EOF")
                            notifCenter.removeObserver(obsrvData)
                            completionHandler(success: true, output: lines )
                        }
                        
                })
                
                // Observe for PIPE TERMINATION
                //
                var obsrvTerm : NSObjectProtocol!
                obsrvTerm = notifCenter.addObserverForName(NSTaskDidTerminateNotification,
                    object: task, queue: nil) { notification -> Void in
//                        print("----------------------------------------- PIPE TERMINATION")
                        notifCenter.removeObserver(obsrvTerm)
                }
                
                
                // Fire the following when task terminates
                //
                task.terminationHandler = {task -> Void in
//                    print("----------------------------------------- TASK TERMINATION")

                }

                // Launch the command
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
//        print("----------------------------------------- !!!!!!!!!!!!!!! TERMINATE CALLED !!!!!!!!!!!!")
        if ( self.task != nil ) {
            self.task.terminate()
        }
    }
    
    // Interrupt running command sending CTRL-C (aka kill -2)
    func interrupt () {
//        print("----------------------------------------- !!!!!!!!!!!!!!! INTERRUPT CALLED !!!!!!!!!!!!")
        if ( self.task != nil ) {
            self.task.interrupt()
        }
    }
    
    
    

}
