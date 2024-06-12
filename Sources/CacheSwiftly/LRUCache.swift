//
//  LRUCache.swift
//
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation

public class LRUCache<V>: Cachable {
    public typealias Value = V
    public typealias Key = String
    
    public var cache: [Key: LRUNode<CacheEntry>] = [:]
    public var costLeft_: Int
    public var costLeft: Int {
        queue.sync {
            costLeft_
        }
    }
    
    public let costLimit: Int
    let lru: DLL = .init()
    let queue = DispatchQueue(label: "cache_race_condition_queue", attributes: [.concurrent], target: .global(qos: .background))
    
    public struct CacheEntry {
        public var value: V
        public var cost: Int
    }
    
    public init(costLimit: Int) {
        self.costLimit = costLimit
        self.costLeft_ = costLimit
    }
    
    public func setValue(_ value: V, forKey key: Key, cost: Int) throws {
        removeValue(forKey: key)
        try release(cost: cost)
        let entry = CacheEntry(value: value, cost: cost)
        let node = LRUNode(value: entry)
        insertToCache(node, key: key)
        decreaseCostLeft(cost)
        lru.insertHead(node)
    }

    public func value(forKey key: Key) async throws -> V? {
        if let node = node(for: key) {
            lru.remove(node)
            lru.insertHead(node)
            return node.value.value
        }
        return nil
    }
    
    public func removeValue(forKey key: Key) {
        if let removedNode = removeFromCache(for: key) {
            let releasedCost = removedNode.value.cost
            increaseCostLeft(releasedCost)
            lru.remove(removedNode)
        }
    }
    
    public func removeAllValues() throws {
        lru.removeAll()
        queue.sync(flags: .barrier) {
            cache.removeAll()
        }
    }
    
    public subscript(_ key: Key) -> V? {
        queue.sync {
            cache[key]?.value.value
        }
    }
    
    private func release(cost: Int) throws {
        guard cost <= costLimit else {
            throw CacheErrors.exceededCostLimit
        }
        while cost > costLeft {
            guard let removedNode = lru.popHead() as? LRUNode<CacheEntry> else {
                fatalError("CacheSwiftly.Cache<V>.Error: got wrong lru node type in file:\(#file) line: \(#line)")
            }
            let releasedCost = getCost(from: removedNode)
            increaseCostLeft(releasedCost)
        }
    }
    
    private func insertToCache(_ node: LRUNode<CacheEntry>, key: Key) {
        queue.sync(flags: .barrier) {
            cache[key] = node
        }
    }
    
    private func removeFromCache(for key: Key) -> LRUNode<CacheEntry>? {
        queue.sync(flags: .barrier) {
            cache.removeValue(forKey: key)
        }
    }
    
    private func decreaseCostLeft(_ amount: Int) {
        queue.sync(flags: .barrier) {
            costLeft_ -= amount
        }
    }
    
    private func node(for key: Key) -> LRUNode<CacheEntry>? {
        queue.sync {
            cache[key]
        }
    }
    
    private func increaseCostLeft(_ amount: Int) {
        queue.sync(flags: .barrier) {
            costLeft_ += amount
        }
    }
    
    private func getCost(from node: LRUNode<CacheEntry>) -> Int {
        queue.sync {
            node.value.cost
        }
    }
}
