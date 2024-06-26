//
//  IOS202map_22App.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/05/10.
//

import SwiftUI

@main
struct IOS202map_22App: App {
    @StateObject var manager = LocationManager()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(manager)
        }
    }
}
