//
//  HandPose.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import Foundation

struct HandPose {
    var fingerExtended: [Finger: Bool]
    var thumbTouchingIndex: Bool
}

func matches(_ a: HandPose, _ b: HandPose) -> Bool {
    a.fingerExtended == b.fingerExtended &&
    a.thumbTouchingIndex == b.thumbTouchingIndex
}
