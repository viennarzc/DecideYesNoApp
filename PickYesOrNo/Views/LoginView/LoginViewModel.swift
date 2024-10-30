//
//  LoginViewModel.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import Foundation

class LoginViewModel: ObservableObject {
    private var authService: AuthService

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
}
