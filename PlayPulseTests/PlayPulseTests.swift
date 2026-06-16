//
//  PlayPulseTests.swift
//  PlayPulseTests
//
//  Created by Lakhdeep on 26/02/26.
//
/*
import Testing
@testable import PlayPulse

struct PlayPulseTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}
*/

import Testing
import SwiftData
import Foundation
@testable import PlayPulse

@Suite("AppStats SwiftData Model")
struct AppStatsTests {

    @Test func defaultValuesAreZero() {
        let stats = AppStats()
        #expect(stats.totalEarnedMinutes == 0)
        #expect(stats.totalSessionsCompleted == 0)
        #expect(stats.totalBreaksCompleted == 0)
    }

    @Test func customInitValues() {
        let stats = AppStats(totalEarnedMinutes: 15, totalSessionsCompleted: 3, totalBreaksCompleted: 6)
        #expect(stats.totalEarnedMinutes == 15)
        #expect(stats.totalSessionsCompleted == 3)
        #expect(stats.totalBreaksCompleted == 6)
    }

    @Test func mutationPersistsInMemoryContainer() throws {
        let schema = Schema([AppStats.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        let stats = AppStats(totalEarnedMinutes: 0, totalSessionsCompleted: 0, totalBreaksCompleted: 0)
        context.insert(stats)
        try context.save()

        stats.totalEarnedMinutes = 10
        stats.totalBreaksCompleted = 2
        try context.save()

        let descriptor = FetchDescriptor<AppStats>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched.first?.totalEarnedMinutes == 10)
        #expect(fetched.first?.totalBreaksCompleted == 2)
    }

    @Test func onlyOneStatsRecordExists() throws {
        let schema = Schema([AppStats.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        context.insert(AppStats())
        try context.save()

        let descriptor = FetchDescriptor<AppStats>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
    }
}

@Suite("AppDefaults and AppSettingsKey")
struct AppDefaultsTests {

    @Test func sessionDurationDefault() {
        #expect(AppDefaults.sessionDuration == 600)
    }

    @Test func repsRequiredDefault() {
        #expect(AppDefaults.repsRequired == 10)
    }

    @Test func timeGrantedPerSetDefault() {
        #expect(AppDefaults.timeGrantedPerSet == 300)
    }

    @Test func parentPINDefault() {
        #expect(AppDefaults.parentPIN == "1234")
    }

    @Test func settingsKeysAreUnique() {
        let keys = [
            AppSettingsKey.sessionDuration,
            AppSettingsKey.repsRequired,
            AppSettingsKey.timeGrantedPerSet,
            AppSettingsKey.parentPIN,
            AppSettingsKey.totalEarnedMinutes,
            AppSettingsKey.totalSessionsCompleted,
            AppSettingsKey.totalBreaksCompleted
        ]
        #expect(Set(keys).count == keys.count)
    }
}

@Suite("SessionViewModel Logic")
struct SessionViewModelTests {

    private func makeViewModel() throws -> SessionViewModel {
        let schema = Schema([AppStats.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)
        return SessionViewModel(modelContext: context)
    }

    @Test @MainActor func initialScreenIsHome() throws {
        let vm = try makeViewModel()
        #expect(vm.currentScreen == .home)
    }

    @Test @MainActor func formattedTimeZero() throws {
        let vm = try makeViewModel()
        vm.sessionTimeRemaining = 0
        #expect(vm.formattedTimeRemaining == "00:00")
    }

    @Test @MainActor func formattedTimeFormatting() throws {
        let vm = try makeViewModel()
        vm.sessionTimeRemaining = 605
        #expect(vm.formattedTimeRemaining == "10:05")
    }

    @Test @MainActor func sessionProgressZeroWhenNoTime() throws {
        let vm = try makeViewModel()
        vm.sessionTimeRemaining = 0
        #expect(vm.sessionProgress == 0.0)
    }

    @Test @MainActor func verifyPINSuccess() throws {
        let vm = try makeViewModel()
        UserDefaults.standard.set("5678", forKey: AppSettingsKey.parentPIN)
        #expect(vm.verifyPIN("5678") == true)
        UserDefaults.standard.removeObject(forKey: AppSettingsKey.parentPIN)
    }

    @Test @MainActor func verifyPINFailure() throws {
        let vm = try makeViewModel()
        UserDefaults.standard.set("1234", forKey: AppSettingsKey.parentPIN)
        #expect(vm.verifyPIN("0000") == false)
        UserDefaults.standard.removeObject(forKey: AppSettingsKey.parentPIN)
    }

    @Test @MainActor func cancelPINReturnsHome() throws {
        let vm = try makeViewModel()
        vm.currentScreen = .parentPIN
        vm.cancelPIN()
        #expect(vm.currentScreen == .home)
    }

    @Test @MainActor func dismissSettingsReturnsHome() throws {
        let vm = try makeViewModel()
        vm.currentScreen = .settings
        vm.dismissSettings()
        #expect(vm.currentScreen == .home)
    }

    @Test @MainActor func endSessionResetsState() throws {
        let vm = try makeViewModel()
        vm.sessionTimeRemaining = 300
        vm.isSessionPaused = true
        vm.endSession()
        #expect(vm.currentScreen == .home)
        #expect(vm.sessionTimeRemaining == 0)
        #expect(vm.isSessionPaused == false)
    }

    @Test @MainActor func exerciseCompletedIncrementsStats() throws {
        let vm = try makeViewModel()
        UserDefaults.standard.set(300, forKey: AppSettingsKey.timeGrantedPerSet)
        let prevBreaks = vm.totalBreaksCompleted
        let prevEarned = vm.totalEarnedMinutes
        vm.exerciseCompleted()
        #expect(vm.totalBreaksCompleted == prevBreaks + 1)
        #expect(vm.totalEarnedMinutes == prevEarned + 5)
        #expect(vm.currentScreen == .session)
        UserDefaults.standard.removeObject(forKey: AppSettingsKey.timeGrantedPerSet)
    }

    @Test @MainActor func statsPersistedInSwiftData() throws {
        let schema = Schema([AppStats.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        let vm = SessionViewModel(modelContext: context)
        vm.totalEarnedMinutes = 20
        vm.totalBreaksCompleted = 4

        let descriptor = FetchDescriptor<AppStats>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.first?.totalEarnedMinutes == 20)
        #expect(fetched.first?.totalBreaksCompleted == 4)
    }
}
