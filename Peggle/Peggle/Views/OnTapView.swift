//
//  TapLocatorView.swift
//  Peggle

import SwiftUI

// Taken from https://stackoverflow.com/a/56518293
// This view accepts a callback that runs when the view is tapped.
// Passes the coordinates of the tap to the callback.
struct OnTapView: UIViewRepresentable {
    var tappedCallback: ((CGPoint) -> Void)

    func makeUIView(context: UIViewRepresentableContext<OnTapView>) -> UIView {
        let view = UIView(frame: .zero)
        let gesture = UITapGestureRecognizer(target: context.coordinator,
                                             action: #selector(Coordinator.tapped))

        view.addGestureRecognizer(gesture)
        return view
    }

    class Coordinator: NSObject {
        var tappedCallback: ((CGPoint) -> Void)

        init(tappedCallback: @escaping ((CGPoint) -> Void)) {
            self.tappedCallback = tappedCallback
        }

        @objc
        func tapped(gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            self.tappedCallback(point)
        }
    }

    func makeCoordinator() -> OnTapView.Coordinator {
        Coordinator(tappedCallback: self.tappedCallback)
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<OnTapView>) { }
}
