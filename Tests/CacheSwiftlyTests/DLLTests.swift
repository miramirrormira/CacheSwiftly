@testable import CacheSwiftly
import XCTest

final class DLLTests: XCTestCase {

    func test_removeAll_with_three_nodes_in_dll() throws {
        
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head_ = LRUNodeSpy<Int>(value: 0, calledDeinit: calledDeinit)
        sut.head_?.next = LRUNodeSpy<Int>(value: 1, calledDeinit: calledDeinit)
        sut.head_?.next?.prev = sut.head_
        sut.head_?.next?.next = LRUNodeSpy<Int>(value: 2, calledDeinit: calledDeinit)
        sut.head_?.next?.next?.prev = sut.head_?.next
        sut.tail_ = sut.head_?.next?.next
        
        sut.removeAll()
        
        XCTAssertNil(sut.head_)
        XCTAssertNil(sut.tail_)
        XCTAssertEqual(deinitCount, 3)
    }
    
    func test_popHead_with_empty_dll() {
        let sut = DLL.init()
        let popped = sut.popHead()
        XCTAssertNil(sut.head_)
        XCTAssertNil(sut.tail_)
        XCTAssertNil(popped)
    }
    
    func test_popHead_with_one_node_in_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.head_ = node
        sut.tail_ = sut.head_
        let popped = sut.popHead()
        XCTAssertNil(sut.head_)
        XCTAssertNil(sut.tail_)
        XCTAssertIdentical(popped, node)
    }
    
    func test_popHead_with_one_node_in_dll_and_popped_node_discarded_should_deinit_popped_node() {
        var deinitCount = 0
        let calledDeinit = {
            deinitCount += 1
        }
        let sut = DLL.init()
        sut.head_ = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.tail_ = sut.head_
        sut.popHead()
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popTail_with_empty_dll() {
        let sut = DLL.init()
        let popped = sut.popTail()
        XCTAssertNil(sut.head_)
        XCTAssertNil(sut.tail_)
        XCTAssertNil(popped)
    }
    
    func test_popTail_with_one_node_in_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.head_ = node
        sut.tail_ = sut.head_
        let popped = sut.popTail()
        XCTAssertNil(sut.head_)
        XCTAssertNil(sut.tail_)
        XCTAssertIdentical(popped, node)
    }
    
    func test_popTail_with_one_node_in_dll_and_popped_node_discarded_should_deinit_popped_node() {
        var deinitCount = 0
        let calledDeinit = {
            deinitCount += 1
        }
        let sut = DLL.init()
        sut.head_ = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.tail_ = sut.head_
        sut.popTail()
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popHead_with_two_nodes_in_dll() {
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head_ = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.head_?.next = LRUNodeSpy(value: 1, calledDeinit: calledDeinit)
        sut.tail_ = sut.head_?.next
        sut.tail_?.prev = sut.head_
        
        sut.popHead()
        
        XCTAssertNotNil(sut.head_)
        XCTAssertNotNil(sut.tail_)
        XCTAssertIdentical(sut.head_, sut.tail_)
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popTail_with_two_nodes_in_dll() {
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head_ = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.head_?.next = LRUNodeSpy(value: 1, calledDeinit: calledDeinit)
        sut.tail_ = sut.head_?.next
        sut.tail_?.prev = sut.head_
        
        sut.popTail()
        
        XCTAssertNotNil(sut.head_)
        XCTAssertNotNil(sut.tail_)
        XCTAssertIdentical(sut.head_, sut.tail_)
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_popHead_with_three_nodes_in_dll() {
        
        let sut = DLL.init()
        sut.head_ = LRUNode(value: 0)
        sut.head_?.next = LRUNode(value: 1)
        sut.head_?.next?.next = LRUNode(value: 2)
        sut.head_?.next?.prev = sut.head_
        sut.head_?.next?.next?.prev = sut.head_?.next
        sut.tail_ = sut.head_?.next?.next
        
        sut.popHead()
        
        XCTAssertNotNil(sut.head_)
        XCTAssertNotNil(sut.tail_)
        XCTAssertNotIdentical(sut.head_, sut.tail_)
    }
    
    func test_popTail_with_three_nodes_in_dll() {
        var deinitCount = 0
        
        let calledDeinit = {
            deinitCount += 1
        }
        
        let sut = DLL.init()
        sut.head_ = LRUNodeSpy(value: 0, calledDeinit: calledDeinit)
        sut.head_?.next = LRUNodeSpy(value: 1, calledDeinit: calledDeinit)
        sut.head_?.next?.next = LRUNodeSpy(value: 2, calledDeinit: calledDeinit)
        sut.head_?.next?.prev = sut.head_
        sut.head_?.next?.next?.prev = sut.head_?.next
        sut.tail_ = sut.head_?.next?.next
        
        sut.popTail()
        
        XCTAssertNotNil(sut.head_)
        XCTAssertNotNil(sut.tail_)
        XCTAssertNotIdentical(sut.head_, sut.tail_)
        XCTAssertEqual(deinitCount, 1)
    }
    
    func test_insertHead_with_empty_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.insertHead(node)
        XCTAssertIdentical(sut.head_, node)
        XCTAssertIdentical(sut.tail_, node)
    }
    
    func test_insertHead_with_one_node_in_dll() {
        let sut = DLL.init()
        let node = LRUNode(value: 0)
        sut.head_ = node
        sut.tail_ = node
        
        let newNode = LRUNode(value: 1)
        sut.insertHead(newNode)
        
        XCTAssertIdentical(sut.head_, newNode)
        XCTAssertIdentical(sut.tail_, node)
        XCTAssertIdentical(sut.head_?.next, sut.tail_)
        XCTAssertIdentical(sut.tail_?.prev, sut.head_)
    }
    
    func test_remove_with_one_node_in_dll() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 0)
        sut.head_ = nodeToRemove
        sut.tail_ = nodeToRemove
        
        sut.remove(nodeToRemove)
        
        XCTAssertNil(sut.head_)
        XCTAssertNil(sut.tail_)
    }
    
    func test_remove_with_two_nodes_in_dll_and_removing_head_node() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 0)
        sut.head_ = nodeToRemove
        sut.head_?.next = LRUNode(value: 1)
        sut.tail_ = sut.head_?.next
        sut.tail_?.prev = sut.head_
        
        sut.remove(nodeToRemove)
        
        XCTAssertNotNil(sut.head_)
        XCTAssertIdentical(sut.head_, sut.tail_)
        let newHead = sut.head_ as? LRUNode<Int>
        XCTAssertEqual(newHead?.value, 1)
        XCTAssertNil(sut.head_?.next)
        XCTAssertNil(sut.head_?.prev)
        XCTAssertNil(sut.tail_?.next)
        XCTAssertNil(sut.tail_?.prev)
    }
    
    func test_remove_with_two_nodes_in_dll_and_removing_tail_node() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 1)
        sut.head_ = LRUNode(value: 0)
        sut.head_?.next = nodeToRemove
        sut.tail_ = sut.head_?.next
        sut.tail_?.prev = sut.head_
        
        sut.remove(nodeToRemove)
        
        let newTail = sut.tail_ as! LRUNode<Int>
        XCTAssertEqual(newTail.value, 0)
        XCTAssertNotNil(sut.tail_)
        XCTAssertIdentical(sut.head_, sut.tail_)
        XCTAssertNil(sut.head_?.next)
        XCTAssertNil(sut.head_?.prev)
        XCTAssertNil(sut.tail_?.next)
        XCTAssertNil(sut.tail_?.prev)
    }
    
    func test_remove_with_three_nodes_in_dll_and_removing_middle_node() {
        let sut = DLL.init()
        let nodeToRemove = LRUNode(value: 1)
        sut.head_ = LRUNode(value: 0)
        sut.head_?.next = nodeToRemove
        sut.head_?.next?.next = LRUNode(value: 2)
        sut.head_?.next?.prev = sut.head_
        sut.head_?.next?.next?.prev = sut.head_?.next
        sut.tail_ = sut.head_?.next?.next
        
        sut.remove(nodeToRemove)
        
        XCTAssertIdentical(sut.head_?.next, sut.tail_)
        XCTAssertIdentical(sut.tail_?.prev, sut.head_)
        XCTAssertNil(sut.head_?.prev)
        XCTAssertNil(sut.tail_?.next)
    }
}
