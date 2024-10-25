//
//  DecisionList.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//
struct DecisionList: Decodable {
    let total: Int
    let documents: [DecisionModel]
}
