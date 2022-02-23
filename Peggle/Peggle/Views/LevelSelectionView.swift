//
//  LevelSelectionView.swift
//  Peggle

import SwiftUI

struct LevelSelectionView: View {

    @StateObject private var viewModel = LevelSelectionViewModel(repo: LevelBlueprintFileRepo())

    @State private var selectedName: String?

    let handler = makeErrorHandler()

    /// onSelected is a callback that is called with the selected blueprint and the name of the blueprint as a tuple
    /// when a level has been selected
    let onSelected: (_ blueprint: LevelBlueprint, _ name: String) -> Void
    let onCancel: () -> Void

    var title: some View {
        Text("Select a Level")
            .font(.title)
            .padding()
    }

    var selection: some View {
        Selection(
            selectionItems: viewModel.levelNames.sorted(by: <),
            id: \.self,
            selectedItem: $selectedName
        )
    }

    var controls: some View {
        HStack {
            Spacer()
            Button("Confirm") {
                guard let selectedName = selectedName else {
                    return
                }

                handler.doWithErrorHandling {
                    let blueprint = try viewModel.loadLevelBlueprint(name: selectedName)
                    if let blueprint = blueprint {
                        onSelected(blueprint, selectedName)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            Button("Cancel", role: .cancel) {
                onCancel()
            }
            Spacer()
        }
        .padding()
    }

    var body: some View {
        VStack {
            title
            selection
            controls
        }
        .background(.white)
        .withErrorHandler(handler)
        .onAppear {
            handler.doWithErrorHandling {
                try viewModel.loadLevelNames()
            }
        }
    }
}

struct LevelSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LevelSelectionView(onSelected: { _, _ in }, onCancel: {})
    }
}
