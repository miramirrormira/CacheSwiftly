//
//  MemoryCache.swift
//
//
//  Created by Mira Yang on 6/12/24.
//

import Foundation

public class MemoryCache<V: AnyObject>: Cachable {
    public typealias Value = V
    public typealias Key = String
    
    public var cache: NSCache<NSString, V> = .init()
    
    public func setValue(_ value: V, forKey key: Key, cost: Int) throws {
        cache.setObject(value, forKey: key as NSString, cost: cost)
    }

    public func value(forKey key: Key) async throws -> V? {
        cache.object(forKey: key as NSString)
    }
    
    public func removeValue(forKey key: Key) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func removeAllValues() throws {
        cache.removeAllObjects()
    }
    
    public subscript(_ key: Key) -> V? {
        cache.object(forKey: key as NSString)
    }
}
