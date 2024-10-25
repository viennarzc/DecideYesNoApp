//
//  MainDecisionView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/18/24.
//

import SwiftUI

enum DecisionStatus: String {
    case yes = "Yes"
    case no = "No"
    case undecided = "Undecided"
}

extension DecisionStatus {
    var recordValue: Bool? {
        switch self {
        case .yes:
            return true
        case .no:
            return false
        case .undecided:
            return nil
        }
    }
}

struct MainDecisionView: View {
    @State private var decision: DecisionModel
    @State private var showingAddNoteSheet = false

    init(decision: DecisionModel) {
        _decision = State(initialValue: decision)
    }

    var body: some View {
        
            ScrollView {
                VStack(spacing: 20) {
                    GroupBox {
                        Text(decision.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()

                        HStack(spacing: 10) {
                            DecisionButton(
                                title: "Yes",
                                isSelected: decision.answerDecisionStatus == .yes,
                                color: .green
                            ) {
                                updateDecision(.yes)
                            }

                            DecisionButton(title: "No", isSelected: decision.answerDecisionStatus == .no, color: .red) {
                                updateDecision(.no)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        DecisionButton(title: "Undecided", isSelected: decision.answerDecisionStatus == .undecided, color: .orange) {
                            updateDecision(.undecided)
                        }
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes:")
                            .font(.headline)

//                        if let latestNote = decision.notes.last {
//                            Text(latestNote.content)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }

                        Button(action: { showingAddNoteSheet = true }) {
                            Label("Add Note", systemImage: "square.and.pencil")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    Spacer()
                }
                .navigationTitle("Decision")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        NavigationLink(destination: DecisionHistoryView()) {
                            Image(systemName: "clock")
                        }
                        Button("Edit") {
                            // Action for Edit
                        }
                    }
                }
                .sheet(isPresented: $showingAddNoteSheet) {
                    Text("Add Note")
                }
            }
    }

    private func updateDecision(_ newStatus: DecisionStatus) {
//        decision.answer = newStatus.recordValue
//        decision.lastUpdated = Date()
        // Here you would also call a function to update the decision in the backend
    }
}

struct DecisionButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 64)
                .cornerRadius(10)
        }
        .tint(getBackgroundColor())
        .buttonStyle(BorderedProminentButtonStyle())
    }

    func getBackgroundColor() -> Color {
        return isSelected ? color : Color.secondary
    }
}

struct ImpactBadge: View {
    let impact: Impact

    var body: some View {
        Text(impact.description)
            .font(.caption)
            .padding(5)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(5)
    }
}

struct Impact: Identifiable {
    let id = UUID().uuidString
    let description: String
}

struct Note: Identifiable {
    let id = UUID().uuidString
    let content: String
}

// These views are not implemented here but would be necessary
struct DecisionHistoryView: View {
    var body: some View {
        Text("Decision History")
    }
}

#Preview {
    NavigationStack {
        MainDecisionView(decision: DecisionModel.example)
    }
}

extension DecisionModel {
    static var example: DecisionModel {
        DecisionModel(
            id: UUID().uuidString,
            title: "Example Title",
            createdAtString: Date.now.formatted()
        )
    }
}
