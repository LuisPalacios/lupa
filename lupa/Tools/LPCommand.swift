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
    var taskTerminateRequested = false
    // private var _nextinput_: ReadableStreamType?
    
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
    // MARK: Execute command
    // --------------------------------------------------------------------------------
    
    /// Go ahead and execute the command...
    ///
    func run( shellcommand: String,
        completionHandler: ( exit: Int, stdout: [String], stderr: [String] ) -> Void ) {
    
            //
            var linesStandardOutput : [String]  = []
            //var hasStandardOutput               = false
            var linesStandardError  : [String]  = []
            //var hasStandardError                = false

            
            // Go for it
            if shellcommand != "" {
                
                // Create a new task
                self.task = newtask(shellcommand)
                
                // Just created the task so initiatlize false
                self.taskTerminateRequested = false
                
                // Shortcut to notification center
                let notifCenter = NSNotificationCenter.defaultCenter()
                
                // ---- STANDARD OUTPUT -------
                // Pipe the stdout (Standard Output) to an NSPipe, 
                // and set it to notify us when it gets data
                let pipeStandardOutput = NSPipe()
                task.standardOutput = pipeStandardOutput
                let stdoutHandle = pipeStandardOutput.fileHandleForReading
                stdoutHandle.waitForDataInBackgroundAndNotify()
                
                // Observe for DATA on the Standard Output
                var obsrvStdoutData : NSObjectProtocol!
                obsrvStdoutData = notifCenter.addObserverForName(NSFileHandleDataAvailableNotification,
                    object: stdoutHandle,
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: { ( notification ) -> Void in
                        
                        // print("----------------------------------------- pipeStandardOutput DATA")
                        let data = stdoutHandle.availableData
                        if data.length > 0 {
                            if let nsstr = NSString(data: data, encoding: NSUTF8StringEncoding) {
                                // Store the new lines
                                // print("<stdout>\(nsstr)</stdout>")
                                let str : String = nsstr as String
                                let newLines = str.characters.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
                                linesStandardOutput.appendContentsOf(newLines)
                                //hasStandardOutput = true
                            }
                            stdoutHandle.waitForDataInBackgroundAndNotify()
                        } else {
                            // We are done!, call notification handler
                            // print("----------------------------------------- pipeStandardOutput EOF")
                            notifCenter.removeObserver(obsrvStdoutData)
                            var terminationStatus : Int = 0
                            if ( self.taskTerminateRequested == true ||
                                self.task.terminationStatus == 255 ) {
                                terminationStatus = Int(self.task.terminationStatus)
                            }
                            // print("terminationStatus:\(terminationStatus)")
                            completionHandler(exit: terminationStatus, stdout: linesStandardOutput, stderr: linesStandardError )
                        }
                        
                })
                
                
                // ---- STANDARD ERROR -------
                // Pipe the stderr (Standard Error) to a different NSPipe,
                // and set it to notify us when it gets data
                let pipeStandardError = NSPipe()
                task.standardError = pipeStandardError
                let stderrHandle = pipeStandardError.fileHandleForReading
                stderrHandle.waitForDataInBackgroundAndNotify()
                
                
                // Observe for DATA on the Standard Error
                var obsrvStderrData : NSObjectProtocol!
                obsrvStderrData = notifCenter.addObserverForName(NSFileHandleDataAvailableNotification,
                    object: stderrHandle,
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: { ( notification ) -> Void in
                        
                        // print("----------------------------------------- pipeStandardError DATA")
                        let data = stderrHandle.availableData
                        if data.length > 0 {
                            if let nsstr = NSString(data: data, encoding: NSUTF8StringEncoding) {
                                // Store the new lines
                                // print("<stderr>\(nsstr)</stderr>")
                                let str : String = nsstr as String
                                let newLines = str.characters.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
                                linesStandardError.appendContentsOf(newLines)
                                //hasStandardError = true
                            }
                            stderrHandle.waitForDataInBackgroundAndNotify()
                        } else {
                            // We are done!, remove observer
                            // print("----------------------------------------- pipeStandardError EOF")
                            //print("<stderrLinesError>\(linesStandardError)</stderrLinesError>")
                            notifCenter.removeObserver(obsrvStderrData)
                        }
                        
                })
                
                // Observe for TASK TERMINATION
                //
                var obsrvTerm : NSObjectProtocol!
                obsrvTerm = notifCenter.addObserverForName(NSTaskDidTerminateNotification,
                    object: task, queue: nil) { notification -> Void in
                        // print("----------------------------------------- TASK TERMINATION (no status)")
                        notifCenter.removeObserver(obsrvTerm)
                }
                
                
                // Fire the following when task terminates
                //
                task.terminationHandler = {task -> Void in
                    // print("----------------------------------------- TASK TERMINATION:  \(task.terminationStatus)")
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
    
    // Interrupt command sending SIGTERM (aka kill -15)
    func terminate () {
        // print("----------------------------------------- !!!!!!!!!!!!!!! TERMINATE CALLED !!!!!!!!!!!!")
        if ( self.task != nil ) {
            self.task.terminate()
            self.taskTerminateRequested = true
        }
    }
    
    // Interrupt command sending CTRL-C (aka kill -2)
    func interrupt () {
        // print("----------------------------------------- !!!!!!!!!!!!!!! INTERRUPT CALLED !!!!!!!!!!!!")
        if ( self.task != nil ) {
            self.task.interrupt()
        }
    }
    
    
    

}
