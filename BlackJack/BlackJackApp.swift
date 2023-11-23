//
//  BlackJackApp.swift
//  BlackJack
//
//  Created by Max Siebengartner on 23/11/2023.
//

import SwiftUI

@main
struct BlackJackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
