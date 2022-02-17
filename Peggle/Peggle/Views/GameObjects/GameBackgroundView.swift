//
//  GameBackgroundView.swift
//  Peggle

import SwiftUI

func GameBackground(width: CGFloat, height: CGFloat) -> some View {
    Image("Background")
        .resizable()
        .clipped()
        .scaledToFill()
        .edgesIgnoringSafeArea(.all)
        .frame(width: width, height: height)
}
