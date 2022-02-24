//
//  DisplayableView.swift
//  Peggle

import SwiftUI

struct DisplayableView: View {

    let displayable: Displayable

    var body: some View {
        Image(uiImage: displayable.image)
            .resizable()
            .atPositionFor(displayable)
    }
}
