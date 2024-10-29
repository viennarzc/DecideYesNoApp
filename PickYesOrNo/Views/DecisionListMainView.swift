//
//  DecisionListMainView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/24/24.
//

import SwiftUI

class DecisionListMainViewModel: ObservableObject {
    private var authService: AuthService
    private var decService: DecisionService

    @Published private(set) var decisions: DecisionList? = nil
    @Published private(set) var isLoading = false

    enum DataState {
        case isFetching
        case populated
        case error
        case empty
    }

    @Published private(set) var dataState: DataState = .isFetching

    init() {
        authService = AuthService(
            client: AppConfig.AppWrite.shared.client,
            accountService: AccountService(
                userDefaultsManager: UserDefaultsManager()
            )
        )

        decService = DecisionService(
            authService: authService,
            databaseId: AppConfig.AppWrite.shared.databaseID,
            decisionsCollectionId: AppConfig.AppWrite.shared.decisionsCollectionID,
            decisionHistoryCollectionId: "",
            notesCollectionId: ""
        )
    }

    @MainActor
    func getDecisions() async {
        isLoading = true
        let decisions = try? await decService.getDecisionsForCurrentUser()
        self.decisions = decisions

        if let decisions = decisions {
            dataState = decisions.documents.isEmpty ? .empty : .populated
        } else {
            dataState = .empty
        }

        isLoading = false
    }

    @MainActor
    func getSession() async -> Bool? {
        let session = try? await authService.getSession()
        return session?.current ?? false
    }
    
    func deleteDecision(id: String) async -> Bool {
        let result = await decService.deleteDecision(id: id)
        
        return result
    }
}

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
                                        MainDecisionView(decision: decision)
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
                            }

                        }

                        Text("You must log in")
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
        .sheet(isPresented: $isPresentingLoginView, content: {
            LoginView(onSuccessLogin: {
                isPresentingLoginView = false
                
                Task {
                    await viewModel.getDecisions()
                }
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
