//
//  NavigateToMenuButton.swift
//  Peggle

import SwiftUI

struct NavigateToMenuButton: View {
    @EnvironmentObject var navigator: Navigator<PeggleRoute>

    var body: some View {
        Button {
            navigator.navigateTo(route: .menu)
        } label: {
            Label("Menu", systemImage: "arrow.backward")
        }
        .buttonStyle(.borderedProminent)
    }
}

struct NavBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigateToMenuButton()
    }
}
