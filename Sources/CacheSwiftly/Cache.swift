//
//  Cache.swift
//
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation

public class Cache<V> {
   
    public typealias Key = String
    
    public var cache: [Key: LRUNode<CacheEntry>] = [:]
    public var costLimit: Int
    public var costLeft: Int
    public var lru: DLL = .init()
    
    public struct CacheEntry {
        public var value: V
        public var cost: Int
    }
    
    init(costLimit: Int) {
        self.costLimit = costLimit
        self.costLeft = costLimit
    }
    
    public func setValue(_ value: V, forKey key: Key, cost: Int) throws {
        removeValue(forKey: key)
        try releaseCostForEjecting(value, cost: cost)
        let entry = CacheEntry(value: value, cost: cost)
        let node = LRUNode(value: entry)
        cache[key] = node
        costLeft -= cost
        lru.insertHead(node)
    }
    
    func releaseCostForEjecting(_ value: V, cost: Int) throws {
        guard cost <= costLimit else {
            throw CacheErrors.exceededCostLimit
        }
        while cost > costLeft {
            if let removedNode = lru.popHead(), let lruNode = removedNode as? LRUNode<CacheEntry> {
                let releasedCost = lruNode.value.cost
                costLeft += releasedCost
            }
        }
    }
    
    public func value(forKey key: Key) -> V? {
        guard let node = cache[key] else {
            return nil
        }
        lru.remove(node)
        lru.insertHead(node)
        return node.value.value
    }
    
    public func removeValue(forKey key: Key) {
        if let removedNode = cache.removeValue(forKey: key) {
            let releasedCost = removedNode.value.cost
            costLeft += releasedCost
            lru.remove(removedNode)
        }
    }
    
    public func removeAllValues() throws {
        cache.removeAll()
        lru.removeAll()
    }
}
