//
//  DecisionHistory.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//
import Foundation

struct DecisionHistory {
    let id: String
    let decisionId: String
    let previousAnswer: Bool
    let newAnswer: Bool
    let changedAt: Date
}
