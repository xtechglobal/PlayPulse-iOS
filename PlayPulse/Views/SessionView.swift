//
//  SessionView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct SessionView: View {
    @Environment(SessionViewModel.self) private var session
    @Environment(\.colorScheme) private var colorScheme
    @State private var showEndConfirm = false
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 32) {
                headerSection
                timerRing
                controlButtons
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .frame(maxHeight: .infinity)

            AdBannerView()
        }
        .background(sessionBackground.ignoresSafeArea())
        .alert("End Session?", isPresented: $showEndConfirm) {
            Button("End Session", role: .destructive) { session.endSession() }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Your progress will not be saved.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(session.isSessionPaused ? "Paused ⏸" : "Screen Time 🎮")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)
                .animation(.easeInOut, value: session.isSessionPaused)

            Text("Keep it up!")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 8)
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemFill), lineWidth: 18)
                .frame(width: 230, height: 230)

            Circle()
                .trim(from: 0, to: session.sessionProgress)
                .stroke(
                    LinearGradient(
                        colors: timerGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 230, height: 230)
                .animation(.linear(duration: 1), value: session.sessionProgress)

            VStack(spacing: 8) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse, isActive: !session.isSessionPaused)

                Text(session.formattedTimeRemaining)
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))

                Text("remaining")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            if session.sessionTimeRemaining <= 60 && session.sessionTimeRemaining > 0 {
                Circle()
                    .stroke(Color.orange.opacity(pulse ? 0.4 : 0), lineWidth: 22)
                    .frame(width: 230, height: 230)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                    .onAppear { pulse = true }
            }
        }
    }

    private var timerGradientColors: [Color] {
        let progress = session.sessionProgress
        if progress > 0.5 { return [.blue, .cyan] }
        if progress > 0.25 { return [.orange, .yellow] }
        return [.red, .orange]
    }

    private var controlButtons: some View {
        VStack(spacing: 14) {
            Button {
                if session.isSessionPaused {
                    session.resumeSession()
                } else {
                    session.pauseSession()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: session.isSessionPaused ? "play.fill" : "pause.fill")
                        .contentTransition(.symbolEffect(.replace))
                    Text(session.isSessionPaused ? "Resume" : "Pause")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.rect(cornerRadius: 18))
            .sensoryFeedback(.impact, trigger: session.isSessionPaused)

            HStack(spacing: 12) {
                Button {
                    showEndConfirm = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle")
                        Text("End Session")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var sessionBackground: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(.systemBackground), Color(.systemBackground)]
                : [Color(.systemBackground), Color(red: 0.93, green: 0.95, blue: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
