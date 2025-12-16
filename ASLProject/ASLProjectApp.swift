//
//  ASLProjectApp.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import SwiftUI

@main
struct ASLProjectApp: App {

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace {
            ImmersiveView()
        }
        .upperLimbVisibility(.hidden)
    }
}
