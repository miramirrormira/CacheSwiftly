@testable import CacheSwiftly
import XCTest

final class DiskCacheTests: XCTestCase {
    
    let cacheLabel = "diskCache"
    
    override func setUp() async throws {
        try FileIO.clearFolder(cacheLabel)
        try await super.setUp()
    }

    func test_init_costLeftAndCostLimitShouldHaveInitializedValue() throws {
        let sut = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        XCTAssertEqual(sut.costLeft, 10)
        XCTAssertEqual(sut.costLimit, 10)
    }
    
    func test_deinit_shouldSaveMetaDataFile() throws {
        let path = try FileIO.filePath(fileName: "metaData.cache", folderName: cacheLabel)
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
        var sut: DiskCache<Int>? = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        sut = nil
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    }
    
    func test_init_shouldLoadSavedMetaData() throws {
        var sut: DiskCache<Int>? = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        sut?.costLeft = 5
        try sut?.setValue(0, forKey: "0", cost: 0)
        sut = nil
        sut = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        XCTAssertEqual(sut?.costLeft, 5)
        XCTAssertEqual(sut?.costLimit, 10)
        XCTAssertEqual(sut?.keys.count, 1)
    }
    
    func test_removeValue_withKey0Value0() throws {
        let sut = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        try sut.setValue(0, forKey: "0", cost: 0)
        try sut.removeValue(forKey: "0")
        let path = try FileIO.filePath(fileName: "0", folderName: cacheLabel)
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
        XCTAssertFalse(sut.keys.contains("0"))
    }
    
    func test_setValue_withKey0Value0_shouldSaveFile() throws {
        let sut = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        try sut.removeAllValues()
        try sut.setValue(0, forKey: "0", cost: 0)
        let path = try FileIO.filePath(fileName: "0", folderName: cacheLabel)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
        let cachedFile = try FileIO.loadDataFrom(file: "0", folderName: cacheLabel)
        let decodedFile = try JSONDecoder().decode(CacheEntry<Int>.self, from: cachedFile!)
        XCTAssertEqual(decodedFile.cost, 0)
        XCTAssertEqual(decodedFile.value, 0)
        XCTAssertTrue(sut.keys.contains("0"))
    }
    
    func test_setValue_withKey0Value0ThenKey0Value1_shouldSaveNewFile() throws {
        
        let sut = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        try sut.removeAllValues()
        
        try sut.setValue(0, forKey: "0", cost: 0)
        try sut.setValue(1, forKey: "0", cost: 0)
        
        let path = try FileIO.filePath(fileName: "0", folderName: cacheLabel)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
        let cachedFile = try FileIO.loadDataFrom(file: "0", folderName: cacheLabel)
        let decodedFile = try JSONDecoder().decode(CacheEntry<Int>.self, from: cachedFile!)
        XCTAssertEqual(decodedFile.cost, 0)
        XCTAssertEqual(decodedFile.value, 1)
        XCTAssertTrue(sut.keys.contains("0"))
    }
    
    func test_value_withNonExistingKey_shouldReturnNil() throws {
        let sut = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        let value = try sut.value(forKey: "0")
        XCTAssertNil(value)
    }
    
    func test_value_withExistingKey0Value0_shouldReturnTheCorrectValue() throws {
        let sut = try DiskCache<Int>(label: cacheLabel, costLimit: 10)
        try sut.setValue(0, forKey: "0", cost: 0)
        let value = try sut.value(forKey: "0")
        XCTAssertEqual(value, 0)
    }
}
