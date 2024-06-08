@testable import CacheSwiftly
import XCTest

final class DLLTests: XCTestCase {

    func test_removeAll_with_three_nodes_in_dll() throws {
        
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head = LRUNodeSpy<Int>(value: 0, calledDeinit: calledDeinit)
        sut.head?.next = LRUNodeSpy<Int>(value: 1, calledDeinit: calledDeinit)
        sut.head?.next?.prev = sut.head
        sut.head?.next?.next = LRUNodeSpy<Int>(value: 2, calledDeinit: calledDeinit)
        sut.head?.next?.next?.prev = sut.head?.next
        sut.tail = sut.head?.next?.next
        
        sut.removeAll()
        
        XCTAssertNil(sut.head)
        XCTAssertNil(sut.tail)
        XCTAssertEqual(deinitCount, 3)
    }
    
    func test_popHead_with_empty_dll() {
        let sut = DLL.init()
        let popped = sut.popHead()
        XCTAssertNil(sut.head)
        XCTAssertNil(sut.tail)
        XCTAssertNil(popped)
    }
    
    func test_popHead_with_one_node_in_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.head = node
        sut.tail = sut.head
        let popped = sut.popHead()
        XCTAssertNil(sut.head)
        XCTAssertNil(sut.tail)
        XCTAssertIdentical(popped, node)
    }
    
    func test_popHead_with_one_node_in_dll_and_popped_node_discarded_should_deinit_popped_node() {
        var deinitCount = 0
        let calledDeinit = {
            deinitCount += 1
        }
        let sut = DLL.init()
        sut.head = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.tail = sut.head
        sut.popHead()
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popTail_with_empty_dll() {
        let sut = DLL.init()
        let popped = sut.popTail()
        XCTAssertNil(sut.head)
        XCTAssertNil(sut.tail)
        XCTAssertNil(popped)
    }
    
    func test_popTail_with_one_node_in_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.head = node
        sut.tail = sut.head
        let popped = sut.popTail()
        XCTAssertNil(sut.head)
        XCTAssertNil(sut.tail)
        XCTAssertIdentical(popped, node)
    }
    
    func test_popTail_with_one_node_in_dll_and_popped_node_discarded_should_deinit_popped_node() {
        var deinitCount = 0
        let calledDeinit = {
            deinitCount += 1
        }
        let sut = DLL.init()
        sut.head = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.tail = sut.head
        sut.popTail()
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popHead_with_two_nodes_in_dll() {
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.head?.next = LRUNodeSpy(value: 1, calledDeinit: calledDeinit)
        sut.tail = sut.head?.next
        sut.tail?.prev = sut.head
        
        sut.popHead()
        
        XCTAssertNotNil(sut.head)
        XCTAssertNotNil(sut.tail)
        XCTAssertIdentical(sut.head, sut.tail)
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popTail_with_two_nodes_in_dll() {
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.head?.next = LRUNodeSpy(value: 1, calledDeinit: calledDeinit)
        sut.tail = sut.head?.next
        sut.tail?.prev = sut.head
        
        sut.popTail()
        
        XCTAssertNotNil(sut.head)
        XCTAssertNotNil(sut.tail)
        XCTAssertIdentical(sut.head, sut.tail)
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popHead_with_three_nodes_in_dll() {
        
        let sut = DLL.init()
        sut.head = LRUNode(value: 0)
        sut.head?.next = LRUNode(value: 1)
        sut.head?.next?.next = LRUNode(value: 2)
        sut.head?.next?.prev = sut.head
        sut.head?.next?.next?.prev = sut.head?.next
        sut.tail = sut.head?.next?.next
        
        sut.popHead()
        
        XCTAssertNotNil(sut.head)
        XCTAssertNotNil(sut.tail)
        XCTAssertNotIdentical(sut.head, sut.tail)
    }
    
    func test_popTail_with_three_nodes_in_dll() {
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.head?.next = LRUNodeSpy(value: 1, calledDeinit: calledDeinit)
        sut.head?.next?.next = LRUNodeSpy(value: 2, calledDeinit: calledDeinit)
        sut.head?.next?.prev = sut.head
        sut.head?.next?.next?.prev = sut.head?.next
        sut.tail = sut.head?.next?.next
        
        sut.popTail()
        
        XCTAssertNotNil(sut.head)
        XCTAssertNotNil(sut.tail)
        XCTAssertNotIdentical(sut.head, sut.tail)
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_insertHead_with_empty_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.insertHead(node)
        XCTAssertIdentical(sut.head, node)
        XCTAssertIdentical(sut.tail, node)
    }
    
    func test_insertHead_with_one_node_in_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.head = node
        sut.tail = node
        
        let newNode = LRUNode(value: 1)
        sut.insertHead(newNode)
        
        XCTAssertIdentical(sut.head, newNode)
        XCTAssertIdentical(sut.tail, node)
        XCTAssertIdentical(sut.head?.next, sut.tail)
        XCTAssertIdentical(sut.tail?.prev, sut.head)
    }
    
    func test_remove_with_one_node_in_dll() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 0)
        sut.head = nodeToRemove
        sut.tail = nodeToRemove
        
        sut.remove(nodeToRemove)
        
        XCTAssertNil(sut.head)
        XCTAssertNil(sut.tail)
    }
    
    func test_remove_with_two_nodes_in_dll_and_removing_head_node() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 0)
        sut.head = nodeToRemove
        sut.head?.next = LRUNode(value: 1)
        sut.tail = sut.head?.next
        sut.tail?.prev = sut.head
        
        sut.remove(nodeToRemove)
        
        XCTAssertIdentical(sut.head, sut.tail)
        XCTAssertNil(sut.head?.next)
        XCTAssertNil(sut.head?.prev)
        XCTAssertNil(sut.tail?.next)
        XCTAssertNil(sut.tail?.prev)
    }
    
    func test_remove_with_two_nodes_in_dll_and_removing_tail_node() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 1)
        sut.head = LRUNode(value: 0)
        sut.head?.next = nodeToRemove
        sut.tail = sut.head?.next
        sut.tail?.prev = sut.head
        
        sut.remove(nodeToRemove)
        
        XCTAssertIdentical(sut.head, sut.tail)
        XCTAssertNil(sut.head?.next)
        XCTAssertNil(sut.head?.prev)
        XCTAssertNil(sut.tail?.next)
        XCTAssertNil(sut.tail?.prev)
    }
    
    func test_remove_with_three_nodes_in_dll_and_removing_middle_node() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 1)
        sut.head = LRUNode(value: 0)
        sut.head?.next = nodeToRemove
        sut.head?.next?.next = LRUNode(value: 2)
        sut.head?.next?.prev = sut.head
        sut.head?.next?.next?.prev = sut.head?.next
        sut.tail = sut.head?.next?.next
        
        sut.remove(nodeToRemove)
        
        XCTAssertIdentical(sut.head?.next, sut.tail)
        XCTAssertIdentical(sut.tail?.prev, sut.head)
        XCTAssertNil(sut.head?.prev)
        XCTAssertNil(sut.tail?.next)
    }
    
    
}
