//
//  DecisionHistoryView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import SwiftUI

struct DecisionHistoryView: View {
    internal init(decisionID: String) {
        _viewModel = StateObject(
            wrappedValue: DecisionHistoryViewModel(decisionID: decisionID)
        )
    }

    @StateObject private var viewModel: DecisionHistoryViewModel

    var body: some View {
        VStack {
            if let historyList = viewModel.historyList {
                if historyList.sortedByDate.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(historyList.documents, id: \.id) { history in
                                DecisionHistoryItemView(history: history)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                loadingView
            }
        }
        .task {
            await viewModel.getHistoryList()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No History Yet")
                .font(.headline)

            Text("Changes to this decision will appear here")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading history...")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



#Preview {
    DecisionHistoryView(decisionID: "")
}
