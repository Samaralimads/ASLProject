//
//  ASLLetters.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import Foundation
import SwiftUI

enum ASLLetter: String, CaseIterable {
    case A, B, D, E, F, I, L, U, W, Y
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
    .D: ASLPose(
        fingerExtended: [
            .thumb: false,
            .index: true,
            .middle: false,
            .ring: false,
            .little: false
        ],
        thumbTouchingIndex: false
    ),
    .E: ASLPose(
        fingerExtended: [
            .thumb: false,
            .index: false,
            .middle: false,
            .ring: false,
            .little: false
        ],
        thumbTouchingIndex: false
    ),
    .F: ASLPose(
        fingerExtended: [
            .thumb: false,
            .index: false,
            .middle: false,
            .ring: false,
            .little: false
        ],
        thumbTouchingIndex: true
    ),
    .I: ASLPose(
        fingerExtended: [
            .thumb: false,
            .index: false,
            .middle: false,
            .ring: false,
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
    ),
    .U: ASLPose(
        fingerExtended: [
            .thumb: false,
            .index: true,
            .middle: true,
            .ring: false,
            .little: false
        ],
        thumbTouchingIndex: false
    ),
    .W: ASLPose(
        fingerExtended: [
            .thumb: false,
            .index: true,
            .middle: true,
            .ring: true,
            .little: false
        ],
        thumbTouchingIndex: false
    ),
    .Y: ASLPose(
        fingerExtended: [
            .thumb: true,
            .index: false,
            .middle: false,
            .ring: false,
            .little: true
        ],
        thumbTouchingIndex: false
    )
]
