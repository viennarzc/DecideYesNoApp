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
    
    let id: String
    let title: String
    let createdAtString: String
    let lastUpdatedString: String?
    let answer: Bool?

    var createdAt: Date? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
        }

        return nil
    }

    var answerDecisionStatus: DecisionStatus {
        switch answer {
        case .some(true): return .yes
        case .some(false): return .no
        case .none: return .undecided
        }
    }

    private enum CodingKeys: CodingKey {
        case id
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
