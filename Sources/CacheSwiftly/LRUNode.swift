//
//  LRUNode.swift
//  
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation

public class LRUNode<Value>: Node {
    public var value: Value
    public var next: Node?
    public var prev: Node?
    public init(value: Value) {
        self.value = value
    }
}
