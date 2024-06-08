//
//  DLL.swift
//
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation

public class DLL {
    
    public var head: Node?
    public var tail: Node?
    
    public init() { }
    
    public func remove(_ node: Node) {
        if node === head {
            popHead()
            return
        }
        if node === tail {
            popTail()
            return
        }
        let prev = node.prev
        let next = node.next
        prev?.next = next
        next?.prev = prev
    }
    
    @discardableResult
    public func popHead() -> Node? {
        let oldHead = head
        let newHead = head?.next
        newHead?.prev = nil
        head = newHead
        if head == nil {
            tail = nil
        }
        return oldHead
    }
    
    @discardableResult
    public func popTail() -> Node? {
        let oldTail = tail
        let newTail = tail?.prev
        newTail?.next = nil
        tail = newTail
        if tail == nil {
            head = nil
        }
        return oldTail
    }
    
    public func insertHead(_ node: Node) {
        if head == nil && tail == nil {
            head = node
            tail = node
            return
        }
        
        node.next = head
        head?.prev = node
        head = node
    }
    
    public func removeAll() {
        var curNode = head
        while curNode != nil {
            let next = curNode?.next
            curNode?.prev = nil
            curNode?.next = nil
            curNode = next
        }
        head = nil
        tail = nil
    }
}
