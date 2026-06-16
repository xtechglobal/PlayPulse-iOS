//
//  SettingsView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI

struct SettingsView: View {
    @Environment(SessionViewModel.self) private var session
    @AppStorage(AppSettingsKey.sessionDuration) private var sessionDuration: Int = AppDefaults.sessionDuration
    @AppStorage(AppSettingsKey.repsRequired) private var repsRequired: Int = AppDefaults.repsRequired
    @AppStorage(AppSettingsKey.timeGrantedPerSet) private var timeGrantedPerSet: Int = AppDefaults.timeGrantedPerSet
    @AppStorage(AppSettingsKey.parentPIN) private var parentPIN: String = AppDefaults.parentPIN

    @State private var showChangePIN: Bool = false
    @State private var showResetConfirm: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var newPIN: String = ""

    private let sessionDurationOptions: [(label: String, seconds: Int)] = [
        ("5 minutes", 300),
        ("10 minutes", 600),
        ("15 minutes", 900),
        ("20 minutes", 1200),
        ("30 minutes", 1800)
    ]

    private let repsOptions: [Int] = [5, 10, 15, 20, 25, 30]

    private let earnedTimeOptions: [(label: String, seconds: Int)] = [
        ("3 minutes", 180),
        ("5 minutes", 300),
        ("10 minutes", 600),
        ("15 minutes", 900),
        ("20 minutes", 1200)
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    headerCard
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section {
                    Picker("Session Duration", selection: $sessionDuration) {
                        ForEach(sessionDurationOptions, id: \.seconds) { opt in
                            Text(opt.label).tag(opt.seconds)
                        }
                    }
                    .font(.system(.body, design: .rounded))

                    Picker("Jumping Jacks Required", selection: $repsRequired) {
                        ForEach(repsOptions, id: \.self) { val in
                            Text("\(val) reps").tag(val)
                        }
                    }
                    .font(.system(.body, design: .rounded))

                    Picker("Time Earned Per Set", selection: $timeGrantedPerSet) {
                        ForEach(earnedTimeOptions, id: \.seconds) { opt in
                            Text(opt.label).tag(opt.seconds)
                        }
                    }
                    .font(.system(.body, design: .rounded))
                } header: {
                    Label("Session Settings", systemImage: "slider.horizontal.3")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }

                Section {
                    Button {
                        showChangePIN = true
                    } label: {
                        HStack {
                            Label("Change PIN", systemImage: "lock.rotation")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Text("••••")
                                .foregroundStyle(.secondary)
                                .font(.system(.body, design: .rounded))
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Label("Security", systemImage: "lock.shield")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }

                Section {
                    statsRow(icon: "clock.fill", color: .blue, label: "Total Earned", value: "\(session.totalEarnedMinutes) min")
                    statsRow(icon: "flame.fill", color: .orange, label: "Breaks Completed", value: "\(session.totalBreaksCompleted)")
                    statsRow(icon: "gamecontroller.fill", color: .purple, label: "Sessions Started", value: "\(session.totalSessionsCompleted)")
                } header: {
                    Label("Stats", systemImage: "chart.bar.fill")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }

                Section {
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms & Conditions", systemImage: "doc.text.fill")
                            .font(.system(.body, design: .rounded))
                    }
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                            .font(.system(.body, design: .rounded))
                    }
                    Button {
                        requestReviewPlaceholder()
                    } label: {
                        Label("Review the App", systemImage: "star.bubble.fill")
                            .font(.system(.body, design: .rounded))
                    }
                    Link(destination: URL(string: "mailto:support@playpulse.app")!) {
                        Label("Contact Us", systemImage: "envelope.fill")
                            .font(.system(.body, design: .rounded))
                    }
                } header: {
                    Label("Support", systemImage: "questionmark.circle.fill")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }

                Section {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset All Stats", systemImage: "arrow.counterclockwise")
                            .font(.system(.body, design: .rounded))
                    }
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Account", systemImage: "person.crop.circle.badge.xmark")
                            .font(.system(.body, design: .rounded))
                    }
                    Button {
                        session.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.system(.body, design: .rounded))
                    }
                }
            }
            .navigationTitle("Parent Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { session.dismissSettings() }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .sheet(isPresented: $showChangePIN) {
                ChangePINSheet(currentPIN: $parentPIN)
            }
            .alert("Reset Stats?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    session.totalEarnedMinutes = 0
                    session.totalBreaksCompleted = 0
                    session.totalSessionsCompleted = 0
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All activity stats will be cleared. Settings will remain.")
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    session.deleteAccount()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes the local mock account and clears saved PlayPulse stats on this device.")
            }
        }
    }

    private func requestReviewPlaceholder() {
        // Hook StoreKit requestReview here when the App Store product is live.
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.orange)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Parent Controls")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text("Customize your child's experience")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func statsRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            Label {
                Text(label)
                    .font(.system(.body, design: .rounded))
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(color)
            }
            Spacer()
            Text(value)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private struct ChangePINSheet: View {
    @Binding var currentPIN: String
    @Environment(\.dismiss) private var dismiss
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("New PIN (4 digits)", text: $newPIN)
                        .keyboardType(.numberPad)
                        .font(.system(.body, design: .rounded))
                    SecureField("Confirm PIN", text: $confirmPIN)
                        .keyboardType(.numberPad)
                        .font(.system(.body, design: .rounded))
                } header: {
                    Text("Enter a 4-digit PIN")
                        .font(.system(.footnote, design: .rounded))
                }

                if showError {
                    Section {
                        Label("PINs don't match or are not 4 digits.", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.red)
                    }
                    .listRowBackground(Color.red.opacity(0.08))
                }
            }
            .navigationTitle("Change PIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { savePIN() }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func savePIN() {
        guard newPIN.count == 4, newPIN == confirmPIN, newPIN.allSatisfy(\.isNumber) else {
            showError = true
            return
        }
        currentPIN = newPIN
        dismiss()
    }
}
