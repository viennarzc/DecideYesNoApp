//
//  DecisionHistoryService.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Appwrite
import Foundation
import JSONCodable

class DecisionHistoryService {
    private let databases: Databases
    private let databaseId: String
    private let decisionHistoryCollectionId: String
    private let userDefaultsManager: UserDefaultsManager

    private let jsonDecoder: JSONDecoder
    private let account: Account

    init(client: Client, databaseId: String, decisionHistoryCollectionId: String) {
        databases = Databases(client)
        userDefaultsManager = UserDefaultsManager()
        self.databaseId = databaseId
        self.decisionHistoryCollectionId = decisionHistoryCollectionId
        jsonDecoder = JSONDecoder()
        
        account = Account(client)
    }

    // MARK: - Create History Entry

    func createHistoryEntry(_ form: CreateDecisionHistoryForm) async throws -> DecisionHistoryModel {
        let appwriteUser = try await account.get()
        let userId = appwriteUser.id
        
        let document = try await databases.createDocument(
            databaseId: databaseId,
            collectionId: decisionHistoryCollectionId,
            documentId: ID.unique(),
            data: form.toJson(),
            permissions: [
                Permission.delete(Role.user(userId)),
                Permission.write(Role.users()),
                Permission.update(Role.user(userId)),
                Permission.read(Role.user(userId)),
            ]
        )

        return try await mapToHistoryModel(data: document.data.toJson())
    }

    // MARK: - Get History for Decision

    func getHistoryForDecision(decisionId: String) async throws -> DecisionHistoryList {
        let documentList = try await databases.listDocuments(
            databaseId: databaseId,
            collectionId: decisionHistoryCollectionId,
            queries: [
//                Query.equal("decision", value: decisionId),
                Query.orderDesc("createdAt"),
            ]
        )

        return try await mapToHistoryList(documentList)
    }

    // MARK: - Private Mapping Methods

    private func mapToHistoryModel(data jsonString: String) async throws -> DecisionHistoryModel {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw DecisionHistoryError.invalidJsonData
        }

        do {
            return try jsonDecoder.decode(DecisionHistoryModel.self, from: jsonData)
        } catch {
            throw DecisionHistoryError.decodingFailed(error)
        }
    }

    private func mapToHistoryList(_ documentList: DocumentList<[String: AnyCodable]>) async throws -> DecisionHistoryList {
        
        let historyEntries = try await withThrowingTaskGroup(of: DecisionHistoryModel.self) { group in
            for document in documentList.documents {
                group.addTask {
                    let jsonString = try document.data.toJson()
                    guard let jsonData = jsonString.data(using: .utf8) else {
                        throw DecisionHistoryError.invalidJsonData
                    }
                    return try self.jsonDecoder.decode(DecisionHistoryModel.self, from: jsonData)
                }
            }

            var entries: [DecisionHistoryModel] = []
            for try await entry in group {
                entries.append(entry)
            }
            return entries
        }

        return DecisionHistoryList(total: documentList.total, documents: historyEntries)
    }

    // MARK: - Error Handling

    enum DecisionHistoryError: LocalizedError {
        case invalidJsonData
        case decodingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .invalidJsonData:
                return "Failed to convert history document data to JSON"
            case let .decodingFailed(error):
                return "Failed to decode history model: \(error.localizedDescription)"
            }
        }
    }
}
