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
    
    @State private var handTracker = HandTracker()
    @State private var jointEntitiesRight: [HandSkeleton.JointName: ModelEntity] = [:]
    @State private var jointEntitiesLeft: [HandSkeleton.JointName: ModelEntity] = [:]
    
    var body: some View {
        RealityView { content in
            // Create spheres for each joint and store them
            for joint in HandSkeleton.JointName.allCases {
                
                // Right hand
                let rightSphere = ModelEntity(
                    mesh: .generateSphere(radius: 0.01),
                    materials: [SimpleMaterial(color: .red, isMetallic: false)]
                )
                jointEntitiesRight[joint] = rightSphere
                handTracker.rightHandParts[joint]?.addChild(rightSphere)
                if let right = handTracker.rightHandParts[joint] {
                    content.add(right)
                }
                
                // Left hand
                let leftSphere = ModelEntity(
                    mesh: .generateSphere(radius: 0.01),
                    materials: [SimpleMaterial(color: .red, isMetallic: false)]
                )
                jointEntitiesLeft[joint] = leftSphere
                handTracker.leftHandParts[joint]?.addChild(leftSphere)
                if let left = handTracker.leftHandParts[joint] {
                    content.add(left)
                }
            }
        }
        .task {
            await handTracker.startHandTracking()
        }
        
        .task {
            while !Task.isCancelled {
                let pose = handTracker.currentPose(isRight: true)
                print(pose.fingerExtended)
                
                // Update the recognized letters
                handTracker.updateRecognizedLetters()
                
                // Update sphere colors based on recognized letters
                for joint in HandSkeleton.JointName.allCases {
                    // Right hand
                    if let entity = jointEntitiesRight[joint] {
                        let isRecognized = handTracker.recognizedRightLetter != nil
                        entity.model?.materials = [
                            SimpleMaterial(color: isRecognized ? .green : .red, isMetallic: false)
                        ]
                    }
                    
                    // Left hand
                    if let entity = jointEntitiesLeft[joint] {
                        let isRecognized = handTracker.recognizedLeftLetter != nil
                        entity.model?.materials = [
                            SimpleMaterial(color: isRecognized ? .green : .red, isMetallic: false)
                        ]
                    }
                }
                
                // Debug print
                if let letter = handTracker.recognizedRightLetter {
                    print("✅ Recognized letter: \(letter.rawValue)")
                }
                
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
            }
        }
    }
}
