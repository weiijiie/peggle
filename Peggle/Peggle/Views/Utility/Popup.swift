//
//  Popup.swift
//  Peggle

import Foundation
import SwiftUI

/// Based on:  https://www.vadimbulavin.com/swiftui-popup-sheet-popover
/// and https://blog.artemnovichkov.com/custom-popups-in-swiftui
struct Popup<T: View>: ViewModifier {

    @Binding var isPresented: Bool

    let blurRadius: CGFloat
    let shadowRadius: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let tapOutsideToDismiss: Bool
    let onDismiss: (() -> Void)?

    let popupContent: T

    init(
        isPresented: Binding<Bool>,
        blurRadius: CGFloat = 3,
        shadowRadius: CGFloat = 32,
        cornerRadius: CGFloat = 8,
        backgroundColor: Color = .white,
        tapOutsideToDismiss: Bool = true,
        @ViewBuilder content: () -> T,
        onDismiss: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.blurRadius = blurRadius
        self.shadowRadius = shadowRadius
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.tapOutsideToDismiss = tapOutsideToDismiss
        self.onDismiss = onDismiss
        self.popupContent = content()
    }

    func body(content: Content) -> some View {
        content
            .blur(radius: isPresented ? blurRadius : 0)
            .allowsHitTesting(!isPresented)
            .overlay(popup())
            .onChange(of: isPresented) { presented in
                if !presented {
                    onDismiss?()
                }
            }
    }

    @ViewBuilder
    private func popup() -> some View {
        ZStack(alignment: .center) {
            Color.black
                .opacity(isPresented ? 0.15 : 0)
                .ignoresSafeArea()
                .zIndex(0)
                .onTapGesture {
                    if tapOutsideToDismiss {
                        isPresented = false
                    }
                }

            if isPresented {
                VStack {
                    Spacer()
                    popupContent
                        .background(
                            backgroundColor.shadow(radius: shadowRadius)
                        )
                        .cornerRadius(cornerRadius)

                    Spacer()
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(.spring(), value: isPresented)
    }
}

extension View {
    func popup<T: View>(
        isPresented: Binding<Bool>,
        blurRadius: CGFloat = 3,
        shadowRadius: CGFloat = 32,
        cornerRadius: CGFloat = 8,
        backgroundColor: Color = .white,
        tapOutsideToDismiss: Bool = true,
        @ViewBuilder content: () -> T,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(Popup(
            isPresented: isPresented,
            blurRadius: blurRadius,
            shadowRadius: shadowRadius,
            cornerRadius: cornerRadius,
            backgroundColor: backgroundColor,
            tapOutsideToDismiss: tapOutsideToDismiss,
            content: content,
            onDismiss: onDismiss
        ))
    }
}
