//
//  PegBlueprint+Displayable.swift
//  Peggle

import UIKit

extension PegBlueprint: Displayable {

    var width: CGFloat {
        switch self.hitBox {
        case let .circle(center: _, radius: radius):
            return CGFloat(radius * 2)
        case let .axisAlignedRectangle(center: _, width: width, height: _):
            return CGFloat(width)
        }
    }

    var height: CGFloat {
        switch self.hitBox {
        case let .circle(center: _, radius: radius):
            return CGFloat(radius * 2)
        case let .axisAlignedRectangle(center: _, width: _, height: height):
            return CGFloat(height)
        }
    }

    var image: UIImage {
        switch self.color {
        case .blue:
            return #imageLiteral(resourceName: "PegBlue")
        case .orange:
            return #imageLiteral(resourceName: "PegOrange")
        }
    }
}