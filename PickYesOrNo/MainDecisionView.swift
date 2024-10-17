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

struct MainDecisionView: View {
    @State private var decision: Decision
    @State private var showingAddNoteSheet = false

    init(decision: Decision) {
        _decision = State(initialValue: decision)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                GroupBox {
                    Text(decision.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()

                    HStack(spacing: 10) {
                        DecisionButton(title: "Yes", isSelected: decision.status == .yes, color: .green) {
                            updateDecision(.yes)
                        }

                        DecisionButton(title: "No", isSelected: decision.status == .no, color: .red) {
                            updateDecision(.no)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    DecisionButton(title: "Undecided", isSelected: decision.status == .undecided, color: .orange) {
                        updateDecision(.undecided)
                    }
                }
                .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Notes:")
                        .font(.headline)

                    if let latestNote = decision.notes.last {
                        Text(latestNote.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showingAddNoteSheet = true }) {
                        Label("Add Note", systemImage: "square.and.pencil")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: NavigationLink(destination: DecisionHistoryView()) {
                Image(systemName: "clock")
            })
            .sheet(isPresented: $showingAddNoteSheet) {
                AddNoteView(decision: $decision)
            }
        }
    }

    private func updateDecision(_ newStatus: DecisionStatus) {
        decision.status = newStatus
        decision.lastUpdated = Date()
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

// Example Data Structures (you would define these properly in your model)
struct Decision: Identifiable {
    let id: UUID
    let title: String
    var status: DecisionStatus
    var impacts: [Impact]
    var notes: [Note]
    var lastUpdated: Date

    static var example: Decision {
        Decision(id: UUID(), title: "Should I learn SwiftUI?", status: .undecided, impacts: [Impact(description: "Career Growth")], notes: [Note(content: "Seems promising for iOS development")], lastUpdated: Date())
    }
}

struct Impact: Identifiable {
    let id = UUID()
    let description: String
}

struct Note: Identifiable {
    let id = UUID()
    let content: String
}

// These views are not implemented here but would be necessary
struct DecisionHistoryView: View {
    var body: some View {
        Text("Decision History")
    }
}

struct AddNoteView: View {
    @Binding var decision: Decision
    var body: some View {
        Text("Add Note")
    }
}

struct AddImpactView: View {
    @Binding var decision: Decision
    var body: some View {
        Text("Add Impact")
    }
}

#Preview {
    MainDecisionView(decision: Decision.example)
}
