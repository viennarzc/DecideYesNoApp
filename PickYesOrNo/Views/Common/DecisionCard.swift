//
//  DecisionCard.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/31/24.
//
import SwiftUI

struct DecisionCard: View {
    let decision: DecisionModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(decision.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)

            HStack {
                StatusBadge(status: decision.answerDecisionStatus)
                Spacer()
                if let date = decision.createdAt {
                    Text(
                        date.formatted(.dateTime.day(.twoDigits)
                            .month(.wide)
                            .weekday(.wide)
                            .hour(.defaultDigits(amPM: .wide)))
                    )
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: Color(.systemGray4).opacity(0.3), radius: 3, x: 0, y: 1)
        )
    }
}
