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
    func createDecision(userId: String, answer: Bool) async throws -> Decision
    func updateDecision(id: String, newAnswer: Bool) async throws -> Decision
    func getDecision(id: String) async throws -> Decision
    func getDecisionsForUser(userId: String) async throws -> [Decision]
    func addNoteToDecision(decisionId: String, content: String) async throws -> Note
}

enum DecisionError: Error {
    case userNotLoggedIn
}

// Repository protocols (to be implemented with actual data storage logic)
protocol DecisionRepositoryProtocol {
    func create(_ decision: Decision) async throws -> Decision
    func update(_ decision: Decision) async throws -> Decision
    func get(id: String) async throws -> Decision
    func getForUser(userId: String) async throws -> [Decision]
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

import Foundation

struct DecisionHistory {
    let id: String
    let decisionId: String
    let previousAnswer: Bool
    let newAnswer: Bool
    let changedAt: Date
}

struct DecisionModel: Identifiable, Decodable {
    let id: String
    let title: String
    let createdAtString: String
    let lastUpdatedString: String?
    let answer: Bool?

    var createdAt: Date? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
        }

        return nil
    }

    var answerDecisionStatus: DecisionStatus {
        switch answer {
        case .some(true): return .yes
        case .some(false): return .no
        case .none: return .undecided
        }
    }

    private enum CodingKeys: CodingKey {
        case id
        case title
        case createdAt
        case lastUpdated
        case answer
    }

    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<DecisionModel.CodingKeys> = try decoder.container(keyedBy: DecisionModel.CodingKeys.self)

        id = try container.decode(String.self, forKey: DecisionModel.CodingKeys.id)
        title = try container.decode(String.self, forKey: DecisionModel.CodingKeys.title)
        createdAtString = try container
            .decode(String.self, forKey: .createdAt)
        lastUpdatedString = try container
            .decode(String.self, forKey: .lastUpdated)
        answer = try container.decodeIfPresent(Bool.self, forKey: .answer)
    }
}

struct DecisionList: Decodable {
    let total: Int
    let documents: [DecisionModel]
}
