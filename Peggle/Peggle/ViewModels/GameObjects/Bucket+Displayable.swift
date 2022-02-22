//
//  Bucket+Displayable.swift
//  Peggle

import SwiftUI

extension Bucket: Displayable {
    var width: CGFloat {
        // should use the top width for displaying, since it is the largest
        topWidth
    }

    var height: CGFloat {
        bucketHeight
    }

    var image: UIImage {
        #imageLiteral(resourceName: "Bucket")
    }
}
