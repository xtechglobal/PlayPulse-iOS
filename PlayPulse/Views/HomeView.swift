//
//  HomeView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct HomeView: View {
    @Environment(SessionViewModel.self) private var session
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    statsGrid
                    earnedTimeCard
                    startButton
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            AdBannerView()
        }
        .background(backgroundGradient.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    session.currentScreen = .paywall
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.orange)
                        Text("Premium")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.12), in: Capsule())
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    session.requestParentAccess()
                } label: {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange, .red)
                    .symbolEffect(.pulse)
                Text("PlayPulse")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
            }
            Text("Move to earn your screen time!")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
    }

    private var statsGrid: some View {
        HStack(spacing: 14) {
            StatCard(
                icon: "flame.fill",
                iconColor: .orange,
                value: "\(session.totalBreaksCompleted)",
                label: "Breaks Done"
            )
            StatCard(
                icon: "clock.fill",
                iconColor: .blue,
                value: "\(session.totalEarnedMinutes)",
                label: "Mins Earned"
            )
            StatCard(
                icon: "trophy.fill",
                iconColor: .yellow,
                value: "\(session.totalSessionsCompleted)",
                label: "Sessions"
            )
        }
    }

    private var earnedTimeCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemFill), lineWidth: 14)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: pulseProgress)
                    .stroke(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 160, height: 160)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: session.totalEarnedMinutes)

                VStack(spacing: 4) {
                    Text("\(session.totalEarnedMinutes)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                    Text("mins earned")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Text("Complete jumping jacks to earn screen time!")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 24))
    }

    private var pulseProgress: Double {
        let mins = Double(session.totalEarnedMinutes)
        return mins <= 0 ? 0 : min(1.0, (mins.truncatingRemainder(dividingBy: 30)) / 30)
    }

    private var startButton: some View {
        VStack(spacing: 12) {
            Button {
                session.startSession()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Start Session")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.rect(cornerRadius: 18))
            .sensoryFeedback(.impact, trigger: session.totalSessionsCompleted)

            Button {
                session.startBreak()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.jumprope")
                    Text("Earn Time Now")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(.systemBackground), Color(.systemBackground)]
                : [Color(.systemBackground), Color(.systemGroupedBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .contentTransition(.numericText())
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 18))
    }
}
