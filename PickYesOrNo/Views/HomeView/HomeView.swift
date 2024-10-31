//
//  HomeView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/29/24.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Overview
                    statsOverview

                    // Recent Decisions
                    recentDecisions

                    Section {
                        GroupBox {
                            DecisionTimeAnalytics(decisions: viewModel.recentDecisions)
                        }

                    } header: {
                        Text("Decision Time Patterns")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .navigationTitle("Decisions")
            .onAppear {
                viewModel.fetchData()
            }
        }
        .task {
            await viewModel.updateLocalUser()
        }
    }

    // MARK: - Stats Overview

    private var statsOverview: some View {
        VStack(spacing: 16) {
            HStack {
                StatCard(
                    title: "Total Decisions",
                    value: "\(viewModel.totalDecisions)",
                    systemName: "chart.bar.fill"
                )
                StatCard(
                    title: "Yes Decisions",
                    value: "\(viewModel.yesDecisions)",
                    systemName: "checkmark.circle.fill"
                )
            }

            HStack {
                StatCard(
                    title: "No Decisions",
                    value: "\(viewModel.noDecisions)",
                    systemName: "xmark.circle.fill"
                )
                StatCard(
                    title: "This Month",
                    value: "\(viewModel.thisMonthDecisions)",
                    systemName: "calendar.badge.clock"
                )
            }

            StatCard(
                title: "Undecided",
                value: "\(viewModel.undecidedDecisions)", systemName: "questionmark.circle.fill"
            )
        }
    }

    // MARK: - Recent Decisions

    private var recentDecisions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Decisions")
                .font(.headline)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if viewModel.recentDecisions.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.recentDecisions) { decision in
                    DecisionRow(decision: decision)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("No decisions yet")
                .font(.headline)
                .foregroundColor(.gray)

            Text("Start making decisions by tapping the + button")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
