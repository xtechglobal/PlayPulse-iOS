//
//  AppScreen.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI
import SwiftData

enum AppScreen: Equatable {
    case splash
    case welcome
    case login
    case home
    case session
    case breakTime
    case settings
    case parentPIN
    case paywall
}

@Observable
@MainActor
final class SessionViewModel {
    var currentScreen: AppScreen = .splash
    var sessionTimeRemaining: Int = 0
    var isSessionPaused: Bool = false
    var pendingPINDestination: AppScreen = .settings

    var totalEarnedMinutes: Int = 0 {
        didSet {
            stats.totalEarnedMinutes = totalEarnedMinutes
            saveStats()
        }
    }
    var totalSessionsCompleted: Int = 0 {
        didSet {
            stats.totalSessionsCompleted = totalSessionsCompleted
            saveStats()
        }
    }
    var totalBreaksCompleted: Int = 0 {
        didSet {
            stats.totalBreaksCompleted = totalBreaksCompleted
            saveStats()
        }
    }

    var sessionDuration: Int {
        let v = UserDefaults.standard.integer(forKey: AppSettingsKey.sessionDuration)
        return v > 0 ? v : AppDefaults.sessionDuration
    }
    var repsRequired: Int {
        let v = UserDefaults.standard.integer(forKey: AppSettingsKey.repsRequired)
        return v > 0 ? v : AppDefaults.repsRequired
    }
    var timeGrantedPerSet: Int {
        let v = UserDefaults.standard.integer(forKey: AppSettingsKey.timeGrantedPerSet)
        return v > 0 ? v : AppDefaults.timeGrantedPerSet
    }
    var parentPIN: String {
        UserDefaults.standard.string(forKey: AppSettingsKey.parentPIN) ?? AppDefaults.parentPIN
    }

    private let modelContext: ModelContext
    private var stats: AppStats
    private var timerTask: Task<Void, Never>?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        let descriptor = FetchDescriptor<AppStats>()
        if let existing = try? modelContext.fetch(descriptor).first {
            self.stats = existing
        } else {
            let fresh = AppStats()
            modelContext.insert(fresh)
            try? modelContext.save()
            self.stats = fresh
        }

        self.totalEarnedMinutes = stats.totalEarnedMinutes
        self.totalSessionsCompleted = stats.totalSessionsCompleted
        self.totalBreaksCompleted = stats.totalBreaksCompleted
    }

    func completeSplash() {
        if !UserDefaults.standard.bool(forKey: AppSettingsKey.hasCompletedWelcome) {
            currentScreen = .welcome
        } else if !UserDefaults.standard.bool(forKey: AppSettingsKey.isSignedIn) {
            currentScreen = .login
        } else {
            currentScreen = .home
        }
    }

    func completeWelcome() {
        UserDefaults.standard.set(true, forKey: AppSettingsKey.hasCompletedWelcome)
        currentScreen = .login
    }

    func signIn(provider: AuthProvider) {
        UserDefaults.standard.set(true, forKey: AppSettingsKey.isSignedIn)
        UserDefaults.standard.set(provider.title, forKey: AppSettingsKey.signedInProvider)
        currentScreen = .home
    }

    func signOut() {
        UserDefaults.standard.set(false, forKey: AppSettingsKey.isSignedIn)
        UserDefaults.standard.removeObject(forKey: AppSettingsKey.signedInProvider)
        currentScreen = .login
    }

    func deleteAccount() {
        UserDefaults.standard.set(false, forKey: AppSettingsKey.isSignedIn)
        UserDefaults.standard.removeObject(forKey: AppSettingsKey.signedInProvider)
        totalEarnedMinutes = 0
        totalSessionsCompleted = 0
        totalBreaksCompleted = 0
        currentScreen = .login
    }

    func startSession() {
        sessionTimeRemaining = sessionDuration
        totalSessionsCompleted += 1
        currentScreen = .session
        startTimer()
    }

    func pauseSession() {
        isSessionPaused = true
        timerTask?.cancel()
    }

    func resumeSession() {
        isSessionPaused = false
        startTimer()
    }

    func endSession() {
        timerTask?.cancel()
        timerTask = nil
        isSessionPaused = false
        sessionTimeRemaining = 0
        currentScreen = .home
    }

    func startBreak() {
        timerTask?.cancel()
        currentScreen = .breakTime
    }

    func exerciseCompleted() {
        totalBreaksCompleted += 1
        totalEarnedMinutes += timeGrantedPerSet / 60
        sessionTimeRemaining = timeGrantedPerSet
        currentScreen = .session
        startTimer()
    }

    func requestParentAccess(destination: AppScreen = .settings) {
        pendingPINDestination = destination
        currentScreen = .parentPIN
    }

    func verifyPIN(_ entered: String) -> Bool {
        entered == parentPIN
    }

    func pinVerified() {
        currentScreen = pendingPINDestination
    }

    func cancelPIN() {
        currentScreen = .home
    }

    func dismissSettings() {
        currentScreen = .home
    }

    var sessionProgress: Double {
        guard sessionDuration > 0 else { return 0 }
        return Double(sessionTimeRemaining) / Double(sessionDuration)
    }

    var formattedTimeRemaining: String {
        let m = sessionTimeRemaining / 60
        let s = sessionTimeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func saveStats() {
        try? modelContext.save()
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self else { break }
                if self.isSessionPaused { continue }
                if self.sessionTimeRemaining > 0 {
                    self.sessionTimeRemaining -= 1
                } else {
                    self.currentScreen = .breakTime
                    break
                }
            }
        }
    }
}
