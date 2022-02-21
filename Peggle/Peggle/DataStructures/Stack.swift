//
//  Stack.swift
//  Peggle

import Foundation

/**
 A generic `Stack` class whose elements are last-in, first-out.

 - Authors: CS3217, Huang Weijie
 */
struct Stack<T> {

    // Use an array to represent the stack, where elements pushed are appended
    // to the end of the array, and elements popped are removed from the end
    // of the array.
    private var elements: [T] = []

    /// Adds an element to the top of the stack.
    /// - Parameter item: The element to be added to the stack
    mutating func push(_ item: T) {
        elements.append(item)
    }

    /// Removes the element at the top of the stack and return it.
    /// - Returns: element at the top of the stack
    mutating func pop() -> T? {
        if elements.isEmpty {
            return nil
        }

        return elements.removeLast()
    }

    /// Returns, but does not remove, the element at the top of the stack.
    /// - Returns: element at the top of the stack
    func peek() -> T? {
        elements.last
    }

    /// The number of elements currently in the stack.
    var count: Int {
        elements.count
    }

    /// Whether the stack is empty.
    var isEmpty: Bool {
        elements.isEmpty
    }

    /// Removes all elements in the stack.
    mutating func removeAll() {
        elements.removeAll()
    }

    /// Returns an array of the elements in their respective pop order, i.e.
    /// first element in the array is the first element to be popped.
    /// - Returns: array of elements in their respective pop order
    func toArray() -> [T] {
        // Since each newly pushed element is added to the end of the elements array,
        // a reversed copy of that array will have the first element be the most recently
        // pushed element, which should be the first to be popped.
        return elements.reversed()
    }
}
