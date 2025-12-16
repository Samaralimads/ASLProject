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

    
    func currentPose(isRight: Bool) -> HandPose {

        let hand = isRight ? rightHandParts : leftHandParts

        let pose = HandPose(
            fingerExtended: [
                .index: isFingerExtended(
                    tip: .indexFingerTip,
                    knuckle: .indexFingerKnuckle,
                    palm: .wrist,
                    in: hand
                ),
                .middle: isFingerExtended(
                    tip: .middleFingerTip,
                    knuckle: .middleFingerKnuckle,
                    palm: .wrist,
                    in: hand
                ),
                .ring: isFingerExtended(
                    tip: .ringFingerTip,
                    knuckle: .ringFingerKnuckle,
                    palm: .wrist,
                    in: hand
                ),
                .little: isFingerExtended(
                    tip: .littleFingerTip,
                    knuckle: .littleFingerKnuckle,
                    palm: .wrist,
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

    
}

