//
//  DecisionHistoryList.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//


struct DecisionHistoryList: Decodable {
    let total: Int
    let documents: [DecisionHistoryModel]
}