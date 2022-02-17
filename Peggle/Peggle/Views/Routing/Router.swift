//
//  RouterView.swift
//  Peggle

import SwiftUI

typealias RouteType = CaseIterable & Equatable

/// Extremely simplistic router that handles the conditional displaying of routes depending on the current route.
/// Usage:
///   1. Create a router for a `RouteType`, ie. `let router = Router<MyRoute>(initialRoute: MyRoutes.home)`
///   2. Add the route provider to the top level of your views, ie `router.provider { ... }`
///   3. Inside the environment provider, define your routes, ie. `router.route(for: .menu) { ... }`
///   4. In any child views of routes, access the navigator as an environment object,
///     ie. `@EnvironmentObject var navigator: Navigator<MyRouter>`
///
///   Example:
///   ```
///   struct MyView: View {
///       let router = Router(initialRoute: MyRoutes.home)
///
///       var body: some View {
///           router.provider {
///               router.route(for: .home) {
///                   Text("hello world")
///               }
///               router.route(for: .menu) {
///                   Text("menu")
///               }
///           }
///       }
///   }
///   ```
class Router<T: RouteType> {

    let initialRoute: T

    init(initialRoute: T) {
        self.initialRoute = initialRoute
    }

    struct Provider<Content: View>: View {

        @StateObject var navigator = Navigator<T>()

        let initialRoute: T
        let content: Content

        fileprivate init(initialRoute: T, @ViewBuilder content: () -> Content) {
            self.initialRoute = initialRoute
            self.content = content()
        }

        var body: some View {
            content
                .environmentObject(navigator)
                .onAppear {
                    navigator.navigateTo(route: initialRoute)
                }
        }
    }

    struct Route<Content: View>: View {

        private(set) var route: T
        @EnvironmentObject var navigator: Navigator<T>

        let content: Content

        fileprivate init(route: T, @ViewBuilder content: () -> Content) {
            self.route = route
            self.content = content()
        }

        var body: some View {
            if navigator.currentRoute == route {
                content
            }
        }
    }

    func provider<Content: View>(@ViewBuilder content: () -> Content) -> Provider<Content> {
        Provider(initialRoute: initialRoute, content: content)
    }

    func route<Content: View>(for route: T, @ViewBuilder content: () -> Content) -> Route<Content> {
        Route(route: route, content: content)
    }
}

class Navigator<T: RouteType>: ObservableObject {
    @Published var currentRoute: T?

    func navigateTo(route: T) {
        currentRoute = route
    }
}
