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

struct User: Codable {
    let id: String
    let email: String
    let name: String
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



// UserDefaultsManager
class UserDefaultsManager {
    private let defaults = UserDefaults.standard
    
    func saveUserId(_ userId: String) {
        defaults.set(userId, forKey: "userId")
    }
    
    func saveUserEmail(_ email: String) {
        defaults.set(email, forKey: "userEmail")
    }
    
    func getUserId() -> String? {
        return defaults.string(forKey: "userId")
    }
    
    func getUserEmail() -> String? {
        return defaults.string(forKey: "userEmail")
    }
    
    func clearUserData() {
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "userEmail")
    }
}
