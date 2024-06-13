//
//  CacheEntry.swift
//  
//
//  Created by Mira Yang on 6/12/24.
//

import Foundation

public final class CacheEntry<V> {
    
    public typealias Key = String
    
    public var value: V
    public var cost: Int
    public var lruNode: LRUNode<Key>?
    public var createdAt: Date
    
    init(value: V, cost: Int) {
        self.value = value
        self.cost = cost
        self.createdAt = Date()
    }
}

extension CacheEntry: Codable where V: Codable { }
