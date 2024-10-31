//
//  MainDecisionViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Foundation

class MainDecisionViewModel: ObservableObject {
    private var decisionCoordinator: DecisionCoordinator
    private var authService: AuthService

    init() {
        authService = AuthService(
            client: AppConfig.AppWrite.shared.client,
            accountService: AccountService(
                userDefaultsManager: UserDefaultsManager()
            )
        )

        decisionCoordinator = DecisionCoordinator(
            client: AppConfig.AppWrite.shared.client,
            authService: authService,
            databaseId: AppConfig.AppWrite.shared.databaseID,
            decisionsCollectionId: AppConfig.AppWrite.shared.decisionsCollectionID,
            decisionHistoryCollectionId: AppConfig.AppWrite.shared.decisionsHistoryCollectionID
        )
    }

    func updateDecision(with id: String, to answer: Bool?) async {
        do {
            try await decisionCoordinator.updateDecision(id: id, answer: answer)

        } catch {
            debugPrint("error when updating: \(error.localizedDescription)")
        }
    }
    
    func deleteDecision(id: String) async -> Bool {
        let result = await decisionCoordinator.deleteDecision(id: id)
        
        return result
    }
    
    func getDecision(for id: String) async -> DecisionModel? {
        do {
            let decision = try await decisionCoordinator.getDecision(for: id)
            return decision
            
        } catch {
            debugPrint("error when getting decision: \(error.localizedDescription)")
            return nil
        }
    }
}
