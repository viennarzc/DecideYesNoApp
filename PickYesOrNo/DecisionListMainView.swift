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
    
    var body: some View {
        ScrollView {
            VStack {
                if let decisions = viewModel.decisions {
                    ForEach(decisions.documents) { decision in
                        Text(decision.title)
                        
                        Divider()
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
