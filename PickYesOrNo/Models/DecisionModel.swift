//
//  DecisionModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//
import Foundation

struct DecisionModel: Identifiable, Decodable {
    internal init(id: String, title: String, createdAtString: String, lastUpdatedString: String? = nil, answer: Bool? = nil) {
        self.id = id
        self.title = title
        self.createdAtString = createdAtString
        self.lastUpdatedString = lastUpdatedString
        self.answer = answer
    }

    let id: String //document id
    let title: String
    let createdAtString: String
    let lastUpdatedString: String?
    let answer: Bool?

    var createdAt: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" //ISO8601 Format
        let date = dateFormatter.date(from: createdAtString)
        return date
    }

    var answerDecisionStatus: DecisionStatus {
        switch answer {
        case .some(true): return .yes
        case .some(false): return .no
        case .none: return .undecided
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id = "$id"
        case title
        case createdAt
        case lastUpdated
        case answer
    }

    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<DecisionModel.CodingKeys> = try decoder.container(keyedBy: DecisionModel.CodingKeys.self)

        id = try container.decode(String.self, forKey: DecisionModel.CodingKeys.id)
        title = try container.decode(String.self, forKey: DecisionModel.CodingKeys.title)
        createdAtString = try container
            .decode(String.self, forKey: .createdAt)
        lastUpdatedString = try container
            .decode(String.self, forKey: .lastUpdated)
        answer = try container.decodeIfPresent(Bool.self, forKey: .answer)
    }
}
