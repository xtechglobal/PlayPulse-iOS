//
//  JJPhase.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import AVFoundation
import Vision

nonisolated enum JJPhase: Equatable {
    case unknown
    case armsDown
    case armsUp
}

nonisolated final class JumpingJackDetector: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {

    var onUpdate: ((Int, Bool) -> Void)?

    private let stateLock = NSLock()
    private var repCount_ = 0
    private var phase_ = JJPhase.unknown
    private var frameIndex_ = 0

    func reset() {
        stateLock.lock()
        repCount_ = 0
        phase_ = .unknown
        frameIndex_ = 0
        stateLock.unlock()
    }

    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        stateLock.lock()
        frameIndex_ += 1
        let shouldProcess = frameIndex_ % 4 == 0
        stateLock.unlock()

        guard shouldProcess,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)

        guard (try? handler.perform([request])) != nil,
              let body = request.results?.first else {
            stateLock.lock()
            let count = repCount_
            stateLock.unlock()
            DispatchQueue.main.async { [weak self] in
                self?.onUpdate?(count, false)
            }
            return
        }

        let newPhase = computePhase(from: body)

        stateLock.lock()
        let oldPhase = phase_
        if newPhase != .unknown {
            phase_ = newPhase
        }
        if oldPhase == .armsDown && newPhase == .armsUp {
            repCount_ += 1
        }
        let count = repCount_
        stateLock.unlock()

        DispatchQueue.main.async { [weak self] in
            self?.onUpdate?(count, true)
        }
    }

    private func computePhase(from obs: VNHumanBodyPoseObservation) -> JJPhase {
        guard
            let lw = try? obs.recognizedPoint(.leftWrist),
            let rw = try? obs.recognizedPoint(.rightWrist),
            let ls = try? obs.recognizedPoint(.leftShoulder),
            let rs = try? obs.recognizedPoint(.rightShoulder),
            lw.confidence > 0.3,
            rw.confidence > 0.3,
            ls.confidence > 0.3,
            rs.confidence > 0.3
        else { return .unknown }

        let avgWristY = (lw.location.y + rw.location.y) / 2
        let avgShoulderY = (ls.location.y + rs.location.y) / 2

        if avgWristY > avgShoulderY + 0.08 { return .armsUp }
        if avgWristY < avgShoulderY - 0.04 { return .armsDown }
        return .unknown
    }
}
