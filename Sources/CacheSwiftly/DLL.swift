//
//  DLL.swift
//
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation

public class DLL {
    
    var head_: Node?
    var tail_: Node?
    private let threadSafetyQueue = DispatchQueue(label: "CacheSwiftly.DLL.threadSafetyQueue")
    
    public init() { }
    
    public var head: Node? {
        threadSafetyQueue.sync {
            head_
        }
    }
    
    public var tail: Node? {
        threadSafetyQueue.sync {
            tail_
        }
    }
    
    public func remove(_ node: Node) {
        threadSafetyQueue.sync {
            let prev = node.prev
            let next = node.next
            prev?.next = next
            next?.prev = prev
            if node === head_ {
                head_ = next
                if head_ == nil {
                    tail_ = nil
                }
                return
            }
            if node === tail_ {
                tail_ = prev
                return
            }
        }
    }
    
    @discardableResult
    public func popHead() -> Node? {
        threadSafetyQueue.sync {
            let oldHead = head_
            let newHead = head_?.next
            newHead?.prev = nil
            head_ = newHead
            if head_ == nil {
                tail_ = nil
            }
            return oldHead
        }
    }
    
    @discardableResult
    public func popTail() -> Node? {
        threadSafetyQueue.sync {
            let oldTail = tail_
            let newTail = tail_?.prev
            newTail?.next = nil
            tail_ = newTail
            if tail_ == nil {
                head_ = nil
            }
            return oldTail
        }
    }
    
    public func insertHead(_ node: Node) {
        threadSafetyQueue.sync {
            if head_ == nil && tail_ == nil {
                head_ = node
                tail_ = node
                return
            }
            node.next = head_
            head_?.prev = node
            head_ = node
        }
    }
    
    public func removeAll() {
        threadSafetyQueue.sync {
            var curNode = head_
            while curNode != nil {
                let next = curNode?.next
                curNode?.prev = nil
                curNode?.next = nil
                curNode = next
            }
            head_ = nil
            tail_ = nil
        }
    }
}
