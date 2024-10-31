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
    var onTapSignup: () -> Void

    var body: some View {
        Form {
            GroupBox {
                VStack {
                    Text("Email")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField(
                        "Type your email here",
                        text: $email.animation(.spring)
                    )
                    .textFieldStyle(.roundedBorder)
                }
                
                
                Divider()
                    .padding(.vertical)
                
                VStack {
                    Text("Password")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SecureField("Password", text: $password, prompt: Text("Enter Password"))
                        .textFieldStyle(.roundedBorder)
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
            .backgroundStyle(Color(.tertiarySystemBackground))
            
            Button {
                onTapSignup()
                
            } label: {
                Text("Sign Up instead")
                    .font(.caption2)
                    .fontWeight(.regular)
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .cornerRadius(10)
            }
            .padding(.vertical)
            .buttonStyle(.borderless)
            .tint(.blue)
            
        }
        .formStyle(.columns)
        
    }

    private var disableLoginButton: Bool {
        email.isEmpty || password.isEmpty
    }
}

#Preview {
    NavigationStack {
        LoginView(onSuccessLogin: {}, onTapSignup: { })
    }
}

