//
//  BucketView.swift
//  Peggle

import SwiftUI

struct BucketView: View {

    let bucket: Bucket

    var body: some View {
        DisplayableView(displayable: bucket)
    }
}

struct BucketView_Previews: PreviewProvider {
    static var previews: some View {
        BucketView(bucket: Bucket(forLevelWidth: 800, forLevelHeight: 800, period: 5))
    }
}
