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
    
    @State private var isCompleted = false
    
    // Track which letter we're learning
    @State private var currentLetterIndex = 0
    let lettersToLearn: [ASLLetter] = [.A, .B, .D, .E, .I, .L, .U, .W, .Y]
    
    var currentTargetLetter: ASLLetter {
        lettersToLearn[currentLetterIndex]
    }
    
    var body: some View {
        RealityView { content, attachments in
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
            
            // Add the instruction UI attachment
            if let instructionAttachment = attachments.entity(for: "instruction") {
                instructionAttachment.position = [0, 1.5, -1.5] // Position in front of user
                content.add(instructionAttachment)
            }
            
        } attachments: {
            Attachment(id: "instruction") {
                VStack(spacing: 20) {
                    if !isCompleted{
                        Text("Make the sign for:")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        // Display the image from assets
                        Image(currentTargetLetter.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(20)
                        
                        Text("Letter: \(currentTargetLetter.rawValue)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Progress: \(currentLetterIndex + 1)/\(lettersToLearn.count)")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("🎉 Congratulations!")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("You've completed all letters!")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(40)
                .background(Color.black.opacity(0.7))
                .cornerRadius(30)
            }
        }
        .task {
            await handTracker.startHandTracking()
        }
        
        .task {
            while !Task.isCancelled {
                // Update the recognized letters
                handTracker.updateRecognizedLetters()
                
                // Check if user made the correct letter
                let recognizedRight = handTracker.recognizedRightLetter
                let recognizedLeft = handTracker.recognizedLeftLetter
                
                if (recognizedRight == currentTargetLetter || recognizedLeft == currentTargetLetter) {
                    print("✅ Correct! Recognized letter: \(currentTargetLetter.rawValue)")
                    
                    // Move to next letter after a short delay
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                    
                    await MainActor.run {
                        if currentLetterIndex < lettersToLearn.count - 1 {
                            currentLetterIndex += 1
                            print("📝 Next letter: \(currentTargetLetter.rawValue)")
                        } else {
                            isCompleted = true
                            print("🎉 All letters completed!")
                        }
                    }
                }
                
                // Update sphere colors
                await MainActor.run {
                    for joint in HandSkeleton.JointName.allCases {
                        // Right hand
                        if let entity = jointEntitiesRight[joint] {
                            let isCorrect = recognizedRight == currentTargetLetter
                            entity.model?.materials = [
                                SimpleMaterial(color: isCorrect ? .green : .red, isMetallic: false)
                            ]
                        }
                        
                        // Left hand
                        if let entity = jointEntitiesLeft[joint] {
                            let isCorrect = recognizedLeft == currentTargetLetter
                            entity.model?.materials = [
                                SimpleMaterial(color: isCorrect ? .green : .red, isMetallic: false)
                            ]
                        }
                    }
                }
                
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
            }
        }
    }
}
