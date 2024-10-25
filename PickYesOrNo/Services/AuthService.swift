//
//  AuthService.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/20/24.
//
import Appwrite
import JSONCodable

// AuthService
class AuthService {
    private let client: Client
    private let account: Account
    private let accountService: AccountService
    
    init(client: Client, accountService: AccountService) {
        self.client = client
        self.account = Account(client)
        self.accountService = accountService
    }
    
    func signUp(email: String) async throws -> User {
        let userId = ID.unique()
        let token = try await account.createEmailToken(userId: userId, email: email)
        let user = User(id: userId, email: email, name: "")
        try await accountService.saveUser(user)
        return user
    }
    
    func login(email: String, password: String) async throws -> User {
        let session = try await account.createEmailPasswordSession(email: email, password: password)
        let user = try await account.get()
        try await accountService.saveSession(session)
        return User(id: user.id, email: user.email, name: user.name)
    }
    
    func logout() async throws {
        let result = try await account.deleteSession(sessionId: "current")
        accountService.clearSession()
    }
    
    func createEmailTokenOTP(email: String) async throws -> Token {
        guard let userId = accountService.getCurrentUserId() else { throw AuthError.userIdNotFound }
        return try await account.createEmailToken(userId: userId, email: email)
    }
    
    func createSession(secret: String) async throws -> User {
        guard let userId = accountService.getCurrentUserId() else {
            throw AuthError.userIdNotFound
        }
        
        let session = try await account.createSession(userId: userId, secret: secret)
        try await accountService.saveSession(session)
        debugPrint("Session \(session)")
        return try await getCurrentUser()
    }
    
    func createEmailVerification() async throws {
        //TODO:
    }
    
    func createEmailVerificationConfirmation(secret: String) async throws {
        //TODO:
    }
    
    func getCurrentUser() async throws -> User {
        let appwriteUser = try await account.get()
        return User(id: appwriteUser.id, email: appwriteUser.email, name: appwriteUser.name)
    }
    
    func getClient() -> Client {
        client
    }
    
    func getSession() async throws {
        let account = Account(client)

        let session = try await account.getSession(
            sessionId: "current"
        )
        
        debugPrint(session.current)
    }
    
    public func onRegister(
           _ email: String,
           _ password: String
    ) async throws -> Appwrite.User<[String: AnyCodable]> {
           try await account.create(
               userId: ID.unique(),
               email: email,
               password: password
           )
       }
}

enum AuthError: Error {
    case userIdNotFound
}
