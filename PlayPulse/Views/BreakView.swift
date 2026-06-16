//
//  BreakView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI
import AVFoundation

struct BreakView: View {
    @Environment(SessionViewModel.self) private var session
    @State private var jjViewModel = JumpingJackViewModel()
    @State private var celebrationScale = 1.0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                headerBar
                cameraSection
                repCounterSection
                instructionText
                Spacer(minLength: 12)
            }
            AdBannerView()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            jjViewModel.requiredReps = session.repsRequired
            jjViewModel.onComplete = {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    celebrationScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring()) { celebrationScale = 1.0 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    session.exerciseCompleted()
                }
            }
            jjViewModel.startDetection()
        }
        .onDisappear {
            jjViewModel.stopDetection()
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Exercise Break! 🏃")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text("Earn \(session.timeGrantedPerSet / 60) more minutes")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(jjViewModel.isBodyDetected ? Color.green.opacity(0.15) : Color(.systemFill))
                    .frame(width: 40, height: 40)
                Image(systemName: jjViewModel.isBodyDetected ? "figure.stand" : "camera.metering.none")
                    .font(.system(size: 18))
                    .foregroundStyle(jjViewModel.isBodyDetected ? .green : .secondary)
                    .symbolEffect(.pulse, isActive: jjViewModel.isBodyDetected)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var cameraSection: some View {
        Color(.secondarySystemBackground)
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .overlay {
                #if targetEnvironment(simulator)
                cameraPlaceholder
                #else
                if AVCaptureDevice.default(for: .video) != nil {
                    CameraPreviewView(session: jjViewModel.captureSession)
                        .allowsHitTesting(false)
                } else {
                    cameraPlaceholder
                }
                #endif
            }
            .clipShape(.rect(cornerRadius: 20))
            .padding(.horizontal, 20)
    }

    private var cameraPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Camera Preview")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
            Text("Install on your device via the Rork App\nto use the camera.")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var repCounterSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(.systemFill), lineWidth: 12)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: jjViewModel.progress)
                    .stroke(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 140, height: 140)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: jjViewModel.repCount)

                VStack(spacing: 2) {
                    Text("\(jjViewModel.repCount)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                        .scaleEffect(celebrationScale)
                        .foregroundStyle(jjViewModel.repCount >= session.repsRequired ? .orange : .primary)

                    Text("of \(session.repsRequired)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: jjViewModel.repCount)
            .padding(.top, 16)

            HStack(spacing: 8) {
                ForEach(0..<session.repsRequired, id: \.self) { i in
                    Capsule()
                        .fill(i < jjViewModel.repCount ? Color.orange : Color(.systemFill))
                        .frame(height: 6)
                        .animation(.spring(response: 0.3), value: jjViewModel.repCount)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var instructionText: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                instructionStep(num: "1", text: "Stand in front of camera")
                instructionStep(num: "2", text: "Arms up & out")
                instructionStep(num: "3", text: "Back to sides")
            }
            .padding(.horizontal, 20)
        }
    }

    private func instructionStep(num: String, text: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.15)).frame(width: 28, height: 28)
                Text(num)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.orange)
            }
            Text(text)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    final class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
