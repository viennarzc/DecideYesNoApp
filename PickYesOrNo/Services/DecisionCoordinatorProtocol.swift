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
//    func createDecision(answer: Bool) async throws -> DecisionModel
    func updateDecision(id: String, answer: Bool?) async throws
//    func getDecision(id: String) async throws -> DecisionModel
//    func getDecisionsForCurrentUser() async throws -> DecisionList
//    func getDecisionHistory(decisionId: String) async throws -> DecisionHistoryList
}

class DecisionCoordinator: DecisionCoordinatorProtocol {

    private let decisionService: DecisionService
    private let historyService: DecisionHistoryService
    
    init(client: Client, 
         authService: AuthService,
         databaseId: String,
         decisionsCollectionId: String,
         decisionHistoryCollectionId: String) {
        
        // Initialize independent services
        self.decisionService = DecisionService(
            authService: authService,
            databaseId: databaseId,
            decisionsCollectionId: decisionsCollectionId
        )
        
        self.historyService = DecisionHistoryService(
            client: client,
            databaseId: databaseId,
            decisionHistoryCollectionId: decisionHistoryCollectionId
        )
    }
    
    // MARK: - Coordinated Operations
//    func createDecision(title: String, answer: Bool?) async throws -> DecisionModel {
        
//        let decision = try await decisionService.createDecision(
//            title: title,
//            answer: answer
//        )
//        
//        // Create initial history entry
//        let historyForm = CreateDecisionHistoryForm(
//            decisionId: decision.id,
//            newAnswer: answer
//        )
//        _ = try await historyService.createHistoryEntry(historyForm)
//        
//        return decision
//    }
    
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
//    func getDecision(id: String) async throws -> DecisionModel {
//        return try await decisionService.getDecision(id: id)
//    }
    
    func getDecisionsForCurrentUser() async throws -> DecisionList {
        return try await decisionService.getDecisionsForCurrentUser()
    }
    
    func getDecisionHistory(decisionId: String) async throws -> DecisionHistoryList {
        return try await historyService.getHistoryForDecision(decisionId: decisionId)
    }
}

// MARK: - Convenience Methods
extension DecisionCoordinator {
//    func getDecisionWithHistory(id: String) async throws -> (decision: DecisionModel, history: DecisionHistoryList) {
//        async let decision = getDecision(id: id)
//        async let history = getDecisionHistory(decisionId: id)
//        return try await (decision, history)
//    }
}
