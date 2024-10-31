//
//  EmptyStateView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/31/24.
//
import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No Decisions Yet")
                .font(.headline)

            Text("Tap + to add your first decision")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
}
