//
//  LoginView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct LoginView: View {
    @Environment(SessionViewModel.self) private var session
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var message: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                socialButtons
                emailCard
                offlineButton
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 28)
        }
        .background(background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 70, weight: .bold))
                .foregroundStyle(.orange, .blue)
            Text("Welcome to PlayPulse")
                .font(.system(.largeTitle, design: .rounded, weight: .black))
                .multilineTextAlignment(.center)
            Text("Sign in to save progress later, or continue offline for this device.")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var socialButtons: some View {
        VStack(spacing: 12) {
            ForEach([AuthProvider.apple, .google, .facebook, .tiktok]) { provider in
                Button {
                    session.signIn(provider: provider)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: provider.systemImage)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(provider.tint)
                        Text("Continue with \(provider.title)")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emailCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Email Login")
                .font(.system(.headline, design: .rounded, weight: .bold))
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            Button {
                if email == "test@test.com", password == "abc#1234" {
                    session.signIn(provider: .email)
                } else {
                    message = "Use test@test.com / abc#1234 for mock login."
                }
            } label: {
                Text("Login with Email")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.rect(cornerRadius: 16))

            if !message.isEmpty {
                Text(message)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.red)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 22))
    }

    private var offlineButton: some View {
        Button {
            session.signIn(provider: .offline)
        } label: {
            Label("Continue Offline", systemImage: "wifi.slash")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.bordered)
        .clipShape(.rect(cornerRadius: 18))
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(.systemBackground), Color.orange.opacity(0.12), Color.cyan.opacity(0.10)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
