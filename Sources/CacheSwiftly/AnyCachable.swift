//
//  AnyCachable.swift
//
//
//  Created by Mira Yang on 6/13/24.
//

import Foundation

public class AnyCachable<V>: Cachable {
    
    public typealias Value = V
    let wrappedSetValue: (V, Key, Int) throws -> Void
    let wrappedValue: (Key) async throws -> V?
    let wrappedRemoveValue: (Key) throws -> Void
    let wrappedRemoveAllValues: () throws -> Void
    
    public init<C: Cachable>(_ cachable: C) where C.Value == V {
        self.wrappedSetValue = cachable.setValue(_:forKey:cost:)
        self.wrappedValue = cachable.value(forKey:)
        self.wrappedRemoveValue = cachable.removeValue(forKey:)
        self.wrappedRemoveAllValues = cachable.removeAllValues
    }
    
    public func setValue(_ value: V, forKey key: Key, cost: Int) throws {
        try wrappedSetValue(value, key, cost)
    }
    
    public func value(forKey key: Key) async throws -> V? {
        try await wrappedValue(key)
    }
    
    public func removeValue(forKey key: Key) throws {
        try wrappedRemoveValue(key)
    }
    
    public func removeAllValues() throws {
        try wrappedRemoveAllValues()
    }
    
    public subscript(key: Key) -> V? {
        get async throws {
            try await wrappedValue(key)
        }
    }
}
