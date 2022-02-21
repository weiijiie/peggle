//
//  LevelSelectionView.swift
//  Peggle

import SwiftUI

struct LevelSelectionView: View {

    @StateObject private var viewModel = LevelSelectionViewModel(repo: LevelBlueprintFileRepo())

    @State private var selectedName: String?

    let errorHandler = ErrorHandler()

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
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(viewModel.levelNames.enumerated()), id: \.element) { index, name in
                    let selected = selectedName != nil && name == selectedName
                    Text(name)
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selected ? Color(.systemGray4) : .white)
                        .onTapGesture { selectedName = name }

                    // only display dividers between elements
                    if index != viewModel.levelNames.count - 1 {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemGray6))
    }

    var controls: some View {
        HStack {
            Spacer()
            Button("Confirm") {
                guard let selectedName = selectedName else {
                    return
                }

                errorHandler.doWithErrorHandling {
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
        .withErrorHandler(errorHandler)
        .onAppear {
            errorHandler.doWithErrorHandling {
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
