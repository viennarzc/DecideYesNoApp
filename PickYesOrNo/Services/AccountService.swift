//
//  AccountService.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/18/24.
//
import Foundation
import Combine
import Appwrite

protocol AccountServiceProtocol {
    func login(email: String, password: String) async throws -> User?
}

enum AccountServiceError: LocalizedError {
    case loginFailed
}

// AccountService
class AccountService {
    private let userDefaultsManager: UserDefaultsManager
    private var currentSession: Session?
    
    init(userDefaultsManager: UserDefaultsManager) {
        self.userDefaultsManager = userDefaultsManager
    }
    
    func saveUser(_ user: User) async throws {
        userDefaultsManager.saveUserId(user.id)
        userDefaultsManager.saveUserEmail(user.email)
    }
    
    func saveSession(_ session: Session) async throws {
        currentSession = session
        // Optionally save session ID to UserDefaults if needed
    }
    
    func clearSession() {
        currentSession = nil
        userDefaultsManager.clearUserData()
    }
    
    func getCurrentUserId() -> String? {
        return userDefaultsManager.getUserId()
    }
    
    func getCurrentUserEmail() -> String? {
        return userDefaultsManager.getUserEmail()
    }
    
    func getCurrentSession() -> Session? {
        return currentSession
    }
}
