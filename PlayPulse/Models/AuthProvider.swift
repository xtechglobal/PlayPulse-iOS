//
//  AuthProvider.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

nonisolated enum AuthProvider: String, CaseIterable, Identifiable {
    case apple
    case google
    case facebook
    case tiktok
    case email
    case offline

    var id: String { rawValue }

    var title: String {
        switch self {
        case .apple: "Apple"
        case .google: "Google"
        case .facebook: "Facebook"
        case .tiktok: "TikTok"
        case .email: "Email"
        case .offline: "Offline Mode"
        }
    }

    var systemImage: String {
        switch self {
        case .apple: "apple.logo"
        case .google: "g.circle.fill"
        case .facebook: "f.circle.fill"
        case .tiktok: "music.note"
        case .email: "envelope.fill"
        case .offline: "wifi.slash"
        }
    }

    var tint: Color {
        switch self {
        case .apple: .primary
        case .google: .red
        case .facebook: .blue
        case .tiktok: .pink
        case .email: .orange
        case .offline: .green
        }
    }
}
