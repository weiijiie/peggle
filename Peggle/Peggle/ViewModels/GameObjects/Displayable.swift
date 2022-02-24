//
//  Displayable.swift
//  Peggle

import SwiftUI

// Defines attributes that a game object needs to be displayed on a screen
typealias Displayable = Positionable & ImageRepresentable

protocol Positionable {
    var viewCenter: CGPoint { get }
    var viewWidth: CGFloat { get }
    var viewHeight: CGFloat { get }
}

protocol ImageRepresentable {
    var image: UIImage { get }
}

extension View {
    func atPositionFor(_ positionable: Positionable) -> some View {
        frame(width: positionable.viewWidth, height: positionable.viewHeight)
            .position(positionable.viewCenter)
    }
}
