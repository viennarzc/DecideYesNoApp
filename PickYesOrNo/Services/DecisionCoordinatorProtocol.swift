//
//  DecisionCoordinatorProtocol.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//


import Foundation
import Appwrite

// MARK: - Decision Coordinator
protocol DecisionCoordinatorProtocol {
    func updateDecision(id: String, answer: Bool?) async throws
}

class DecisionCoordinator: DecisionCoordinatorProtocol {

    private let decisionService: DecisionService
    private let historyService: DecisionHistoryService
    private let account: Account
    
    init(client: Client, 
         authService: AuthService,
         databaseId: String,
         decisionsCollectionId: String,
         decisionHistoryCollectionId: String) {
        
        // Initialize independent services
        self.decisionService = DecisionService(
            client: client,
            databaseId: databaseId,
            decisionsCollectionId: decisionsCollectionId
        )
        
        self.historyService = DecisionHistoryService(
            client: client,
            databaseId: databaseId,
            decisionHistoryCollectionId: decisionHistoryCollectionId
        )
        
        account = Account(client)
    }
    
    // MARK: - Coordinated Operations
    
    func updateDecision(id: String, answer: Bool?) async throws {
        // First update the decision
        
        let updatedDecision = try await decisionService.updateDecision(
            id: id,
            newAnswer: answer
        )
        
        // Then create history entry
        let historyForm = CreateDecisionHistoryForm(
            decisionId: id,
            newAnswer: answer
        )
        _ = try await historyService.createHistoryEntry(historyForm)
    }
    
    // MARK: - Pass-through Operations
    
    func getDecisionsForCurrentUser() async throws -> DecisionList {
        return try await decisionService.getDecisionsForCurrentUser()
    }
    
    func getDecisionHistory(decisionId: String) async throws -> DecisionHistoryList {
        return try await historyService.getHistoryForDecision(decisionId: decisionId)
    }
}

// MARK: - Convenience Methods
extension DecisionCoordinator {
    func getDecisionWithHistory(id: String) async throws -> (decision: DecisionModel?, history: DecisionHistoryList) {
        async let decision = decisionService.getDecision(id: id)
        async let history = getDecisionHistory(decisionId: id)
        return try await (decision, history)
    }
}
