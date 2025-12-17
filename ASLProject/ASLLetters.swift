//
//  ASLLetters.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import Foundation
import SwiftUI

enum ASLLetter: String, CaseIterable {
    case A, B, L
}

struct ASLPose {
    let fingerExtended: [Finger: Bool]
    let thumbTouchingIndex: Bool
}

let aslPoses: [ASLLetter: ASLPose] = [
    .A: ASLPose(
        fingerExtended: [
            .thumb: true,
            .index: false,
            .middle: false,
            .ring: false,
            .little: false
        ],
        thumbTouchingIndex: false
    ),
    .B: ASLPose(
        fingerExtended: [
            .thumb: false,
            .index: true,
            .middle: true,
            .ring: true,
            .little: true
        ],
        thumbTouchingIndex: false
    ),
    .L: ASLPose(
        fingerExtended: [
            .thumb: true,
            .index: true,
            .middle: false,
            .ring: false,
            .little: false
        ],
        thumbTouchingIndex: false
    )
    
]

