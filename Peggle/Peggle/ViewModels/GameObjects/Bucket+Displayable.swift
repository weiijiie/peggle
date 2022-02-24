//
//  Bucket+Displayable.swift
//  Peggle

import UIKit

extension Bucket: Displayable {
    var viewCenter: CGPoint {
        self.position.toCGPoint()
    }

    var viewWidth: CGFloat {
        // should use the top width for displaying, since it is the largest
        self.topWidth
    }

    var viewHeight: CGFloat {
        self.bucketHeight
    }

    var image: UIImage {
        #imageLiteral(resourceName: "Bucket")
    }
}
