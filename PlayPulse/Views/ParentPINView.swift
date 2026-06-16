//
//  ParentPINView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct ParentPINView: View {
    @Environment(SessionViewModel.self) private var session
    @State private var enteredPIN = ""
    @State private var shakeOffset = 0.0
    @State private var showError = false

    private let digits = [["1","2","3"],["4","5","6"],["7","8","9"],["","0","⌫"]]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                headerSection

                pinDots
                    .offset(x: shakeOffset)

                if showError {
                    Text("Incorrect PIN. Try again.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.red)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                numpad
                    .padding(.horizontal, 48)

                cancelButton
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .animation(.spring(response: 0.3), value: showError)
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: enteredPIN.count == 4 ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.orange)
                    .contentTransition(.symbolEffect(.replace))
            }
            Text("Parent Access")
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text("Enter your 4-digit PIN")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var pinDots: some View {
        HStack(spacing: 20) {
            ForEach(0..<4, id: \.self) { i in
                ZStack {
                    Circle()
                        .fill(i < enteredPIN.count ? Color.orange : Color(.systemFill))
                        .frame(width: 18, height: 18)
                        .animation(.spring(response: 0.2), value: enteredPIN.count)
                    if i < enteredPIN.count {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 18, height: 18)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .animation(.spring(response: 0.2), value: enteredPIN.count)
    }

    private var numpad: some View {
        VStack(spacing: 14) {
            ForEach(digits, id: \.self) { row in
                HStack(spacing: 14) {
                    ForEach(row, id: \.self) { key in
                        numpadButton(key: key)
                    }
                }
            }
        }
    }

    private func numpadButton(key: String) -> some View {
        Button {
            handleKey(key)
        } label: {
            ZStack {
                if key.isEmpty {
                    Color.clear
                        .frame(height: 64)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(key == "⌫" ? Color(.systemFill) : Color(.secondarySystemBackground))
                        .frame(height: 64)
                    if key == "⌫" {
                        Image(systemName: "delete.backward.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(key)
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: enteredPIN)
        .disabled(key.isEmpty)
    }

    private var cancelButton: some View {
        Button {
            session.cancelPIN()
        } label: {
            Text("Cancel")
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func handleKey(_ key: String) {
        showError = false
        if key == "⌫" {
            if !enteredPIN.isEmpty { enteredPIN.removeLast() }
        } else if enteredPIN.count < 4 {
            enteredPIN.append(key)
            if enteredPIN.count == 4 {
                verifyPIN()
            }
        }
    }

    private func verifyPIN() {
        if session.verifyPIN(enteredPIN) {
            session.pinVerified()
        } else {
            withAnimation(.linear(duration: 0.05).repeatCount(6, autoreverses: true)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                shakeOffset = 0
                showError = true
                enteredPIN = ""
            }
        }
    }
}
