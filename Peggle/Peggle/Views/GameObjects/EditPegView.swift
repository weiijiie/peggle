//
//  EditPegView.swift
//  Peggle

import SwiftUI
import Physics

struct EditPegView: View {

    let viewWidth: CGFloat = 300

    let pegBlueprint: PegBlueprint

    @Binding var show: Bool
    @Binding var isEditing: Bool

    @Binding var rotation: Degrees
    @Binding var scale: Double

    let onUpdate: (PegBlueprint) -> Bool

    init(
        pegBlueprint: PegBlueprint,
        show: Binding<Bool>,
        isEditing: Binding<Bool>,
        rotation: Binding<Degrees>,
        scale: Binding<Double>,
        onUpdate: @escaping (PegBlueprint) -> Bool
    ) {
        self.pegBlueprint = pegBlueprint
        self._show = show
        self._isEditing = isEditing
        self._rotation = rotation
        self._scale = scale
        self.onUpdate = onUpdate
    }

    func slider<T, Title, Icon>(
        label: Label<Title, Icon>,
        binding: Binding<T>,
        in range: ClosedRange<T>,
        pegBlueprintUpdater: @escaping (T) -> PegBlueprint,
        resetFunc: @escaping () -> Void
    ) -> some View where T: BinaryFloatingPoint, T.Stride: BinaryFloatingPoint {
        HStack(spacing: 12) {
            label
                .labelStyle(.iconOnly)
                .foregroundColor(.primary)
                .font(.headline)
            Slider(
                value: binding, in: range,
                onEditingChanged: { started in
                    // if the user has stopped adjusting the slider, then call the
                    // onUpdate callback to propagate the changes to the parent
                    if !started {
                        let updated = onUpdate(pegBlueprintUpdater(binding.wrappedValue))
                        if !updated {
                            resetFunc()
                        }
                    }

                    isEditing = started
                }
            )
        }
    }

    // close to invisible background that allows players to tap
    // outside the edit panel to close it
    var tapToCloseBackground: some View {
        Color.white
            .opacity(0.001)
            .ignoresSafeArea()
            .zIndex(0)
            .onTapGesture { show = false }

    }

    var popupBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.thinMaterial)
            .shadow(color: .gray, radius: 6)
            .opacity(0.65)
    }

    var closeButton: some View {
        Button {
            show = false
        } label: {
            Label("hello", systemImage: "x.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundColor(.red)
                .font(.title3)
        }
    }

    var sliders: some View {
        VStack {
            slider(
                label: Label("Rotation", systemImage: "arrow.clockwise"),
                binding: $rotation,
                in: 0...360,
                pegBlueprintUpdater: pegBlueprint.withRotation,
                resetFunc: { rotation = pegBlueprint.rotation }
            )
            slider(
                label: Label("Scale", systemImage: "arrow.up.left.and.arrow.down.right"),
                binding: $scale,
                in: 1.0...2.5,
                pegBlueprintUpdater: pegBlueprint.scaled,
                resetFunc: { scale = pegBlueprint.scale }
            )
        }
        .padding([.bottom, .leading, .trailing])
    }

    var body: some View {
        GeometryReader { geometry in
            let centerX = pegBlueprint.center.x + 200
            let exceedsTrailingBoundary = exceedsTrailingBoundary(
                x: centerX,
                width: viewWidth,
                geometry: geometry
            )

            ZStack {
                tapToCloseBackground
                VStack {
                    HStack {
                        Spacer()
                        closeButton
                    }
                    sliders
                }
                .padding(3)
                .frame(width: viewWidth)
                .background(popupBackground)
                .position(
                    x: exceedsTrailingBoundary ? pegBlueprint.center.x - 200 : centerX,
                    y: pegBlueprint.center.y)
                .zIndex(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)    }

    private func exceedsTrailingBoundary(
        x: CGFloat,
        width: CGFloat,
        geometry: GeometryProxy
    ) -> Bool {
        let maxX = x + width / 2
        return maxX > geometry.frame(in: .local).maxX
    }
}
