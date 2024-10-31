//
//  CreateDecisionViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Foundation
import Combine

@MainActor
class CreateDecisionViewModel: ObservableObject {
    
    @Published var form = CreateDecisionForm(title: "", answer: false)
    @Published var showError = false
    @Published var errorMessage = ""
    @Published private(set) var isCreating = false
    
    let onSuccessCreateDecision = PassthroughSubject<Void, Error>()
    
    private let decisionService: DecisionService
    
    var isValid: Bool {
        !form.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init() {
        // Initialize your services here similar to the list view
        let authService = AuthService(
            client: AppConfig.AppWrite.shared.client,
            accountService: AccountService(
                userDefaultsManager: UserDefaultsManager()
            )
        )
        
        decisionService = DecisionService(
            client: AppConfig.AppWrite.shared.client,
            databaseId: AppConfig.AppWrite.shared.databaseID,
            decisionsCollectionId: AppConfig.AppWrite.shared.decisionsCollectionID
        )
    }
    
    func createDecision() async {
        guard isValid else { return }
        
        isCreating = true
        defer { isCreating = false }
        
        do {
            // Assuming your DecisionService has a create method
            try await decisionService
                .createDecision(title: form.title, answer: form.answer)
            onSuccessCreateDecision.send(())
            
        } catch {
            debugPrint(error.localizedDescription)
            showError = true
            onSuccessCreateDecision.send(completion: .failure(error))
            errorMessage = "Failed to create decision: \(error.localizedDescription)"
        }
    }
}
