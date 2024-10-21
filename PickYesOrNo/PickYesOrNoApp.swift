//
//  PickYesOrNoApp.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/17/24.
//

import SwiftUI

@main
struct PickYesOrNoApp: App {
    
    init() {
        AppConfig.AppWrite.configure(
            endpoint: "https://cloud.appwrite.io/v1",
            allowSelfSigned: false
        )
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
