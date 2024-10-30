//
//  ContentView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/17/24.
//

import SwiftUI

class ViewModel: ObservableObject {
    private var authService: AuthService
    private var decService: DecisionService

    init() {
        authService = AuthService(
            client: AppConfig.AppWrite.shared.client,
            accountService: AccountService(
                userDefaultsManager: UserDefaultsManager()
            )
        )

        decService = DecisionService(
            authService: authService,
            databaseId: AppConfig.AppWrite.shared.databaseID,
            decisionsCollectionId: AppConfig.AppWrite.shared.decisionsCollectionID
        )
    }

    func login(email: String, password: String) async {
        guard let user = try? await authService.login(email: "vnrzc.developer@gmail.com", password: "pAssword123") else { return }

        debugPrint("User \(user.email)")
    }

    func login2(email: String, password: String) async {
        guard let user = try? await authService.login(email: email, password: password) else { return }

        debugPrint("User \(user.email)")
    }

    func createSession(code: String) async {
        guard let session = try? await authService.createSession(
            secret: code)

        else { return }

        debugPrint("User session", session)
    }

    func getDecisions() async {
        try? await decService.getDecisionsForCurrentUser()
    }

    func getDecision(id: String) async {
        try? await decService.getDecision(id: id)
    }

    func createDecision() async {
        do {
            try await decService.createDecision(title: "Random title", answer: Bool.random())

        } catch let error {
            debugPrint("Error create decision \(error.localizedDescription)")
        }
    }

    func getSession() async {
        try? await authService.getSession()
    }

    func logout() async {
        do {
            try await authService.logout()
        } catch let error {
            debugPrint("Error when logout \(error.localizedDescription)")
        }
    }

    func createAccount(email: String, password: String) async {
        do {
            let result = try await authService.onRegister(email, password)
            debugPrint(result)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}

struct ContentView: View {
    @StateObject private var vm = ViewModel()
    @State private var showingOTPView: Bool = false
    @State private var code: String = ""

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }

            DecisionListMainView().tabItem {
                Label("Decisions", systemImage: "list.triangle")
            }
            
            SettingsMainView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }

}

#Preview {
    ContentView()
}
