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
    
    public typealias TimeInterval = Foundation.TimeInterval
    
    public static let Main = LPQueue(queue: DispatchQueue.main);
//    public static let Default = LPQueue(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default))
//    public static let Background = LPQueue(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background))
//    public static let BackgroundGroup = LPQueue(group: DispatchGroup(), queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background))

    public static let Default = LPQueue(queue: DispatchQueue.global(qos: .default))
    public static let Background = LPQueue(queue: DispatchQueue.global(qos: .background))
    public static let BackgroundGroup = LPQueue(group: DispatchGroup(), queue: DispatchQueue.global(qos: .background))
    
//    try qos: DispatchQoS.QoSClass.default instead of priority: DispatchQueue.GlobalQueuePriority.default
//
    
    public fileprivate(set) var queue: DispatchQueue!
    public fileprivate(set) var group: DispatchGroup!
    
    public init(queue: DispatchQueue = DispatchQueue(label: "org.parchis.LPQueue", attributes: [])) {
        self.queue = queue
    }

    public init(group: DispatchGroup, queue: DispatchQueue = DispatchQueue(label: "org.parchis.LPQueue", attributes: []) ) {
        self.queue = queue
        self.group = group
    }
    
    public func after(_ interval: Foundation.TimeInterval, block: @escaping () -> ()) {
        let dispatchTime = DispatchTime.now() + Double(Int64(interval * Foundation.TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: dispatchTime, execute: block)
    }

    public func async(_ block: @escaping () -> ()) {
        queue.async(execute: block)
    }
    
    public func async(_ block: @escaping () -> (), completion: @escaping () -> ()) {
        queue.async {
            block()
            completion()
        }
    }

    public func sync(_ block: () -> ()) {
        queue.sync(execute: block)
    }
    
    public func sync(_ block: () -> (), completion: () -> ()) {
        queue.sync {
            block()
            completion()
        }
    }

    public func group_async(_ block: @escaping () -> (), completion: () -> ()) {
        group.enter()
        let background = LPQueue.Background
        background.async(block, completion: {
            self.group.leave(); // Leave the group
        })
        completion()
    }

    public func group_notify(_ block: @escaping () -> ()) {
        group.notify(queue: queue) {
            block()
        }
    }
    
}
