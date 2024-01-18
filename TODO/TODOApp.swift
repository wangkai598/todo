//
//  TODOApp.swift
//  TODO
//
//  Created by keven on 2024/1/18.
//

import SwiftUI

@main
struct TODOApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
