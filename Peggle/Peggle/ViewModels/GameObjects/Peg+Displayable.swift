//
//  Peg+Displayable.swift
//  Peggle

import UIKit

extension Peg: Displayable {

    var viewCenter: CGPoint {
        self.center.toCGPoint()
    }

    var viewWidth: CGFloat {
        switch self.hitBox {
        case let .circle(center: _, radius: radius):
            return CGFloat(radius * 2)
        case let .axisAlignedRectangle(center: _, width: width, height: _):
            return CGFloat(width)
        }
    }

    var viewHeight: CGFloat {
        switch self.hitBox {
        case let .circle(center: _, radius: radius):
            return CGFloat(radius * 2)
        case let .axisAlignedRectangle(center: _, width: _, height: height):
            return CGFloat(height)
        }
    }

    var image: UIImage {
        switch (self.type, self.hasBeenHit) {
        case (.blue, false):
            return #imageLiteral(resourceName: "PegBlue")
        case (.blue, true):
            return #imageLiteral(resourceName: "PegBlueGlow")
        case (.orange, false):
            return #imageLiteral(resourceName: "PegOrange")
        case (.orange, true):
            return #imageLiteral(resourceName: "PegOrangeGlow")
        case (.green, false):
            return #imageLiteral(resourceName: "PegGreen")
        case (.green, true):
            return #imageLiteral(resourceName: "PegGreenGlow")
        }
    }
}
