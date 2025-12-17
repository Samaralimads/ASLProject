# ASLProject

An immersive **American Sign Language (ASL) hand pose recognition** prototype built with **SwiftUI, RealityKit, and ARKit Hand Tracking**.  
The project visualizes hand joints in 3D and recognizes basic ASL letters when a pose is held steadily.

---

## Overview

ASLProject uses Apple’s **VisionOS hand tracking** to:

- Track left and right hands in real time  
- Visualize hand joints as 3D spheres  
- Detect finger extension and thumb contact  
- Recognize ASL letters based on hand pose  
- Provide visual feedback through color changes  

---

##  How It Works

### Hand Tracking
- Uses `ARKitSession` with `HandTrackingProvider`
- Updates all `HandSkeleton.JointName` joints every frame
- Supports both left and right hands

### Pose Detection
For each hand:
- Finger extension is calculated using distance from fingertip to wrist
- Thumb extension is handled separately
- Finger contact (e.g. thumb touching index) is detected via joint distance
- A `HandPose` structure represents the current state

### ASL Recognition
- Each ASL letter is defined as a target pose
- The current hand pose is compared to known ASL poses
- A letter is recognized only if the pose is held consistently for a short duration (temporal filtering)

### Visual Feedback
- 🔴 Red joints: no valid ASL pose detected
- 🟢 Green joints: ASL letter successfully recognized

---

## Supported ASL Letters

Currently implemented:

- **A**
- **B**
- **D**
- **E**
- **I**
- **L**
- **U**
- **W**
- **Y**

Each letter is defined by:
- Which fingers are extended
- Whether the thumb is touching the index finger
