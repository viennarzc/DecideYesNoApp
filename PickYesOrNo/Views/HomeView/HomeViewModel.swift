//
//  HomeViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/29/24.
//
import Appwrite
import Foundation

// MARK: - View Model

class HomeViewModel: ObservableObject {
    private var authService: AuthService
    private var decService: DecisionService
    private let defaultsManager: UserDefaultsManager

    @Published var recentDecisions: [DecisionModel] = []
    @Published var allDecisions: [DecisionModel] = []
    @Published var totalDecisions: Int = 0
    @Published var yesDecisions: Int = 0
    @Published var noDecisions: Int = 0
    @Published var undecidedDecisions: Int = 0
    @Published var thisMonthDecisions: Int = 0
    @Published var isLoading: Bool = false

    init(defaultsManager: UserDefaultsManager = UserDefaultsManager()) {
        self.defaultsManager = defaultsManager
        
        authService = AuthService(
            client: AppConfig.AppWrite.shared.client,
            accountService: AccountService(
                userDefaultsManager: defaultsManager
            )
        )

        decService = DecisionService(
            client: AppConfig.AppWrite.shared.client,
            databaseId: AppConfig.AppWrite.shared.databaseID,
            decisionsCollectionId: AppConfig.AppWrite.shared.decisionsCollectionID
        )
    }
    
    func updateLocalUser() async {
        guard let user = try? await authService.getCurrentUser() else { return }
        
        defaultsManager.saveUserId(user.id)
        defaultsManager.saveUserEmail(user.email)
        
    }

    func fetchData() {
        isLoading = true

        Task {
            do {
                let list = try await decService.getDecisionsForCurrentUser()
                await processDecisions(list)
            } catch {
                print("Error fetching decisions: \(error)")
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }

    @MainActor
    private func processDecisions(_ documents: DecisionList) {
        let decisions = documents.documents.compactMap { document -> DecisionModel? in
            return DecisionModel(
                id: document.id,
                title: document.title,
                createdAtString: document.createdAtString,
                lastUpdatedString: document.lastUpdatedString,
                answer: document.answer
            )
        }

        recentDecisions = decisions
        calculateStats(decisions)
    }

    private func calculateStats(_ decisions: [DecisionModel]) {
        totalDecisions = decisions.count
        yesDecisions = decisions
            .compactMap { $0.answer }
            .filter { $0 }.count
        noDecisions = decisions
            .compactMap { $0.answer }
            .filter { !$0 }.count
        
        undecidedDecisions = decisions
            .filter { $0.answerDecisionStatus == .undecided }.count

        let calendar = Calendar.current
        let thisMonth = calendar.component(.month, from: Date())

        thisMonthDecisions = decisions.filter {
            calendar.component(.month, from: $0.createdAt!) == thisMonth
        }.count
    }
}
