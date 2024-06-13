@testable import CacheSwiftly
import XCTest

final class CacheTests: XCTestCase {

    func test_init_with_costLimit5_shouldGet5() throws {
        let costLimit = 5
        let sut = LRUCache<Int>(costLimit: costLimit)
        
        XCTAssertEqual(sut.costLimit, 5)
        XCTAssertEqual(sut.costLeft_, sut.costLimit)
    }
    
    func test_setValue_withCost5CostLimit0_shouldThrowExceededCostLimitError() async {
        let sut = LRUCache<Int>(costLimit: 0)
        do {
            try sut.setValue(0, forKey: "", cost: 5)
        } catch let error as CacheErrors {
            XCTAssertEqual(error, CacheErrors.exceededCostLimit)
        } catch {
            XCTFail("wrong error")
        }
    }
    
    func test_setValue_withCost5CostLimit5CostLeft5_shouldReturnCostLeft0() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(0, forKey: "", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
    }
    
    func test_setValue_withCost5CostLimit5CostLeft0_shouldReturnCostLeft0() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(0, forKey: "1", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
        try sut.setValue(0, forKey: "2", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
    }
    
    func test_setValue_withCost5CostLimit5CostLeft2_shouldReturnCostLeft0() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(0, forKey: "1", cost: 3)
        XCTAssertEqual(sut.costLeft, 2)
        try sut.setValue(0, forKey: "2", cost: 5)
        XCTAssertEqual(sut.costLeft, 0)
    }
    
    func test_setValue_withKey1Value1_cacheShouldContainTheSameEntry() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        XCTAssertNotNil(sut.cache["1"])
        XCTAssertEqual(sut.cache["1"]?.value.value, 1)
    }
    
    func test_setValue_withExistingKey1Value1_setNewKey1Value2_shouldReplaceTheOldEntry() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        XCTAssertEqual(sut.cache["1"]?.value.value, 1)
        try sut.setValue(2, forKey: "1", cost: 0)
        XCTAssertEqual(sut.cache["1"]?.value.value, 2)
    }
    
    func test_setValue_withKey1Value1_lruHeadNodeShouldContainTheSameEntry() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        let mruEntry = sut.lru.head as? LRUNode<CacheEntry<Int>>
        XCTAssertEqual(mruEntry?.value.value, 1)
        XCTAssertEqual(mruEntry?.value.cost, 0)
    }
    
    func test_valueForKey_withNonExistingKey1_shouldReturnNil() async throws {
        let sut = LRUCache<Int>(costLimit: 5)
        let value = try await sut.value(forKey: "1")
        XCTAssertNil(value)
    }
    
    func test_valueForKey_withExistingKey1Value1Pair_shouldReturnValue1() async throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        let value = try await sut.value(forKey: "1")
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 1)
    }
    
    func test_valueForKey_withKey1Value1_lruHeadShouldContainTheSameEntry() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        let mruEntry = sut.lru.head as? LRUNode<CacheEntry<Int>>
        XCTAssertEqual(mruEntry?.value.value, 1)
    }
    
    func test_valueForKey_withExistingKey1Value1_setNewKey2Value2_lruHeadShouldContainKey2Value2() async throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        try sut.setValue(2, forKey: "2", cost: 0)
        let _ = try await sut.value(forKey: "1")
        var mruEntry = sut.lru.head as? LRUNode<CacheEntry<Int>>
        XCTAssertEqual(mruEntry?.value.value, 1)
        let _ = try await sut.value(forKey: "2")
        mruEntry = sut.lru.head as? LRUNode<CacheEntry<Int>>
        XCTAssertEqual(mruEntry?.value.value, 2)
    }
    
    func test_removeValue_withKey1Value1_cacheShouldNotContainTheSameEntry() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 0)
        XCTAssertNotNil(sut.cache["1"])
        sut.removeValue(forKey: "1")
        XCTAssertNil(sut.cache["1"])
    }
    
    func test_removeValue_withCost2_costLeftShouldIncreasyBy2() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(1, forKey: "1", cost: 2)
        let oldCostLeft = sut.costLeft_
        sut.removeValue(forKey: "1")
        XCTAssertEqual(sut.costLeft_ - oldCostLeft, 2)
    }
    
    func test_subscript() throws {
        let sut = LRUCache<Int>(costLimit: 5)
        try sut.setValue(0, forKey: "0", cost: 0)
        let value = sut["0"]
        XCTAssertEqual(value, 0)
    }
    
    func test_setValue_raceCondition() async throws {
        let count = 10000
        let sut = LRUCache<Int>(costLimit: count)
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "CacheSwiftly.CacheTests.induceRaceCondition", attributes: [.concurrent])
        for i in 0..<count {
            group.enter()
            concurrentQueue.async {
                do {
                    try sut.setValue(i, forKey: "\(i)", cost: 1)
                    group.leave()
                } catch {
                    XCTFail()
                }
            }
        }
        let expectation = expectation(description: "wait_for_concurrent_setValue")
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 10)
        XCTAssertEqual(sut.cache.count, count)
        XCTAssertEqual(sut.costLeft, 0)
    }
    
    func test_removeValue_raceCondition() async throws {
        let count = 10000
        let sut = LRUCache<Int>(costLimit: count)

        for i in 0..<count {
            do {
                try sut.setValue(i, forKey: "\(i)", cost: 1)
            } catch {
                XCTFail()
            }
        }
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "CacheSwiftly.CacheTests.induceRaceCondition", attributes: [.concurrent])
        
        for i in 0..<count {
            group.enter()
            concurrentQueue.async {
                let key = "\(i)"
                sut.removeValue(forKey: key)
                group.leave()
            }
        }
        
        let expectation = expectation(description: "wait_for_concurrent_setValue")
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 10)
        XCTAssertEqual(sut.costLeft, count)
        XCTAssertEqual(sut.cache.count, 0)
    }
}
