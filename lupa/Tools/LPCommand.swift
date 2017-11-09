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
    var task : Process!
    var taskTerminateRequested = false
    // private var _nextinput_: ReadableStreamType?
    
    // --------------------------------------------------------------------------------
    // MARK: Execute
    // --------------------------------------------------------------------------------
    
    // Create a new task
    //
    fileprivate func newtask (_ shellcommand: String) -> Process {
        let ntask = Process()
        ntask.arguments = ["-c", shellcommand]
        ntask.launchPath = "/bin/bash"
        
        return ntask
    }
    
    // --------------------------------------------------------------------------------
    // MARK: Execute command
    // --------------------------------------------------------------------------------
    
    /// Go ahead and execute the command...
    ///
    func run( _ shellcommand: String,
        completionHandler: @escaping ( _ exit: Int, _ stdout: [String], _ stderr: [String] ) -> Void ) {
    
            //
            var linesStandardOutput : [String]  = []
            var linesStandardError  : [String]  = []
            
            // Go for it
            if shellcommand != "" {
                
                // Create a new task
                self.task = newtask(shellcommand)
                
                // Just created the task so initiatlize false
                self.taskTerminateRequested = false
                
                // Shortcut to notification center
                let notifCenter = NotificationCenter.default
                
                // ---- STANDARD OUTPUT -------
                // Pipe the stdout (Standard Output) to an NSPipe, 
                // and set it to notify us when it gets data
                let pipeStandardOutput = Pipe()
                task.standardOutput = pipeStandardOutput
                let stdoutHandle = pipeStandardOutput.fileHandleForReading
                stdoutHandle.waitForDataInBackgroundAndNotify()
                
                // Observe for DATA on the Standard Output
                var obsrvStdoutData : NSObjectProtocol!
                obsrvStdoutData = notifCenter.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                    object: stdoutHandle,
                    queue: OperationQueue.main,
                    using: { ( notification ) -> Void in
                        
                        // print("----------------------------------------- pipeStandardOutput DATA")
                        let data = stdoutHandle.availableData
                        if data.count > 0 {
                            if let nsstr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                // Store the new lines
                                // print("<stdout>\(nsstr)</stdout>")
                                let str : String = nsstr as String
                                let newLines = str.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
                                linesStandardOutput.append(contentsOf: newLines)
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
                            completionHandler(terminationStatus, linesStandardOutput, linesStandardError )
                        }
                        
                })
                
                
                // ---- STANDARD ERROR -------
                // Pipe the stderr (Standard Error) to a different NSPipe,
                // and set it to notify us when it gets data
                let pipeStandardError = Pipe()
                task.standardError = pipeStandardError
                let stderrHandle = pipeStandardError.fileHandleForReading
                stderrHandle.waitForDataInBackgroundAndNotify()
                
                
                // Observe for DATA on the Standard Error
                var obsrvStderrData : NSObjectProtocol!
                obsrvStderrData = notifCenter.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                    object: stderrHandle,
                    queue: OperationQueue.main,
                    using: { ( notification ) -> Void in
                        
                        // print("----------------------------------------- pipeStandardError DATA")
                        let data = stderrHandle.availableData
                        if data.count > 0 {
                            if let nsstr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                // Store the new lines
                                // print("<stderr>\(nsstr)</stderr>")
                                let str : String = nsstr as String
                                let newLines = str.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
                                linesStandardError.append(contentsOf: newLines)
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
                obsrvTerm = notifCenter.addObserver(forName: Process.didTerminateNotification,
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
