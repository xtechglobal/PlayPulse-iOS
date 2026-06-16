
import Foundation
import SwiftData

@Model
final class AppStats {
    var totalEarnedMinutes: Int
    var totalSessionsCompleted: Int
    var totalBreaksCompleted: Int

    init(
        totalEarnedMinutes: Int = 0,
        totalSessionsCompleted: Int = 0,
        totalBreaksCompleted: Int = 0
    ) {
        self.totalEarnedMinutes = totalEarnedMinutes
        self.totalSessionsCompleted = totalSessionsCompleted
        self.totalBreaksCompleted = totalBreaksCompleted
    }
}
