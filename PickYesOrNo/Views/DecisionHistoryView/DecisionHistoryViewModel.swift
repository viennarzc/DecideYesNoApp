//
//  DecisionHistoryViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Foundation

class DecisionHistoryViewModel: ObservableObject {
    private let decisionHistoryService: DecisionHistoryService
    let decisionID: String

    @Published private(set) var historyList: DecisionHistoryList?

    init(decisionID: String) {
        decisionHistoryService = DecisionHistoryService(
            client: AppConfig.AppWrite.shared.client,
            databaseId: AppConfig.AppWrite.shared.databaseID,
            decisionHistoryCollectionId: AppConfig.AppWrite.shared.decisionsHistoryCollectionID
        )

        self.decisionID = decisionID
    }

    @MainActor
    func getHistoryList() async {
        do {
            let list = try await decisionHistoryService.getHistoryForDecision(decisionId: decisionID)
            historyList = list

        } catch {
            debugPrint("error when getting decision history list", error.localizedDescription)
        }
    }
}
