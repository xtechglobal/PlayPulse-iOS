//
//  CameraService.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


@preconcurrency import AVFoundation

nonisolated final class CameraService: NSObject, @unchecked Sendable {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.playpulse.camera.session")

    func startSession(outputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureAndStart(outputDelegate: outputDelegate)
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    private func configureAndStart(outputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        guard !captureSession.isRunning else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480

        let position: AVCaptureDevice.Position = .front
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input) else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(input)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        let videoQueue = DispatchQueue(label: "com.playpulse.camera.video")
        videoOutput.setSampleBufferDelegate(outputDelegate, queue: videoQueue)

        guard captureSession.canAddOutput(videoOutput) else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.addOutput(videoOutput)

        if let connection = videoOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
}
