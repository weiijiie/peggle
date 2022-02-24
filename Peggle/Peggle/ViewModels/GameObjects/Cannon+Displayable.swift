//
//  Cannon.swift
//  Peggle

import UIKit
import Physics

extension Cannon: Displayable {

    var viewCenter: CGPoint {
        self.position.toCGPoint()
    }

    var viewWidth: CGFloat {
        CGFloat(self.size)
    }

    var viewHeight: CGFloat {
        CGFloat(self.size)
    }

    var image: UIImage {
        #imageLiteral(resourceName: "Cannon")
    }
}

/// Returns the appropriate amount that the cannon image should be rotated given the current cannon angle.
/// Since a cannon angle of 90 degrees (cannon pointing downwards) corresponds to a 0 degree rotation in the
/// image asset of the cannon (which is also pointing downwards), we subtract 90 from the current angle to
/// normalize the values.
extension Cannon {
    var imageRotation: Degrees {
        currentAngle - 90
    }
}
