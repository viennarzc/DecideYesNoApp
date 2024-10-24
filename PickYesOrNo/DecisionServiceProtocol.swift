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

class DecisionService {
    private let databases: Databases
    private let databaseId: String
    private let decisionsCollectionId: String
    private let decisionHistoryCollectionId: String
    private let notesCollectionId: String
    private let authService: AuthService

    init(authService: AuthService, databaseId: String, decisionsCollectionId: String, decisionHistoryCollectionId: String, notesCollectionId: String) {
        self.authService = authService
        databases = Databases(authService.getClient())
        self.databaseId = databaseId
        self.decisionsCollectionId = decisionsCollectionId
        self.decisionHistoryCollectionId = decisionHistoryCollectionId
        self.notesCollectionId = notesCollectionId
    }

    func createDecision(answer: Bool) async throws {
        let currentUser = try await authService.getCurrentUser()
        let data: [String: Any] = [
            "userId": currentUser.id,
            "answer": answer,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "lastUpdated": ISO8601DateFormatter().string(from: Date()),
            "title": "Some title",
            "id": ID.unique(),
        ]

        let document = try await databases.createDocument(
            databaseId: databaseId,
            collectionId: decisionsCollectionId,
            documentId: ID.unique(),
            data: data,
            permissions: [
                Permission.delete(Role.user(currentUser.id)),
                Permission.write(Role.users()),
                Permission.update(Role.user(currentUser.id)),
                Permission.read(Role.user(currentUser.id)),
            ] // optional
        )
        debugPrint("Document \(document.data)")
    }

    func updateDecision(id: String, newAnswer: Bool) async throws {
        let decision = try await databases.getDocument(
            databaseId: databaseId,
            collectionId: decisionsCollectionId,
            documentId: id
        )

        let oldAnswer = decision.data["answer"] as? Bool ?? false
        let updateData: [String: Any] = [
            "answer": newAnswer,
            "lastUpdated": ISO8601DateFormatter().string(from: Date()),
        ]

        let updatedDecision = try await databases.updateDocument(
            databaseId: databaseId,
            collectionId: decisionsCollectionId,
            documentId: id,
            data: updateData
        )

        // Create decision history
        let historyData: [String: Any] = [
            "decisionId": id,
            "previousAnswer": oldAnswer,
            "newAnswer": newAnswer,
            "changedAt": ISO8601DateFormatter().string(from: Date()),
        ]

        let document = try await databases.createDocument(
            databaseId: databaseId,
            collectionId: decisionHistoryCollectionId,
            documentId: ID.unique(),
            data: historyData
        )
        debugPrint("Document \(document)")
    }

    func getDecision(id: String) async throws {
        do {
            let document = try await databases.getDocument(
                databaseId: databaseId,
                collectionId: decisionsCollectionId,
                documentId: id
            )

            debugPrint("Document \(document.toMap())")

        } catch let error {
            debugPrint("Error: ", error.localizedDescription)
        }
    }

    func getDecisionsForCurrentUser() async throws -> DecisionList {
        let documentList = try await databases.listDocuments(
            databaseId: databaseId,
            collectionId: decisionsCollectionId,
            queries: [] // we can add query - userId, though through the permissions in collection, the current user should only fetch what the user created
        )
        debugPrint("document List total \(documentList.total)")

        return try await mapToDecisionList(documentList)
    }

    func addNoteToDecision(decisionId: String, content: String) async throws {
        let noteData: [String: Any] = [
            "decisionId": decisionId,
            "content": content,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
        ]

        let document = try await databases.createDocument(
            databaseId: databaseId,
            collectionId: notesCollectionId,
            documentId: ID.unique(),
            data: noteData
        )
    }

    // MARK: - Error Handling

    enum DecisionError: LocalizedError {
        case invalidJsonData
        case decodingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .invalidJsonData:
                return "Failed to convert document data to JSON"
            case let .decodingFailed(error):
                return "Failed to decode decision model: \(error.localizedDescription)"
            }
        }
    }

    private func mapToDecisionList(_ documentList: DocumentList<[String: AnyCodable]>) async throws -> DecisionList {
        let decisions = try documentList.documents.map { document -> DecisionModel in
            // Convert document data to JSON string
            let jsonString = try document.data.toJson()

            guard let jsonData = jsonString.data(using: .utf8) else {
                throw DecisionError.invalidJsonData
            }

            do {
                let model = try JSONDecoder().decode(
                    DecisionModel.self,
                    from: jsonData
                )
                return model
            } catch {
                throw DecisionError.decodingFailed(error)
            }
        }

        return DecisionList(total: documentList.total, documents: decisions)
    }
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

struct DecisionModel: Identifiable, Codable {
    let id: String
    let title: String

    private enum CodingKeys: CodingKey {
        case id
        case title
    }

    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<DecisionModel.CodingKeys> = try decoder.container(keyedBy: DecisionModel.CodingKeys.self)

        id = try container.decode(String.self, forKey: DecisionModel.CodingKeys.id)
        title = try container.decode(String.self, forKey: DecisionModel.CodingKeys.title)
    }

    func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<DecisionModel.CodingKeys> = encoder.container(keyedBy: DecisionModel.CodingKeys.self)

        try container.encode(id, forKey: DecisionModel.CodingKeys.id)
        try container.encode(title, forKey: DecisionModel.CodingKeys.title)
    }
}

struct DecisionList: Codable {
    let total: Int
    let documents: [DecisionModel]
}
