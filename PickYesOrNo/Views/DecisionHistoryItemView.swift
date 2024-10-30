//
//  DecisionHistoryItemView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import SwiftUI

struct DecisionHistoryItemView: View {
    let history: DecisionHistoryModel

    var body: some View {
        GroupBox {
            HStack {
                // Answer indicator
                Circle()
                    .fill(color())
                    .frame(width: 10, height: 10)
                
                // Decision details
                Text(decisionAnswer)
                    .font(.headline)
                
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    
                    if let date = history.createdAt {
                        Text(date.formatted(date: .complete, time: .omitted))
                            .font(.caption)
                        
                        Text(date.formatted(date: .omitted, time: .standard))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            return dateString
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    func color() -> Color {
        guard let answer = history.newAnswer else { return Color.orange }

        return answer ? Color.green : Color.red
    }

    var decisionAnswer: String {
        guard let answer = history.newAnswer else { return "Undecided" }

        return answer ? "Yes" : "No"
    }
}

// Preview
struct DecisionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal state with data
            DecisionHistoryItemView(
                history: DecisionHistoryModel(
                    id: "",
                    newAnswer: true,
                    createdAtString: "2020-10-15T06:38:00.000+00:00")
            )
        }
    }
}
