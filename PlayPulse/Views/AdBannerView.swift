//
//  AdBannerView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct AdBannerView: View {
    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
            Text("Advertisement")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
}

struct AdFullscreenPresenter: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white.opacity(0.4))
                Text("Ad Space")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Integrate your ad SDK here\n(AdMob, Facebook, Unity Ads)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                Button("Close") { isPresented = false }
                    .buttonStyle(.bordered)
                    .tint(.white)
            }
        }
    }
}
