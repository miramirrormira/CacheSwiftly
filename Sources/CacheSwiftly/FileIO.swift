//
//  FileIO.swift
//
//
//  Created by Mira Yang on 6/13/24.
//

import Foundation
open class FileIO {
    
    // MARK: Search files
    static func filePath(fileName: String,
                         folderName: String = "",
                         directory: FileManager.SearchPathDirectory = .documentDirectory,
                         domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws -> String {
        
        let cleanFolderName: String = cleanFolderName(folderName)
        try createFolder(folderName)
        let appendPath = cleanFolderName == "" ? fileName : "/\(cleanFolderName)/" + fileName
        return try FileManager.default.url(for: directory, in: domainMask, appropriateFor: nil, create: true).path + appendPath
    }
    
    static func removeFile(fileName: String,
                           folderName: String = "",
                           directory: FileManager.SearchPathDirectory = .documentDirectory,
                           domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws {
        let path = try filePath(fileName: fileName, folderName: folderName, directory: directory, domainMask: domainMask)
        guard FileManager.default.fileExists(atPath: path) else {
            return
        }
        try FileManager.default.removeItem(atPath: path)
    }
    
    static func saveData(_ data: Data,
                         fileName: String,
                         folderName: String,
                         directory: FileManager.SearchPathDirectory = .documentDirectory,
                         domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws {
        let path = try filePath(fileName: fileName, folderName: folderName, directory: directory, domainMask: domainMask)
        let fileURL = URL(filePath: path)
        try data.write(to: fileURL, options: .atomicWrite)
    }
    
    static func loadDataFrom(file fileName: String,
                             folderName: String,
                             directory: FileManager.SearchPathDirectory = .documentDirectory,
                             domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws -> Data? {
        let path = try filePath(fileName: fileName, folderName: folderName, directory: directory, domainMask: domainMask)
        let url = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: url) {
            return data
        }
        return nil
    }
    
    static func cleanFolderName(_ folderName: String) -> String {
        var cleanFolderName: String = folderName
        if cleanFolderName.first == "/" {
            cleanFolderName = String(cleanFolderName.dropFirst())
        }
        if cleanFolderName.last == "/" {
            cleanFolderName = String(cleanFolderName.dropLast())
        }
        return cleanFolderName
    }
    
    static func createFolder(_ folderName: String,
                             directory: FileManager.SearchPathDirectory = .documentDirectory,
                             domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws {
        guard folderName != "" else { return }
        let cleanFolderName: String = cleanFolderName(folderName)
        guard let directoryURL = FileManager.default.urls(for: directory, in: domainMask).first else {
            throw FileErrors.cannotFindDirectory
        }
        let folderURL = directoryURL.appending(path: cleanFolderName)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }
    
    static func clearFolder(_ folderName: String,
                            directory: FileManager.SearchPathDirectory = .documentDirectory,
                            domainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws {
        let cleanFolderName: String = cleanFolderName(folderName)
        guard let directoryURL = FileManager.default.urls(for: directory, in: domainMask).first else {
            throw FileErrors.cannotFindDirectory
        }
        let folderURL = directoryURL.appending(path: cleanFolderName)
        let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        for file in files {
            try FileManager.default.removeItem(at: file)
        }
    }
}
