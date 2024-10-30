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
    let newAnswer: Bool?
    let createdAtString: String
    
    var createdAt: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" //ISO8601 Format
        let date = dateFormatter.date(from: createdAtString)
        return date
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case newAnswer
        case createdAtString = "$createdAt"
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


