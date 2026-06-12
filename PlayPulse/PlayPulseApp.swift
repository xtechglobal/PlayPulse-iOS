//
//  PlayPulseApp.swift
//  PlayPulse
//
//  Created by Lakhdeep on 26/02/26.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct PlayPulseApp: App {
    let modelContainer: ModelContainer = {
        let schema = Schema([AppStats.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    private static let testKey = "test_WWexwYhCDBtFaCVAKnbXqQZmpCv"
    private static let prodKey = "appl_BLymTLQwzsZmCetSmAVmGGjrppu"

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Self.testKey)
        #else
        Purchases.configure(withAPIKey: Self.prodKey)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AppRoot()
        }
        .modelContainer(modelContainer)
    }
}

private struct AppRoot: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContentView()
            .environment(SessionViewModel(modelContext: modelContext))
    }
}
