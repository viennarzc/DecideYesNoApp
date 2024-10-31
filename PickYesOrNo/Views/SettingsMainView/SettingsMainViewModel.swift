//
//  SettingsMainViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Foundation

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
