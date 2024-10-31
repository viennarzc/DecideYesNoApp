//
//  StatusBadge.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/31/24.
//
import SwiftUI

struct StatusBadge: View {
    let status: DecisionStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.2))
            )
            .foregroundColor(statusColor)
    }

    private var statusColor: Color {
        switch status {
        case .yes:
            return .green
        case .no:
            return .red
        case .undecided:
            return .orange
        }
    }
}
