//
//  AuthView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/29/24.
//
import SwiftUI

struct AuthView: View {
    @State private var selectedTab: Tab = .login
    var onSuccessLogin: () -> Void
    var onSignupSuccess: () -> Void

    enum Tab: Identifiable, CaseIterable {
        case login
        case signup

        var id: Self { self }

        var title: String {
            switch self {
            case .login:
                return "Login"

            case .signup:
                return "Sign Up"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    switch selectedTab {
                    case .login:
                        LoginView(onSuccessLogin: onSuccessLogin, onTapSignup: {
                            
                            withAnimation(.spring) {
                                selectedTab = .signup
                            }
                        })
                        .padding()
                        .tabItem {
                            Text("Login")
                        }
                        
                    case .signup:
                        SignupView(onSignupSuccess: onSignupSuccess)
                            .padding()
                            .tabItem {
                                Text("Sign Up")
                            }
                            
                    }
                }
                .navigationTitle(selectedTab.title)
            }
        }
    }
}

#Preview {
    AuthView(onSuccessLogin: {}, onSignupSuccess: {})
}
