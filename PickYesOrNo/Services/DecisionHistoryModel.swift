//
//  DecisionHistoryModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//


import Foundation
import Appwrite

// MARK: - Models
struct DecisionHistoryModel: Decodable {
    let id: String
    let decision: DecisionModel
    let newAnswer: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case decision
        case newAnswer
        case createdAt
    }
}

struct DecisionHistoryList: Decodable {
    let total: Int
    let documents: [DecisionHistoryModel]
}

struct CreateDecisionHistoryForm {
    let decisionId: String
    let newAnswer: Bool?
    
    func toJson() -> [String: Any] {
        return [
            "decision": decisionId,
            "newAnswer": newAnswer,
            "createdAt": ISO8601DateFormatter().string(from: Date())
        ]
    }
}


