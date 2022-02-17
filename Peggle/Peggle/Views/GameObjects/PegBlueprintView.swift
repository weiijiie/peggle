//
//  PegView.swift
//  Peggle

import SwiftUI
import Physics

struct PegBlueprintView: View {
    let pegBlueprint: PegBlueprint

    let onTap: () -> Void
    let onLongPress: () -> Void
    let onDragEnd: (_ endLocation: CGPoint) -> Void

    @GestureState var dragLocation: CGPoint?

    var body: some View {
        Image(uiImage: pegBlueprint.image)
            .resizable()
            .frame(width: pegBlueprint.width, height: pegBlueprint.height)
            .position(pegBlueprint.center.toCGPoint())
            // hide the actual peg while dragging so only the preview is seen
            .opacity(dragLocation == nil ? 1 : 0)
            .onTapGesture(perform: onTap)
            .onLongPressGesture(perform: onLongPress)
            .gesture(
                DragGesture()
                    .updating($dragLocation) { value, location, _ in
                        location = value.location
                    }.onEnded { value in
                        onDragEnd(value.location)
                    }
            )

        // while dragging, show a preview of the peg at the dragged location
        if let dragLocation = dragLocation {
            Image(uiImage: pegBlueprint.image)
                .resizable()
                .frame(width: pegBlueprint.width, height: pegBlueprint.height)
                .position(dragLocation)
                .opacity(0.5)
                .zIndex(1) // show this preview above other pegs
        }
    }
}

struct PegBlueprintView_Previews: PreviewProvider {
    static var previews: some View {
        PegBlueprintView(
            pegBlueprint: PegBlueprint.round(color: .blue, center: Point(x: 250, y: 250), radius: 30),
            onTap: {},
            onLongPress: {},
            onDragEnd: { _ in }
        )
    }
}
