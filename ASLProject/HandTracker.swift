//
//  HandTracker.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import ARKit
import RealityKit

@MainActor
@Observable
class HandTracker {

    private let session = ARKitSession()
    private let handData = HandTrackingProvider()

    var leftHandParts: [HandSkeleton.JointName: Entity] = [:]
    var rightHandParts: [HandSkeleton.JointName: Entity] = [:]
    
    // published variables that the view can observe
    var recognizedRightLetter: ASLLetter?
    var recognizedLeftLetter: ASLLetter?
    
    // Hold timer properties
    private var rightPoseStartTime: Date?
    private var leftPoseStartTime: Date?
    private var lastRightLetter: ASLLetter?
    private var lastLeftLetter: ASLLetter?
    private let requiredHoldDuration: TimeInterval = 1.0

    func startHandTracking() async {
        print("Starting Hand Tracking")

        // Initialize all joints with empty entities
        for joint in HandSkeleton.JointName.allCases {
            rightHandParts[joint] = Entity()
            leftHandParts[joint] = Entity()
        }

        try! await session.run([handData])

        guard HandTrackingProvider.isSupported else { return }

        for await update in handData.anchorUpdates {
            switch update.event {
            case .added, .updated:
                updateHand(update.anchor)
            case .removed:
                continue
            }
        }
    }

    private func updateHand(_ anchor: HandAnchor) {
        for joint in HandSkeleton.JointName.allCases {

            guard let jointTransform =
                    anchor.handSkeleton?
                        .joint(joint)
                        .anchorFromJointTransform
            else { continue }

            let worldTransform =
                anchor.originFromAnchorTransform * jointTransform

            if anchor.chirality == .right {
                rightHandParts[joint]?
                    .setTransformMatrix(worldTransform, relativeTo: nil)
            } else {
                leftHandParts[joint]?
                    .setTransformMatrix(worldTransform, relativeTo: nil)
            }
        }
    }
    
    func isFingerExtended(
        tip: HandSkeleton.JointName,
        knuckle: HandSkeleton.JointName,
        palm: HandSkeleton.JointName,
        in hand: [HandSkeleton.JointName: Entity]
    ) -> Bool {

        guard
            let tipPos = hand[tip]?.position(relativeTo: nil),
            let knucklePos = hand[knuckle]?.position(relativeTo: nil),
            let palmPos = hand[palm]?.position(relativeTo: nil)
        else { return false }

        let tipDistance = simd_distance(tipPos, palmPos)
        let knuckleDistance = simd_distance(knucklePos, palmPos)

        return tipDistance > knuckleDistance + 0.01
    }
    
    func isThumbExtended(
        in hand: [HandSkeleton.JointName: Entity]
    ) -> Bool {

        guard
            let tip = hand[.thumbTip]?.position(relativeTo: nil),
            let knuckle = hand[.thumbKnuckle]?.position(relativeTo: nil),
            let wrist = hand[.forearmWrist]?.position(relativeTo: nil)
        else { return false }

        // Direction vectors
        let knuckleDir = normalize(knuckle - wrist)
        let tipDir = normalize(tip - wrist)

        // Dot product tells us if they point the same way
        let alignment = dot(knuckleDir, tipDir)

        // Threshold tuned for thumb anatomy
        return alignment > 0.85
    }

    
    func currentPose(isRight: Bool) -> HandPose {

        let hand = isRight ? rightHandParts : leftHandParts

        let pose = HandPose(
            fingerExtended: [
                .thumb: isThumbExtended(in: hand),
                .index: isFingerExtended(
                    tip: .indexFingerTip,
                    knuckle: .indexFingerKnuckle,
                    palm: .forearmWrist,
                    in: hand
                ),
                .middle: isFingerExtended(
                    tip: .middleFingerTip,
                    knuckle: .middleFingerKnuckle,
                    palm: .forearmWrist,
                    in: hand
                ),
                .ring: isFingerExtended(
                    tip: .ringFingerTip,
                    knuckle: .ringFingerKnuckle,
                    palm: .forearmWrist,
                    in: hand
                ),
                .little: isFingerExtended(
                    tip: .littleFingerTip,
                    knuckle: .littleFingerKnuckle,
                    palm: .forearmWrist,
                    in: hand
                )
            ],
            thumbTouchingIndex: areFingersTouching(
                .thumbTip,
                .indexFingerTip,
                in: hand
            )
        )

        return pose
    }

    
    func areFingersTouching(
        _ a: HandSkeleton.JointName,
        _ b: HandSkeleton.JointName,
        in hand: [HandSkeleton.JointName: Entity]
    ) -> Bool {
        guard
            let p1 = hand[a]?.position(relativeTo: nil),
            let p2 = hand[b]?.position(relativeTo: nil)
        else { return false }

        return simd_distance(p1, p2) < 0.025
    }
    
    func recognizedLetter(isRightHand: Bool) -> ASLLetter? {
        let current = currentPose(isRight: isRightHand)
        
        for (letter, pose) in aslPoses {
            let handPose = HandPose(fingerExtended: pose.fingerExtended, thumbTouchingIndex: pose.thumbTouchingIndex)
            if matches(current, handPose) {
                return letter
            }
        }
        
        return nil
    }
    
    // New function with hold timer
    func recognizedLetterWithHold(isRightHand: Bool) -> ASLLetter? {
        let current = currentPose(isRight: isRightHand)
        var matchedLetter: ASLLetter?
        
        for (letter, pose) in aslPoses {
            let handPose = HandPose(fingerExtended: pose.fingerExtended, thumbTouchingIndex: pose.thumbTouchingIndex)
            if matches(current, handPose) {
                matchedLetter = letter
                break
            }
        }
        
        if isRightHand {
            if matchedLetter == lastRightLetter {
                // Same pose as before
                if let startTime = rightPoseStartTime {
                    let elapsed = Date().timeIntervalSince(startTime)
                    if elapsed >= requiredHoldDuration {
                        return matchedLetter
                    }
                }
            } else {
                // New pose or no match
                lastRightLetter = matchedLetter
                rightPoseStartTime = matchedLetter != nil ? Date() : nil
            }
        } else {
            if matchedLetter == lastLeftLetter {
                if let startTime = leftPoseStartTime {
                    let elapsed = Date().timeIntervalSince(startTime)
                    if elapsed >= requiredHoldDuration {
                        return matchedLetter
                    }
                }
            } else {
                lastLeftLetter = matchedLetter
                leftPoseStartTime = matchedLetter != nil ? Date() : nil
            }
        }
        
        return nil
    }
    
    func updateRecognizedLetters() {
        recognizedRightLetter = recognizedLetterWithHold(isRightHand: true)
        recognizedLeftLetter = recognizedLetterWithHold(isRightHand: false)
    }
    
}
