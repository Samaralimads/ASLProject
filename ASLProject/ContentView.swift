//
//  ContentView.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import SwiftUI

struct ContentView: View {

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        VStack(spacing: 24) {
            Text("Hand Skeleton Demo")
                .font(.title)

            Button("Enter Immersive Space") {
                Task {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                }
            }
        }
        .padding()
    }
}

