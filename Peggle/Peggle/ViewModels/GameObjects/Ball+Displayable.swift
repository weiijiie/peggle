//
//  Ball+Displayable.swift
//  Peggle

import UIKit

extension Ball: Displayable {

    var width: CGFloat {
        self.radius * 2
    }

    var height: CGFloat {
        self.radius * 2
    }

    var image: UIImage {
        #imageLiteral(resourceName: "Ball")
    }
}
