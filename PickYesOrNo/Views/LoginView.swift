//
//  LoginView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @StateObject private var viewModel: LoginViewModel = LoginViewModel()
    
    var onSuccessLogin: () -> Void

    var body: some View {
        Form {
            VStack {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField(
                    "Type your email here",
                    text: $email.animation(.spring)
                )
            }

            VStack {
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SecureField("Password", text: $password, prompt: Text("Enter Password"))
            }

            Button {
                Task {
                    let user = await viewModel.login(email: email, password: password)
                    
                    if user != nil {
                        onSuccessLogin()
                    }
                    
                }
                
            } label: {
                Text("Login")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .cornerRadius(10)
            }
            .padding(.vertical)
            .buttonStyle(BorderedProminentButtonStyle())
            .disabled(disableLoginButton)
        }
        .safeAreaPadding(.top, 64)
        .navigationTitle("Login")
    }

    private var disableLoginButton: Bool {
        email.isEmpty || password.isEmpty
    }
}

#Preview {
    NavigationStack {
        LoginView(onSuccessLogin: {})
    }
}

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
