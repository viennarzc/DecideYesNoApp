//
//  DecisionListMainViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Foundation

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
            decisionsCollectionId: AppConfig.AppWrite.shared.decisionsCollectionID
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
