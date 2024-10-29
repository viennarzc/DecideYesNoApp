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
            VStack {
                Spacer()
                
                Picker(selection: $selectedTab) {
                    ForEach(Tab.allCases) { tab in
                        Text(tab.title)
                    }
                    
                } label: {
                    Text("Tab Picker")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                switch selectedTab {
                case .login:
                    LoginView(onSuccessLogin: onSuccessLogin)
                        .tabItem {
                            Text("Login")
                        }
                    
                case .signup:
                    SignupView(onSignupSuccess: onSignupSuccess)
                        .tabItem {
                            Text("Sign Up")
                        }
                    
                }
                
            }
        }
//        .ignoresSafeArea(.all)
    }
}

#Preview {
    AuthView(onSuccessLogin: {}, onSignupSuccess: {})
}
