//
//  StackTests.swift
//  PeggleTests

import XCTest
@testable import Peggle

class StackTests: XCTestCase {
    var stack: Stack<Int>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        stack = Stack()
    }

    func testPopAndPush_PopReturnsPushedElement() throws {
        let elem = 1
        stack.push(elem)
        let result = try XCTUnwrap(stack.pop())

        XCTAssertEqual(elem, result, "Element pushed should be equal to element popped")
    }

    func testPopAndPush_MultiplePopsAndPushesReturnsElementsInCorrectOrder() throws {
        let elem1 = 1
        let elem2 = 3

        stack.push(elem1)
        stack.push(elem2)

        let result1 = try XCTUnwrap(stack.pop())
        let result2 = try XCTUnwrap(stack.pop())

        XCTAssertEqual(elem1, result2, "First element pushed should be equal to the second element popped")
        XCTAssertEqual(elem2, result1, "Second element pushed should be equal to the first element popped")
    }

    func testPop_ReturnsNilIfEmpty() {
        let result = stack.pop()
        XCTAssertNil(result, "Popping an empty stack should return nil")
    }

    func testPeek_ReturnsButDoesNotRemoveTopElementOfStack() {
        let elem = 1
        stack.push(elem)

        let result = stack.peek()

        XCTAssertEqual(elem, result, "Peeked element should be equal to the pushed element")

        let resultAfterPeek = stack.pop()

        XCTAssertEqual(elem, resultAfterPeek, "Peeking should not remove the element")
    }

    func testPeek_ReturnsNilIfEmpty() {
        let result = stack.peek()
        XCTAssertNil(result, "Peeking an empty stack should return nil")
    }

    func testCount() {
        // empty stack case
        XCTAssertEqual(stack.count, 0, "Count should be 0 when stack is empty")

        // case after pushing
        let count = 3
        for i in 1...count {
            stack.push(i)
        }

        XCTAssertEqual(stack.count, count, "Count should be \(count) after pushing \(count) times")

        // case after popping
        _ = stack.pop()

        XCTAssertEqual(stack.count, count - 1,
                       "Count should be \(count - 1) after pushing \(count) times then popping once")
    }

    func testIsEmpty() {
        // empty stack case
        XCTAssertTrue(stack.isEmpty, "Should return true when stack is empty")

        // non-empty stack case
        stack.push(1)
        XCTAssertFalse(stack.isEmpty, "Should return false when stack is not empty")
    }

    func testRemoveAll() {
        stack.push(1)
        stack.push(2)

        XCTAssertFalse(stack.isEmpty, "Stack should not be empty before .removeAll()")

        stack.removeAll()

        XCTAssertTrue(stack.isEmpty, "Stack should be empty after .removeAll()")
        XCTAssertEqual(stack.count, 0, "Stack should have a count of 0 after .removeAll()")
    }

    func testToArray_ReturnsEmptyArrayIfStackIsEmpty() {
        let array = stack.toArray()
        XCTAssertEqual(array, [], "Should return empty array if stack is empty")
    }

    func testToArray_ReturnsArrayInCorrectOrderIfStackIsNotEmpty() {
        let elem1 = 1, elem2 = 2, elem3 = 3

        stack.push(elem1)
        stack.push(elem2)
        stack.push(elem3)

        let array = stack.toArray()

        XCTAssertEqual(array, [elem3, elem2, elem1], "Should return array arranged in pop order")
    }
}
