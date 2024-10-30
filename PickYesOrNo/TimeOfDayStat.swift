//
//  TimeOfDayStat.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/31/24.
//
import SwiftUI

struct TimeOfDayStat: View {
    @Binding var selectedTime: TimeOfDay?
    let timeAnalysis: [TimeAnalysis]

    var body: some View {
        if let selected = selectedTime,
           let analysis = timeAnalysis.first(where: { $0.timeOfDay == selected }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(selected.emoji)
                    Text(selected.rawValue)
                        .font(.headline)
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(analysis.total)")
                            .font(.title2)
                            .bold()
                    }

                    VStack(alignment: .leading) {
                        Text("Yes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(analysis.yesCount)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                    }

                    VStack(alignment: .leading) {
                        Text("No")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(analysis.noCount)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.red)
                    }

                    if analysis.undecidedCount > 0 {
                        VStack(alignment: .leading) {
                            Text("Pending")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(analysis.undecidedCount)")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(alignment: .center)
            .padding()
            .background(Color(.systemGray6))
            .shadow(radius: 4)
            .cornerRadius(10)
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            TimeOfDayStat(
                selectedTime: .constant(.afternoon),
                timeAnalysis: [.init(timeOfDay: .afternoon, decisions: [.example])]
            )
            
        }
    }
}
