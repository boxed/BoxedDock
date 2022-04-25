//
//  BoxedDockApp.swift
//  BoxedDock
//
//  Created by Anders Hovmöller on 2022-04-20.
//

import SwiftUI
import AppKit

@main
struct BoxedDockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
            .ignoresSafeArea()
            .frame(minWidth: 640, minHeight: 50)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

