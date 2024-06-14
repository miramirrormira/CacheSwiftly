//
//  DiskCache.swift
//  
//
//  Created by Mira Yang on 6/12/24.
//

import Foundation

public class DiskCache<V: Codable>: Cachable {
    
    
    public typealias Value = V
    
    var keys: Set<Key> = []
    let label: String
    var costLimit: Int
    var costLeft: Int
    var metaDataFileName: String {
        "metaData.cache"
    }
    
    init(label: String, costLimit: Int) throws {
        self.label = label
        self.costLimit = costLimit
        self.costLeft = costLimit
        
        if let metaData = try FileIO.loadDataFrom(file: metaDataFileName, folderName: label) {
            let decodedMetaData = try JSONDecoder().decode(DiskCacheMetaData.self, from: metaData)
            self.keys = decodedMetaData.keys
            self.costLeft = decodedMetaData.costLeft
        }
    }
    
    struct DiskCacheMetaData: Codable {
        var keys: Set<Key>
        var costLeft: Int
    }
    
    public func setValue(_ value: V, forKey key: Key, cost: Int) throws {
        let encoded = try JSONEncoder().encode(CacheEntry(value: value, cost: cost))
        try FileIO.saveData(encoded, fileName: key, folderName: label)
        keys.insert(key)
    }
    
    public func value(forKey key: Key) throws -> V? {
        if let data = try FileIO.loadDataFrom(file: key, folderName: label) {
            return try JSONDecoder().decode(CacheEntry<V>.self, from: data).value
        }
        return nil
    }
    
    public func removeValue(forKey key: Key) throws {
        try FileIO.removeFile(fileName: key, folderName: label)
        keys.remove(key)
    }
    
    public func removeAllValues() throws {
        for key in keys {
            try removeValue(forKey: key)
        }
    }
    
    public subscript(key: Key) -> V? {
        get throws {
            try value(forKey: key)
        }
    }
    
    private func filePath(for key: Key) -> String {
        "/\(label)/\(key).cache"
    }
    
    deinit {
        do {
            let metaData = DiskCacheMetaData(keys: keys, costLeft: costLeft)
            let encodedMetaData = try JSONEncoder().encode(metaData)
            try FileIO.saveData(encodedMetaData, fileName: metaDataFileName, folderName: label)
        } catch {
            print("CacheSwiftly.DiskCache.deinit: \(error.localizedDescription)")
        }
    }
}

