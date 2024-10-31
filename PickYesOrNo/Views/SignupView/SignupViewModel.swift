//
//  SignupViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Foundation

class SignupViewModel: ObservableObject {
    private var authService: AuthService

    init() {
        authService = AuthService(
            client: AppConfig.AppWrite.shared.client,
            accountService: AccountService(
                userDefaultsManager: UserDefaultsManager()
            )
        )
    }

    func createAccount(email: String, password: String) async -> Bool {
        do {
            let result = try await authService.onRegister(email, password)
            debugPrint(result)
            return true
        } catch let error {
            debugPrint(error.localizedDescription)
            return false
        }
    }
}
