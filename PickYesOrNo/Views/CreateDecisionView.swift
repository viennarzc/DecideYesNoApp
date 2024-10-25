//
//  CreateDecisionView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//
import SwiftUI

struct CreateDecisionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateDecisionViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("What's your decision about?", text: $viewModel.form.title)
                        .autocapitalization(.sentences)
                } header: {
                    Text("Decision")
                } footer: {
                    Text("Be clear and specific about what you're deciding")
                }
                
                Section {
                    VStack {
                        HStack(spacing: 10) {
                            DecisionButton(
                                title: "Yes",
                                isSelected: viewModel.form.answer == true,
                                color: .green
                            ) {
                                updateDecision(.yes)
                            }
                            
                            DecisionButton(title: "No", isSelected: viewModel.form.answer == false , color: .red) {
                                updateDecision(.no)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        DecisionButton(title: "Undecided", isSelected: viewModel.form.answer == nil, color: .orange) {
                            updateDecision(.undecided)
                        }
                    }
                    .padding(.vertical)
                    
                } header: {
                    Text("Initial Answer")
                } footer: {
                    Text("You can always change this later")
                }
            }
            .navigationTitle("New Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await viewModel.createDecision()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private func updateDecision(_ newStatus: DecisionStatus) {
        viewModel.form.answer = newStatus.recordValue
    }
}

@MainActor
class CreateDecisionViewModel: ObservableObject {
    @Published var form = CreateDecisionForm(title: "", answer: false)
    @Published var showError = false
    @Published var errorMessage = ""
    @Published private(set) var isCreating = false
    
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
            authService: authService,
            databaseId: AppConfig.AppWrite.shared.databaseID,
            decisionsCollectionId: AppConfig.AppWrite.shared.decisionsCollectionID,
            decisionHistoryCollectionId: "",
            notesCollectionId: ""
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
        } catch {
            showError = true
            errorMessage = "Failed to create decision: \(error.localizedDescription)"
        }
    }
}

// Preview
struct CreateDecisionView_Previews: PreviewProvider {
    static var previews: some View {
        CreateDecisionView()
    }
}

// Helper Views
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
            }
        }
        .disabled(isLoading)
    }
}

struct CreateDecisionForm {
    var title: String
    var answer: Bool?
}
