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
        let decisions = try? await decService.getDecisionsForCurrentUser()
        self.decisions = decisions
        
    }
}

struct DecisionListMainView: View {
    
    @StateObject private var viewModel = DecisionListMainViewModel()
    @Environment(\.colorScheme) var colorScheme
       
       var body: some View {
           NavigationView {
               ScrollView {
                   if viewModel.isLoading {
                       ProgressView()
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                           .padding(.top, 40)
                   } else if let decisions = viewModel.decisions {
                       LazyVStack(spacing: 12) {
                           ForEach(decisions.documents) { decision in
                               NavigationLink(
                                destination: {
                                    MainDecisionView(decision: decision)
                                }
                               ) {
                                   DecisionCard(decision: decision)
                               }
                           }
                       }
                       .padding(.horizontal)
                   } else {
                       EmptyStateView()
                   }
               }
               .navigationTitle("Decisions")
               .toolbar {
                   ToolbarItem(placement: .primaryAction) {
                       Button(action: {
                           // Add new decision action
                       }) {
                           Image(systemName: "plus.circle.fill")
                               .imageScale(.large)
                       }
                   }
               }
           }
           .task {
               await viewModel.getDecisions()
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
                    Text(date.formatted(.relative(presentation: .named)))
                }
                
                Text(Date.now.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
