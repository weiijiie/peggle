// swiftlint:disable:this file_name
//
//  OverlayIf.swift
//  Peggle

import SwiftUI

extension View {
    func overlay<T: View>(if condition: Bool, @ViewBuilder content: () -> T) -> some View {
        overlay {
            if condition {
                content()
            }
        }
    }
}
