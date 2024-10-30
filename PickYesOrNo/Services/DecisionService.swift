//
//  DecisionService.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//
import Appwrite
import Foundation
import JSONCodable

class DecisionService {
    private let databases: Databases
    private let databaseId: String
    private let decisionsCollectionId: String
    private let authService: AuthService

    private let jsonDecoder: JSONDecoder

    init(authService: AuthService, databaseId: String, decisionsCollectionId: String) {
        self.authService = authService
        databases = Databases(authService.getClient())
        self.databaseId = databaseId
        self.decisionsCollectionId = decisionsCollectionId
        jsonDecoder = JSONDecoder()
    }

    func createDecision(title: String, answer: Bool?) async throws {
        let currentUser = try await authService.getCurrentUser()

        let decHistory: [String: Any] = [
            "newAnswer": answer,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
        ]

        let data: [String: Any] = [
            "userId": currentUser.id,
            "answer": answer,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "lastUpdated": ISO8601DateFormatter().string(from: Date()),
            "title": title,
            "decisionHistory": [decHistory],
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

    func updateDecision(id: String, newAnswer: Bool?) async throws {
        let decision = try await databases.getDocument(
            databaseId: databaseId,
            collectionId: decisionsCollectionId,
            documentId: id
        )

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
    }

    func getDecision(id: String) async throws -> DecisionModel? {
        do {
            let document = try await databases.getDocument(
                databaseId: databaseId,
                collectionId: decisionsCollectionId,
                documentId: id
            )

            debugPrint("Document \(document.data.toJson)")

            let jsonString = try document.data.toJson()
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw DecisionError.invalidJsonData
            }
            return try jsonDecoder
                .decode(DecisionModel.self, from: jsonData)

        } catch let error {
            debugPrint("Error: ", error.localizedDescription)
        }

        return nil
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

    ///  Deletes a Decision
    /// - Parameter id: Document ID of the decision
    /// - Returns: Success Deletion
    func deleteDecision(id: String) async -> Bool {
        do {
            let result = try await databases.deleteDocument(
                databaseId: databaseId,
                collectionId: decisionsCollectionId,
                documentId: id
            )

            return true

        } catch let error {
            debugPrint(error.localizedDescription)
            return false
        }
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
