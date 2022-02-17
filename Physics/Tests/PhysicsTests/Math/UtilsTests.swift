//
//  UtilsTests.swift
//  PhysicsTests

import XCTest
@testable import Physics

class UtilsTests: XCTestCase {

    struct TestCase<T: Comparable> {
        var value: T
        var min: T
        var max: T
        var expected: T
    }

    func testClampNumeric() {
        let numericTestCases = [
            TestCase(value: 10, min: 5, max: 15, expected: 10),
            TestCase(value: 0, min: 5, max: 15, expected: 5),
            TestCase(value: 20, min: 5, max: 15, expected: 15),
            TestCase(value: 0.3, min: 0.4, max: 0.5, expected: 0.4)
        ]

        for testCase in numericTestCases {
            let result = clamp(value: testCase.value, min: testCase.min, max: testCase.max)

            XCTAssertEqual(result, testCase.expected,
                           "Expected clamped result to be \(testCase.expected), got \(result)")
        }
    }

    func testClampStrings() {
        let stringTestCases = [
            TestCase(value: "hi", min: "ha", max: "ho", expected: "hi"),
            TestCase(value: "aa", min: "ha", max: "ho", expected: "ha"),
            TestCase(value: "zz", min: "ha", max: "ho", expected: "ho"),
            TestCase(value: "hahaha", min: "lol", max: "rofl", expected: "lol")
        ]

        for testCase in stringTestCases {
            let result = clamp(value: testCase.value, min: testCase.min, max: testCase.max)

            XCTAssertEqual(result, testCase.expected,
                           "Expected clamped result to be \(testCase.expected), got \(result)")
        }
    }
}
