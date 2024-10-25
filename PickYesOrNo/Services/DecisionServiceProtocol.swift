//
//  DecisionServiceProtocol.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/20/24.
//

import Appwrite
import Foundation
import JSONCodable

protocol DecisionServiceProtocol {
    func createDecision(userId: String, answer: Bool) async throws -> DecisionModel
    func updateDecision(id: String, newAnswer: Bool) async throws -> DecisionModel
    func getDecision(id: String) async throws -> DecisionModel
    func getDecisionsForUser(userId: String) async throws -> [DecisionModel]
    func addNoteToDecision(decisionId: String, content: String) async throws -> Note
}

enum DecisionError: Error {
    case userNotLoggedIn
}

// Repository protocols (to be implemented with actual data storage logic)
protocol DecisionRepositoryProtocol {
    func create(_ DecisionModel: DecisionModel) async throws -> DecisionModel
    func update(_ DecisionModel: DecisionModel) async throws -> DecisionModel
    func get(id: String) async throws -> DecisionModel
    func getForUser(userId: String) async throws -> [DecisionModel]
}

protocol DecisionHistoryRepositoryProtocol {
    func create(_ history: DecisionHistory) async throws -> DecisionHistory
}

protocol NoteRepositoryProtocol {
    func create(_ note: Note) async throws -> Note
}

protocol UserServiceProtocol {
    func isUserLoggedIn(userId: String) async throws -> Bool
}
