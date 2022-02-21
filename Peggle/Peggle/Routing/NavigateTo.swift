//
//  NavigateTo.swift
//  Peggle

import SwiftUI

/// Helper view that navigates to the given route when it is rendered.
/// Must be created as a child of the appropriate `Router.Provider`,
/// will error otherwise.
struct NavigateTo<T: RouteType>: View {

    @EnvironmentObject var navigator: Navigator<T>
    private let route: T

    init(route: T) {
        self.route = route
    }

    var body: some View {
        Text("Navigating...")
            .hidden()
            .onAppear {
                if navigator.currentRoute != route {
                    navigator.navigateTo(route: route)
                }
            }
    }
}
