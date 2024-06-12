//
//  Cachable.swift
//  
//
//  Created by Mira Yang on 6/12/24.
//

import Foundation

public protocol Cachable {
    associatedtype Value
    typealias Key = String
    func setValue(_ value: Value, forKey key: Key, cost: Int) throws
    func value(forKey key: Key) async throws -> Value?
    func removeValue(forKey key: Key)
    func removeAllValues() throws
}
