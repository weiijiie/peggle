//
//  Peg+Displayable.swift
//  Peggle

import UIKit

extension Peg: Displayable {

    var viewCenter: CGPoint {
        self.center.toCGPoint()
    }

    var viewWidth: CGFloat {
        CGFloat(self.hitBox.width)
    }

    var viewHeight: CGFloat {
        CGFloat(self.hitBox.height)
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
