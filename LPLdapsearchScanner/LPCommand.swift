//
//  LPCommand.swift
//  lupa
//
//  Created by Luis Palacios on 27/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Foundation

private func newtask (shellcommand: String) -> NSTask {
    let task = NSTask()
    task.arguments = ["-c", shellcommand]
    task.launchPath = "/bin/bash"
    
    return task
}

// TODO: explain thoroughly why this local state monstrosity is necessary.
// Summary: it is used exclusively for sending a stream through the forward operator and use it as standardInput in a run command.
// Required to enable "func run (shellcommand: String) -> ReadableStreamType" to also be run by itself on a single line.
private var _nextinput_: ReadableStreamType?

///**
//Specific handling of func run (shellcommand: String) -> ReadableStreamType on the right side using the stream on the
//left side as standard input.
//Warning: is only meant to be used with the "run" command, but could also unintentionally catch other uses of
//"ReadableStreamType |> ReadableStreamType", though that statement doesn't make any sense.
//*/
//public func |> (lhs: ReadableStreamType, @autoclosure rhs:  () -> ReadableStreamType) -> ReadableStreamType {
//    assert(_nextinput_ == nil)
//    _nextinput_ = lhs
//    let result = rhs()
//    if _nextinput_ != nil {
//        printErrorAndExit("The statement 'ReadableStreamType |> ReadableStreamType' is invalid.")
//    }
//    return result
//}

/**
Run a shell command synchronously with no standard input,
or if to the right of a "ReadableStreamType |> ", use the stream on the left side as standard input.
- returns: Standard output
*/
public func run (shellcommand: String) -> ReadableStreamType {
    let task = newtask(shellcommand)
    
    if let input = _nextinput_ {
        task.standardInput = input as! FileHandle
        _nextinput_ = nil
    } else {
        // avoids implicit reading of the main script's standardInput
        task.standardInput = NSPipe ()
    }
    
    let output = NSPipe ()
    task.standardOutput = output
    task.launch()
    
    // necessary for now to ensure one shellcommand is finished before another begins.
    // uncontrolled asynchronous shell processes could be messy.
    // but shell commands on the same line connected with the pipe operator should preferably be asynchronous.
    task.waitUntilExit()
    
    return output.fileHandleForReading
}
