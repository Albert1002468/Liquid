//
//  LiquidApp.swift
//  Shared
//
//  Created by Alberto Dominguez on 2/12/22.
//

import SwiftUI

@main
struct LiquidApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
