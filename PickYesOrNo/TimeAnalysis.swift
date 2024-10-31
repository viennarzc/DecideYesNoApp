//
//  TimeAnalysis.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/31/24.
//

import Charts
import SwiftUI

struct TimeAnalysis {
    let timeOfDay: TimeOfDay
    let decisions: [DecisionModel]

    var total: Int {
        decisions.count
    }

    var yesCount: Int {
        decisions.filter { $0.answer == true }.count
    }

    var noCount: Int {
        decisions.filter { $0.answer == false }.count
    }

    var undecidedCount: Int {
        decisions.filter { $0.answer == nil }.count
    }

    var yesPercentage: Double {
        let decidedCount = yesCount + noCount
        return decidedCount > 0 ? Double(yesCount) / Double(decidedCount) : 0
    }
}

enum TimeOfDay: String, CaseIterable {
    case morning = "Morning" // 5:00 AM - 11:59 AM
    case afternoon = "Afternoon" // 12:00 PM - 4:59 PM
    case evening = "Evening" // 5:00 PM - 8:59 PM
    case night = "Night" // 9:00 PM - 4:59 AM

    var emoji: String {
        switch self {
        case .morning: return "🌅"
        case .afternoon: return "☀️"
        case .evening: return "🌆"
        case .night: return "🌙"
        }
    }

    static func forDate(_ date: Date) -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5 ..< 12:
            return .morning
        case 12 ..< 17:
            return .afternoon
        case 17 ..< 21:
            return .evening
        default:
            return .night
        }
    }
}

struct DecisionTimeAnalytics: View {
    let decisions: [DecisionModel]
    @State private var selectedTime: TimeOfDay?

    var timeAnalysis: [TimeAnalysis] {
        Dictionary(grouping: decisions) { decision in
            guard let date = decision.createdAt else {
                return .afternoon // Default fallback
            }
            return TimeOfDay.forDate(date)
        }
        .map { TimeAnalysis(timeOfDay: $0.key, decisions: $0.value) }
        .sorted { $0.timeOfDay.rawValue < $1.timeOfDay.rawValue }
    }

    @ViewBuilder
    fileprivate func insightsContainer() -> some View {
        // Insights
        if let mostProductiveTime = timeAnalysis.max(by: { $0.total < $1.total }),
           let bestDecisionTime = timeAnalysis.max(by: { $0.yesPercentage < $1.yesPercentage }) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Insights")
                    .font(.headline)
                    .padding(.top)

                Text("🎯 Most active: \(mostProductiveTime.timeOfDay.rawValue) (\(mostProductiveTime.total) decisions)")
                    .font(.subheadline)

                if bestDecisionTime.yesPercentage > 0 {
                    Text("✨ Most positive: \(bestDecisionTime.timeOfDay.rawValue) (\(Int(bestDecisionTime.yesPercentage * 100))% yes)")
                        .font(.subheadline)
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Chart {
                ForEach(timeAnalysis, id: \.timeOfDay) { analysis in
                    BarMark(
                        x: .value("Time", analysis.timeOfDay.rawValue),
                        y: .value("Total", analysis.total)
                    )
                    .foregroundStyle(by: .value("Type", "Total"))

                    BarMark(
                        x: .value("Time", analysis.timeOfDay.rawValue),
                        y: .value("Yes", analysis.yesCount)
                    )
                    .foregroundStyle(by: .value("Type", "Yes"))

                    BarMark(
                        x: .value("Time", analysis.timeOfDay.rawValue),
                        y: .value("No", analysis.noCount)
                    )
                    .foregroundStyle(by: .value("Type", "No"))
                }
            }
            .chartForegroundStyleScale([
                "Total": Color.blue.opacity(0.3),
                "Yes": Color.green,
                "No": Color.red,
            ])
            .frame(height: 200)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                    guard x >= 0, x < proxy.plotAreaSize.width else { return }

                                    let timeIndex = Int((x / proxy.plotAreaSize.width) * Double(TimeOfDay.allCases.count))
                                    guard timeIndex >= 0, timeIndex < TimeOfDay.allCases.count else { return }
                                    withAnimation {
                                        selectedTime = TimeOfDay.allCases[timeIndex]
                                        
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        selectedTime = nil
                                        
                                    }
                                }
                        )
                }
            }
            .overlay(alignment: .bottom) {
                TimeOfDayStat(
                    selectedTime: $selectedTime,
                    timeAnalysis: self.timeAnalysis
                )
            }

            insightsContainer()
        }
        .padding()
    }
}

// Preview provider
struct DecisionTimeAnalytics_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            DecisionTimeAnalytics(decisions: [
                DecisionModel(
                    id: "1",
                    title: "Morning Decision",
                    createdAtString: "2024-10-31T09:00:00.000Z",
                    answer: true
                ),
                DecisionModel(
                    id: "2",
                    title: "Afternoon Decision",
                    createdAtString: "2024-10-31T14:00:00.000Z",
                    answer: true
                ),
                DecisionModel(
                    id: "3",
                    title: "Afternoon Decision",
                    createdAtString: "2024-10-31T12:30:00.000Z",
                    answer: false
                ),
                DecisionModel(
                    id: "4",
                    title: "Night Decision",
                    createdAtString: "2024-10-31T19:30:00.000Z",
                    answer: nil
                ),
                DecisionModel(
                    id: "5",
                    title: "Morning Decision",
                    createdAtString: "2024-10-31T10:30:00.000Z",
                    answer: true
                ),
                DecisionModel(
                    id: "6",
                    title: "Morning Decision",
                    createdAtString: "2024-10-31T05:30:00.000Z",
                    answer: true
                ),
                DecisionModel(
                    id: "7",
                    title: "Morning Decision",
                    createdAtString: "2024-10-31T00:30:00.000Z",
                    answer: false
                ),
                
                // Add more sample decisions...
            ])
        }
    }
}
