//
//  CurrencyTrackerAppApp.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//

import SwiftUI

@main
struct CurrencyTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(HomeViewModel())
        }
    }
}
