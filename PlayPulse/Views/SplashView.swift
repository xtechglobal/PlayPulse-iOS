//
//  SplashView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct SplashView: View {
    @Environment(SessionViewModel.self) private var session
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.95), Color.cyan.opacity(0.85), Color.green.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.22))
                        .frame(width: 150, height: 150)
                        .scaleEffect(isPulsing ? 1.15 : 0.92)
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 76, weight: .black))
                        .foregroundStyle(.white, .yellow)
                        .symbolEffect(.pulse, options: .repeating)
                }

                VStack(spacing: 8) {
                    Text("PlayPulse")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                    Text("Move first. Play next.")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(.white)
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
            try? await Task.sleep(for: .seconds(1.4))
            session.completeSplash()
        }
    }
}
