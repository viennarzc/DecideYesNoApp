//
//  ContentView.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/17/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }

            DecisionListMainView().tabItem {
                Label("Decisions", systemImage: "list.triangle")
            }
            
            SettingsMainView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }

}

#Preview {
    ContentView()
}
