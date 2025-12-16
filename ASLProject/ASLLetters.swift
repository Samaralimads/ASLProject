//
//  ASLLetters.swift
//  ASLProject
//
//  Created by Samara Lima da Silva on 15/12/2025.
//

import Foundation

let ASL_A = HandPose(
    fingerExtended: [
        .index: false,
        .middle: false,
        .ring: false,
        .little: false
    ],
    thumbTouchingIndex: false
)

let ASL_B = HandPose(
    fingerExtended: [
        .index: true,
        .middle: true,
        .ring: true,
        .little: true
    ],
    thumbTouchingIndex: false
)

let ASL_L = HandPose(
    fingerExtended: [
        .index: true,
        .middle: false,
        .ring: false,
        .little: false
    ],
    thumbTouchingIndex: false
)
