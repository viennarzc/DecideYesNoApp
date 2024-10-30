//
//  CreateDecisionHistoryForm.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//


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