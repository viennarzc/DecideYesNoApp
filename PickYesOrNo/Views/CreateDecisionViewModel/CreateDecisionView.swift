//
//  CreateDecisionView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//
import SwiftUI
import Combine

struct CreateDecisionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateDecisionViewModel()
    
    @State private var cancellable: AnyCancellable?

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

                            DecisionButton(title: "No", isSelected: viewModel.form.answer == false, color: .red) {
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
            .onAppear {
                cancellable = viewModel.onSuccessCreateDecision
                    .sink { completion in
                        switch completion {
                        case .finished:
                            debugPrint("Finished")
                        case .failure(let error):
                            debugPrint("Received error: \(error)")
                        }
                    } receiveValue: { _ in
                        //assumes success
                        dismiss()
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

// Preview
struct CreateDecisionView_Previews: PreviewProvider {
    static var previews: some View {
        CreateDecisionView()
    }
}
