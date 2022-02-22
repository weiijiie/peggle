//
//  BucketView.swift
//  Peggle

import SwiftUI

struct BucketView: View {

    let bucket: Bucket

    var body: some View {
        Image(uiImage: bucket.image)
            .resizable()
            .frame(width: bucket.width, height: bucket.height)
            .position(x: bucket.position.x, y: bucket.position.y)
    }
}

struct BucketView_Previews: PreviewProvider {
    static var previews: some View {
        BucketView(bucket: Bucket(forLevelWidth: 800, forLevelHeight: 800, period: 5))
    }
}
