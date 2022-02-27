//
//  PegBlueprint+Displayable.swift
//  Peggle

import UIKit

extension PegBlueprint: Displayable {

    var viewCenter: CGPoint {
        // we need to handle the case of a triangle specially, as the center of
        // a triangle is different from the center of the view, which is a rectangle
        if case let .triangle(a, b, c) = self.hitBox {
            let minX = min(a.x, b.x, c.x)
            let minY = min(a.y, b.y, c.y)

            return CGPoint(
                x: minX + self.hitBox.width / 2,
                y: minY + self.hitBox.height / 2
            )
        }

        return self.center.toCGPoint()
    }

    var viewWidth: CGFloat {
        CGFloat(self.hitBox.width)
    }

    var viewHeight: CGFloat {
        CGFloat(self.hitBox.height)
    }

    var image: UIImage {
        switch (self.color, self.hitBox) {
        case (.blue, .circle):
            return #imageLiteral(resourceName: "PegBlue")
        case (.orange, .circle):
            return #imageLiteral(resourceName: "PegOrange")
        case (.green, .circle):
            return #imageLiteral(resourceName: "PegGreen")
        case (.blue, .triangle):
            return #imageLiteral(resourceName: "BlockBlue")
        case (.orange, .triangle):
            return #imageLiteral(resourceName: "BlockOrange")
        case (.green, .triangle):
            return #imageLiteral(resourceName: "BlockGreen")
        case (_, .axisAlignedRectangle):
            // placeholder image since we do not support rectangular pegs
            return UIImage(systemName: "xmark.octagon")!
        }
    }
}
