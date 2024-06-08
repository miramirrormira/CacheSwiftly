@testable import CacheSwiftly
import XCTest

final class CacheTests: XCTestCase {

    func test_init_with_costLimit5_shouldGet5() throws {
        let costLimit = 5
        let sut = Cache<Int>(costLimit: costLimit)
        
        XCTAssertEqual(sut.costLimit, 5)
        XCTAssertEqual(sut.costLeft, sut.costLimit)
    }
    
    func test_setValue_withCost5CostLimit0_shouldThrowExceededCostLimitError() async {
        let sut = Cache<Int>(costLimit: 0)
        do {
            try sut.setValue(0, forKey: "", cost: 5)
        } catch let error as CacheErrors {
            XCTAssertEqual(error, CacheErrors.exceededCostLimit)
        } catch {
            XCTFail("wrong error")
        }
    }
    
    func test_setValue_withCost5CostLimit5CostLeft5_shouldReturnCostLeft0() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(0, forKey: "", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
    }
    
    func test_setValue_withCost5CostLimit5CostLeft0_shouldReturnCostLeft0() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(0, forKey: "1", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
        try sut.setValue(0, forKey: "2", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
    }
    
    func test_setValue_withCost5CostLimit5CostLeft2_shouldReturnCostLeft0() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(0, forKey: "1", cost: 3)
        XCTAssertEqual(sut.costLeft, 2)
        try sut.setValue(0, forKey: "2", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
    }
    
    func test_setValue_withKey1Value1_cacheShouldContainTheSameEntry() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        XCTAssertNotNil(sut.cache["1"])
        XCTAssertEqual(sut.cache["1"]?.value.value, 1)
    }
    
    func test_setValue_withExistingKey1Value1_setNewKey1Value2_shouldReplaceTheOldEntry() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        XCTAssertEqual(sut.cache["1"]?.value.value, 1)
        try sut.setValue(2, forKey: "1", cost: 0)
        XCTAssertEqual(sut.cache["1"]?.value.value, 2)
    }
    
    func test_setValue_withKey1Value1_lruHeadNodeShouldContainTheSameEntry() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        let entry = sut.lru.head as? LRUNode<Cache<Int>.CacheEntry>
        XCTAssertEqual(entry?.value.value, 1)
        XCTAssertEqual(entry?.value.cost, 0)
    }
    
    func test_valueForKey_withNonExistingKey1_shouldReturnNil() {
        let sut = Cache<Int>(costLimit: 5)
        let value = sut.value(forKey: "1")
        XCTAssertNil(value)
    }
    
    func test_valueForKey_withExistingKey1Value1Pair_shouldReturnValue1() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        let value = sut.value(forKey: "1")
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 1)
    }
    
    func test_valueForKey_withKey1Value1_lruHeadShouldContainTheSameEntry() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        let entry = sut.lru.head as? LRUNode<Cache<Int>.CacheEntry>
        XCTAssertEqual(entry?.value.value, 1)
    }
    
    func test_valueForKey_withExistingKey1Value1_setNewKey2Value2_lruHeadShouldContainKey2Value2() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        try sut.setValue(2, forKey: "2", cost: 0)
        let _ = sut.value(forKey: "1")
        var entry = sut.lru.head as? LRUNode<Cache<Int>.CacheEntry>
        XCTAssertEqual(entry?.value.value, 1)
        let _ = sut.value(forKey: "2")
        entry = sut.lru.head as? LRUNode<Cache<Int>.CacheEntry>
        XCTAssertEqual(entry?.value.value, 2)
    }
    
    func test_removeValue_withKey1Value1_cacheShouldNotContainTheSameEntry() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        XCTAssertNotNil(sut.cache["1"])
        sut.removeValue(forKey: "1")
        XCTAssertNil(sut.cache["1"])
    }
    
    func test_removeValue_withCost2_costLeftShouldIncreasyBy2() throws {
        let sut = Cache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 2)
        let oldCostLeft = sut.costLeft
        sut.removeValue(forKey: "1")
        XCTAssertEqual(sut.costLeft - oldCostLeft, 2)
    }
}
