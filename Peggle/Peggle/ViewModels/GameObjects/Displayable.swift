//
//  Displayable.swift
//  Peggle

import UIKit

// Defines attributes that a game object needs to be displayed on a screen
protocol Displayable {
    var width: CGFloat { get }
    var height: CGFloat { get }
    var image: UIImage { get }
}
