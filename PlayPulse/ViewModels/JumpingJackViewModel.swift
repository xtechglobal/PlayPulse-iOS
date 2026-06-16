//
//  JumpingJackViewModel.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI
import AVFoundation

@Observable
@MainActor
final class JumpingJackViewModel {
    var repCount: Int = 0
    var isBodyDetected: Bool = false
    var requiredReps: Int = 10
    var onComplete: (() -> Void)?

    private let cameraService = CameraService()
    private let detector = JumpingJackDetector()
    private var completionFired = false

    var captureSession: AVCaptureSession {
        cameraService.captureSession
    }

    func startDetection() {
        completionFired = false
        repCount = 0
        isBodyDetected = false
        detector.reset()
        detector.onUpdate = { [weak self] count, bodyDetected in
            guard let self else { return }
            self.repCount = count
            self.isBodyDetected = bodyDetected
            if count >= self.requiredReps && !self.completionFired {
                self.completionFired = true
                self.onComplete?()
            }
        }
        cameraService.startSession(outputDelegate: detector)
    }

    func stopDetection() {
        cameraService.stopSession()
        detector.onUpdate = nil
    }

    func reset() {
        repCount = 0
        isBodyDetected = false
        completionFired = false
        detector.reset()
    }

    var progress: Double {
        guard requiredReps > 0 else { return 0 }
        return min(1.0, Double(repCount) / Double(requiredReps))
    }
}
