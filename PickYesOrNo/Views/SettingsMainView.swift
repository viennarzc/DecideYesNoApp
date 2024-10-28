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
            .task {
                hasActiveSession = await viewModel.getSession() ?? false
                await viewModel.getCurrentUser()
            }
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

class SettingsMainViewModel: ObservableObject {
    private var authService: AuthService

    @Published private(set) var user: User? = nil

    init() {
        authService = AuthService(
            client: AppConfig.AppWrite.shared.client,
            accountService: AccountService(
                userDefaultsManager: UserDefaultsManager()
            )
        )
    }

    func login(email: String, password: String) async -> User? {
        do {
            let user = try await authService.login(email: email, password: password)
            debugPrint("User \(user.email)")
            return user

        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }

    @MainActor
    func getSession() async -> Bool? {
        let session = try? await authService.getSession()
        return session?.current ?? false
    }

    @MainActor
    func getCurrentUser() async {
        let user = try? await authService.getCurrentUser()

        self.user = user
    }
    
    func logout() async {
        do {
            try await authService.logout()
        } catch let error {
            debugPrint("Error when logout \(error.localizedDescription)")
        }
    }
}
