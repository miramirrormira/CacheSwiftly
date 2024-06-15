//
//  MemoryCache.swift
//
//
//  Created by Mira Yang on 6/12/24.
//

import Foundation

public class MemoryCache<V>: Cachable {
    public typealias Value = V
    public typealias Key = String
    
    public var cache: NSCache<NSString, CacheEntry<V>> = .init()
    
    public init(cache: NSCache<NSString, CacheEntry<V>> = .init()) {
        self.cache = cache
    }
    
    public func setValue(_ value: V, forKey key: Key, cost: Int) throws {
        cache.setObject(CacheEntry(value: value, cost: cost), forKey: key as NSString, cost: cost)
    }

    public func value(forKey key: Key) async throws -> V? {
        cache.object(forKey: key as NSString)?.value
    }
    
    public func removeValue(forKey key: Key) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func removeAllValues() throws {
        cache.removeAllObjects()
    }
    
    public subscript(_ key: Key) -> V? {
        cache.object(forKey: key as NSString)?.value
    }
}
