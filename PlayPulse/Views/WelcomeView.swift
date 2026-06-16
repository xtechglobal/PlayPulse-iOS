//
//  WelcomeView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct WelcomeView: View {
    @Environment(SessionViewModel.self) private var session
    @State private var page: Int = 0

    private let pages: [WelcomePage] = [
        WelcomePage(title: "Earn Screen Time", subtitle: "Kids complete healthy movement goals before play time begins.", imageName: "gamecontroller.fill", color: .orange),
        WelcomePage(title: "Jumping Jack Breaks", subtitle: "On-device Vision counts reps privately using the camera when a break starts.", imageName: "figure.jumprope", color: .cyan),
        WelcomePage(title: "Parent Friendly", subtitle: "PIN-protected settings, premium options, and future ad slots are ready to grow with PlayPulse.", imageName: "lock.shield.fill", color: .green)
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages) { item in
                    VStack(spacing: 28) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(item.color.opacity(0.18))
                                .frame(width: 220, height: 220)
                            Image(systemName: item.imageName)
                                .font(.system(size: 92, weight: .bold))
                                .foregroundStyle(item.color)
                                .symbolEffect(.bounce, value: page)
                        }
                        VStack(spacing: 12) {
                            Text(item.title)
                                .font(.system(.largeTitle, design: .rounded, weight: .black))
                            Text(item.subtitle)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 28)
                        Spacer()
                    }
                    .tag(item.index(in: pages))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: 14) {
                Button {
                    if page < pages.count - 1 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { page += 1 }
                    } else {
                        session.completeWelcome()
                    }
                } label: {
                    Text(page == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(.rect(cornerRadius: 18))

                Button("Skip") { session.completeWelcome() }
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .opacity(page == pages.count - 1 ? 0 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

private struct WelcomePage: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color

    func index(in pages: [WelcomePage]) -> Int {
        pages.firstIndex { $0.id == id } ?? 0
    }
}
