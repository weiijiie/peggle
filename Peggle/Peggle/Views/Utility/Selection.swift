//
//  Selection.swift
//  Peggle

import SwiftUI

/// Helper view to select an element out of an array.
struct Selection<T: Equatable, ID: Hashable>: View {

    let selectionItems: [T]
    let id: KeyPath<T, ID>

    @Binding var selectedItem: T?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                let items = Array(selectionItems.enumerated())
                let elementKeyPath = \EnumeratedSequence<[T]>.Element.element

                ForEach(items, id: elementKeyPath.appending(path: id)) { index, item in
                    let selected = selectedItem != nil && item == selectedItem
                    Text(String(describing: item))
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selected ? Color(.systemGray4) : .white)
                        .onTapGesture { selectedItem = item }

                    // only display dividers between elements
                    if index != items.count - 1 {
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
}
