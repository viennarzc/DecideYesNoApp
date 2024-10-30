//
//  SignupView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/29/24.
//

import SwiftUI

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @StateObject private var viewModel: SignupViewModel = SignupViewModel()
    
    var onSignupSuccess: () -> Void

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
                    let success = await viewModel.createAccount(
                        email: email,
                        password: password
                    )
                    
                    if success {
                        onSignupSuccess()
                    }
                    
                }
                
            } label: {
                Text("Create Account")
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
    SignupView(onSignupSuccess: { })
}



