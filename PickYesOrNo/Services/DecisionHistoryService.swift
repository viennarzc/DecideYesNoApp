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
    
    private let jsonDecoder: JSONDecoder
    
    init(client: Client, databaseId: String, decisionHistoryCollectionId: String) {
        self.databases = Databases(client)
        self.databaseId = databaseId
        self.decisionHistoryCollectionId = decisionHistoryCollectionId
        self.jsonDecoder = JSONDecoder()
    }
    
    // MARK: - Create History Entry
    func createHistoryEntry(_ form: CreateDecisionHistoryForm) async throws -> DecisionHistoryModel {
        let document = try await databases.createDocument(
            databaseId: databaseId,
            collectionId: decisionHistoryCollectionId,
            documentId: ID.unique(),
            data: form.toJson()
        )
        
        return try await mapToHistoryModel(data: document.data.toJson())
    }
    
    // MARK: - Get History for Decision
    func getHistoryForDecision(decisionId: String) async throws -> DecisionHistoryList {
        let documentList = try await databases.listDocuments(
            databaseId: databaseId,
            collectionId: decisionHistoryCollectionId,
            queries: [
                Query.equal("decision", value: decisionId),
                Query.orderDesc("createdAt")
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
            case .decodingFailed(let error):
                return "Failed to decode history model: \(error.localizedDescription)"
            }
        }
    }
}
