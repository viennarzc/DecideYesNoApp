//
//  AppConfig.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/20/24.
//
import Appwrite
import Foundation

struct AppConfig {
    // MARK: - General App Configuration
    static let maxRetryAttempts = 3
    
    struct Keys {
        static var apiKey: String {
            AppConfig.getEnvironmentVariable("API_KEY")
        }
        
        static var secretKey: String {
            AppConfig.getEnvironmentVariable("SECRET_KEY")
        }
    }
    
    // MARK: - AppWrite Configuration
    struct AppWrite {
        static var shared: AppWriteConfig!
        
        struct AppWriteConfig {
            let client: Client
            let projectID: String
            let databaseID: String
            let decisionsCollectionID: String
            let decisionsHistoryCollectionID: String
            
            init(endpoint: String, allowSelfSigned: Bool) {
                self.projectID = AppConfig.getEnvironmentVariable("APPWRITE_PROJECT_ID")
                self.databaseID = AppConfig.getEnvironmentVariable("APPWRITE_DATABASE_ID")
                self.decisionsCollectionID = AppConfig.getEnvironmentVariable("APPWRITE_DECISIONS_COLLECTION_ID")
                
                self.decisionsHistoryCollectionID = AppConfig
                    .getEnvironmentVariable("APPWRITE_DECISIONS_HISTORY_COLLECTION_ID")

                client = Client()
                    .setEndpoint(endpoint)
                    .setProject(projectID)
                    .setSelfSigned(allowSelfSigned)
     
            }
            
            func getDatabase() -> Databases {
                return Databases(client)
            }
            
            // Add other Appwrite services as needed
        }
        
        static func configure(endpoint: String, allowSelfSigned: Bool) {
            shared = AppWriteConfig(endpoint: endpoint, allowSelfSigned: allowSelfSigned)
        }
    }
    
    // MARK: - Helper Methods
    static func getEnvironmentVariable(_ key: String) -> String {
        guard let value = ProcessInfo.processInfo.environment[key] else {
            fatalError("\(key) not set in environment variables")
        }
        return value
    }
}
