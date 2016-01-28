//
//  LPQueue.swift
//
//  Created by Luis Palacios on 15/11/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//
//  v0.1
//

import Dispatch
import Foundation

/// A simple wrapper around GCD queue.
///
public struct LPQueue {
    
    public typealias TimeInterval = NSTimeInterval
    
    public static let Main = LPQueue(queue: dispatch_get_main_queue());
    public static let Default = LPQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    public static let Background = LPQueue(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
    public static let BackgroundGroup = LPQueue(group: dispatch_group_create(), queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))

    public private(set) var queue: dispatch_queue_t!
    public private(set) var group: dispatch_group_t!
    
    public init(queue: dispatch_queue_t = dispatch_queue_create("org.parchis.LPQueue", DISPATCH_QUEUE_SERIAL)) {
        self.queue = queue
    }

    public init(group: dispatch_group_t, queue: dispatch_queue_t = dispatch_queue_create("org.parchis.LPQueue", DISPATCH_QUEUE_SERIAL) ) {
        self.queue = queue
        self.group = group
    }
    
    public func after(interval: NSTimeInterval, block: () -> ()) {
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, queue, block)
    }

    public func async(block: () -> ()) {
        dispatch_async(queue, block)
    }
    
    public func async(block: () -> (), completion: () -> ()) {
        dispatch_async(queue) {
            block()
            completion()
        }
    }

    public func sync(block: () -> ()) {
        dispatch_sync(queue, block)
    }
    
    public func sync(block: () -> (), completion: () -> ()) {
        dispatch_sync(queue) {
            block()
            completion()
        }
    }

    public func group_async(block: () -> (), completion: () -> ()) {
        dispatch_group_enter(group)
        let background = LPQueue.Background
        background.async(block, completion: {
            dispatch_group_leave(self.group); // Leave the group
        })
        completion()
    }

    public func group_notify(block: () -> ()) {
        dispatch_group_notify(group, queue) {
            block()
        }
    }
    
}
