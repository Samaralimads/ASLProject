//
//  ImmersiveView.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {

    var handTracker = HandTracker()

    var body: some View {
        RealityView { content in

            let material = UnlitMaterial(color: .red)

            let fingerObject = ModelEntity(
                mesh: .generateSphere(radius: 0.01),
                materials: [material]
            )

            for joint in HandSkeleton.JointName.allCases {

                handTracker.rightHandParts[joint]?
                    .addChild(fingerObject.clone(recursive: true))

                handTracker.leftHandParts[joint]?
                    .addChild(fingerObject.clone(recursive: true))

                if let right = handTracker.rightHandParts[joint] {
                    content.add(right)
                }

                if let left = handTracker.leftHandParts[joint] {
                    content.add(left)
                }
            }
        }
        .task {
            await handTracker.startHandTracking()
        }
    }
}
