//
//  Navigator.swift
//  Peggle

import SwiftUI

class Navigator<T: RouteType>: ObservableObject {
    @Published private(set) var historyStack = Stack<T>()
    @Published private(set) var currentRoute: T?

    private var initialRoute: T?

    func navigateTo(route: T) {
        currentRoute = route
        historyStack.push(route)

        if initialRoute == nil {
            initialRoute = route
        }
    }

    func navigateBack() {
        _ = historyStack.pop()
        let prevRoute = historyStack.peek()

        if let prevRoute = prevRoute {
            currentRoute = prevRoute
        } else {
            // history stack is empty, we default to the initial route
            currentRoute = initialRoute
        }
    }
}
