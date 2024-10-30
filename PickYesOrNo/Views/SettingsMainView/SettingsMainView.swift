//
//  SettingsMainView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/29/24.
//

import SwiftUI

struct SettingsMainView: View {
    @StateObject private var viewModel: SettingsMainViewModel = SettingsMainViewModel()

    @State private var hasActiveSession: Bool = false
    @State private var isPresentingLoginView: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if hasActiveSession, let user = viewModel.user {
                        Text("Name: \(user.name)")
                        Text("Email: \(user.email)")
                        
                        Button {
                            Task {
                                await viewModel.logout()
                                await viewModel.getCurrentUser()
                            }
                        } label: {
                            Text("Logout")
                        }
                    } else {
                        Button {
                            isPresentingLoginView = true
                        } label: {
                            Text("Login")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onFirstAppear({
                Task {
                    hasActiveSession = await viewModel.getSession() ?? false
                    await viewModel.getCurrentUser()
                    
                }
            })
            .sheet(isPresented: $isPresentingLoginView, content: {
                LoginView(onSuccessLogin: {
                    isPresentingLoginView = false
                    
                    Task {
                        await viewModel.getCurrentUser()
                        hasActiveSession = await viewModel.getSession() ?? false
                    }
                })
            })
        }
    }
}

#Preview {
    SettingsMainView()
}

