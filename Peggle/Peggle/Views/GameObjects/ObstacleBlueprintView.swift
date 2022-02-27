//
//  PegView.swift
//  Peggle

import SwiftUI
import Physics

struct ObstacleBlueprintView: View {
    let obstacleBlueprint: ObstacleBlueprint

    let onTap: () -> Void
    let onLongPress: () -> Void
    let onDragEnd: (_ endLocation: CGPoint) -> Void

    @GestureState var dragLocation: CGPoint?

    var body: some View {
        DisplayableView(displayable: obstacleBlueprint)
            // hide the actual obstacle while dragging so only the preview is seen
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

        // while dragging, show a preview of the obstacle at the dragged location
        if let dragLocation = dragLocation {
            Image(uiImage: obstacleBlueprint.image)
                .resizable()
                .frame(width: obstacleBlueprint.viewWidth, height: obstacleBlueprint.viewHeight)
                .position(dragLocation)
                .opacity(0.5)
                .zIndex(1) // show this preview above other obstacles
        }
    }
}

struct ObstacleBlueprintView_Previews: PreviewProvider {
    static var previews: some View {
        ObstacleBlueprintView(
            obstacleBlueprint: ObstacleBlueprint.round(color: .blue, center: Point(x: 250, y: 250), radius: 30),
            onTap: {},
            onLongPress: {},
            onDragEnd: { _ in }
        )
    }
}
