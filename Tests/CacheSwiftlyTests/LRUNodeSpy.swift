//
//  File.swift
//  
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation
import CacheSwiftly

class LRUNodeSpy<V>: Node {
    
    var next: Node?
    var prev: Node?
    var value: V
    
    var calledDeinit: () -> Void
    
    init(value: V, calledDeinit: @escaping () -> Void) {
        self.value = value
        self.calledDeinit = calledDeinit
    }
    
    deinit {
        calledDeinit()
    }
}
