//
//  DecisionListMainView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/24/24.
//

import SwiftUI


// MARK: - Main View
struct DecisionListMainView: View {
    @StateObject private var viewModel = DecisionListMainViewModel()
    @State private var isPresentingCreateDecisions = false
    @State private var hasSession = false
    @State private var isPresentingLoginView = false

    var body: some View {
        NavigationStack {
            ScrollView {
                DecisionListContent(
                    dataState: viewModel.dataState,
                    decisions: viewModel.decisions?.documents ?? [],
                    hasSession: hasSession,
                    onDeleteDecision: { decisionId in
                        Task {
                            await viewModel.deleteDecision(id: decisionId)
                            await viewModel.getDecisions()
                        }
                    },
                    onDecisionUpdate: {
                        Task {
                            await viewModel.getDecisions()
                        }
                    },
                    onLoginTap: {
                        isPresentingLoginView = true
                    }
                )
            }
            .navigationTitle("Decisions")
            .toolbar {
                CreateDecisionButton(isPresenting: $isPresentingCreateDecisions)
            }
        }
        .sheet(isPresented: $isPresentingCreateDecisions) {
            CreateDecisionView()
        }
        .onChange(of: isPresentingCreateDecisions) { oldValue, newValue in
            if oldValue, !newValue {
                Task {
                    await viewModel.getDecisions()
                }
            }
        }
        .sheet(isPresented: $isPresentingLoginView) {
            LoginView(onSuccessLogin: {
                isPresentingLoginView = false
                Task {
                    await viewModel.getDecisions()
                }
            })
        }
        .task {
            await viewModel.getDecisions()
            hasSession = await viewModel.getSession() ?? false
        }
    }
}

// MARK: - Content View
private struct DecisionListContent: View {
    let dataState: DecisionListMainViewModel.DataState
    let decisions: [DecisionModel]
    let hasSession: Bool
    let onDeleteDecision: (String) -> Void
    let onDecisionUpdate: () -> Void
    let onLoginTap: () -> Void
    
    var body: some View {
        switch dataState {
        case .isFetching:
            LoadingView()
        case .populated:
            DecisionListView(
                decisions: decisions,
                onDeleteDecision: onDeleteDecision,
                onDecisionUpdate: onDecisionUpdate
            )
        case .error:
            ErrorView()
        case .empty:
            EmptyStateContent(
                hasSession: hasSession,
                onLoginTap: onLoginTap
            )
        }
    }
}

// MARK: - List View
private struct DecisionListView: View {
    let decisions: [DecisionModel]
    let onDeleteDecision: (String) -> Void
    let onDecisionUpdate: () -> Void
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(decisions) { decision in
                DecisionListItem(
                    decision: decision,
                    onDelete: {
                        onDeleteDecision(decision.id)
                    },
                    onUpdate: onDecisionUpdate
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - List Item
private struct DecisionListItem: View {
    let decision: DecisionModel
    let onDelete: () -> Void
    let onUpdate: () -> Void
    
    var body: some View {
        NavigationLink(
            destination: MainDecisionView(
                decision: decision,
                onEvent: { _ in
                    onUpdate()
                }
            )
        ) {
            DecisionCard(decision: decision)
                .tint(.black)
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Supporting Views
private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 40)
    }
}

private struct ErrorView: View {
    var body: some View {
        Text("Error")
    }
}

private struct EmptyStateContent: View {
    let hasSession: Bool
    let onLoginTap: () -> Void
    
    var body: some View {
        if hasSession {
            EmptyStateView()
        } else {
            ContentUnavailableView {
                Text("Login Required")
            } description: {
                Text("You must login to able to create, and see the list of decisions")
            } actions: {
                Button(action: onLoginTap) {
                    Text("Login")
                        .fontWeight(.bold)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

private struct CreateDecisionButton: ToolbarContent {
    @Binding var isPresenting: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isPresenting = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DecisionListMainView()
}
