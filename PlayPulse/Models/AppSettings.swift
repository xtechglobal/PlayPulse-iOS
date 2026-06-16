//
//  AppSettings.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//

import Foundation

nonisolated enum AppSettingsKey {
    static let sessionDuration = "sessionDuration"
    static let repsRequired = "repsRequired"
    static let timeGrantedPerSet = "timeGrantedPerSet"
    static let parentPIN = "parentPIN"
    static let totalEarnedMinutes = "totalEarnedMinutes"
    static let totalSessionsCompleted = "totalSessionsCompleted"
    static let totalBreaksCompleted = "totalBreaksCompleted"
    static let hasCompletedWelcome = "hasCompletedWelcome"
    static let isSignedIn = "isSignedIn"
    static let signedInProvider = "signedInProvider"
}

nonisolated enum AppDefaults {
    static let sessionDuration: Int = 600
    static let repsRequired: Int = 10
    static let timeGrantedPerSet: Int = 300
    static let parentPIN: String = "1234"
}
