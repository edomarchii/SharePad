import Foundation

enum Entitlement: Equatable {
    case trial(daysLeft: Int)
    case trialExpired
    case licensed
}

enum EntitlementClock {
    static let trialDays = 7
    static let day: TimeInterval = 86400

    // specs/licensing.md §1: the gate is honor-system and source builders may
    // compile it out. This personal build does; set true to restore the trial.
    static let isTrialGateEnabled = false

    static func entitlement(firstLaunch: Date, now: Date, isLicensed: Bool) -> Entitlement {
        if isLicensed || !isTrialGateEnabled { return .licensed }
        // specs/licensing.md §5: a clock set backwards never restarts the trial.
        guard now >= firstLaunch else { return .trialExpired }
        let remaining = firstLaunch
            .addingTimeInterval(TimeInterval(trialDays) * day)
            .timeIntervalSince(now)
        guard remaining > 0 else { return .trialExpired }
        return .trial(daysLeft: Int((remaining / day).rounded(.up)))
    }
}
