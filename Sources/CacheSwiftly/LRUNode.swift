//
//  LRUNode.swift
//  
//
//  Created by Mira Yang on 6/7/24.
//

import Foundation

public final class LRUNode<Value>: Node {
    
    public var value: Value
    public var next: Node?
    public var prev: Node?
    
    public init(value: Value) {
        self.value = value
    }
    
    private enum CodingKeys: String, CodingKey {
        case value, nextValue, prevValue
    }

    public required init(from decoder: Decoder) throws where Value: Codable {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Value.self, forKey: .value)
        next = nil
        prev = nil
    }

    public func encode(to encoder: Encoder) throws where Value: Codable {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        if let nextNode = next as? LRUNode<Value> {
            try container.encode(nextNode.value, forKey: .nextValue)
        }
        if let prevNode = prev as? LRUNode<Value> {
            try container.encode(prevNode.value, forKey: .prevValue)
        }
    }
}

extension LRUNode: Codable where Value: Codable { }
