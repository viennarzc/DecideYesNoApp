//
//  DecisionListMainView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/24/24.
//

import SwiftUI


struct DecisionListMainView: View {
    @StateObject private var viewModel = DecisionListMainViewModel()
    @Environment(\.colorScheme) var colorScheme

    @State private var isPresentingCreateDecisions: Bool = false
    @State private var hasSession: Bool = false
    @State private var isPresentingLoginView: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                switch viewModel.dataState {
                case .isFetching:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)

                case .populated:

                    if let decisions = viewModel.decisions {
                        LazyVStack(spacing: 12) {
                            ForEach(decisions.documents) { decision in
                                NavigationLink(
                                    destination: {
                                        MainDecisionView(
                                            decision: decision,
                                            onEvent: { event in
                                                Task {
                                                    await viewModel.getDecisions()
                                                }
                                            }
                                        )
                                    }
                                ) {
                                    DecisionCard(decision: decision)
                                        .tint(.black)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel
                                                .deleteDecision(id: decision.id)
                                            
                                            await viewModel.getDecisions()
                                        }
                                        
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                case .error:
                    Text("Error")
                case .empty:
                    if hasSession {
                        EmptyStateView()

                    } else {
                        ContentUnavailableView {
                            Text("Login Required")
                        } description: {
                            Text("You must login to able to create, and see the list of decisions")
                        } actions: {
                            Button {
                                isPresentingLoginView = true
                            } label: {
                                Text("Login")
                                    .fontWeight(.bold)
                            }
                            .buttonBorderShape(.capsule)
                            .buttonStyle(BorderedProminentButtonStyle())

                        }
                    }
                }
            }
            .navigationTitle("Decisions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isPresentingCreateDecisions = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingCreateDecisions, content: {
            CreateDecisionView()
        })
        .onChange(of: isPresentingCreateDecisions, { oldValue, newValue in
            if oldValue, !newValue {
                Task {
                    await viewModel.getDecisions()
                }
            }
        })
        .sheet(isPresented: $isPresentingLoginView, content: {
            LoginView(onSuccessLogin: {
                isPresentingLoginView = false
                
                Task {
                    await viewModel.getDecisions()
                }
            }, onTapSignup: {
                
            })
        })
        .task {
            await viewModel.getDecisions()
        }
        .task {
            hasSession = await viewModel.getSession() ?? false
        }
    }
}

#Preview {
    DecisionListMainView()
}

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
