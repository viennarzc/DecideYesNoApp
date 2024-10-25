//
//  UserDefaultsManager.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/25/24.
//
import Foundation

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
