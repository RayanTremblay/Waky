import Foundation

/// Calculates optimal wake-up times based on 90-minute sleep cycles.
/// Waking at the end of a cycle reduces grogginess.
struct WakeTimeCalculator {
    
    /// Length of one sleep cycle in minutes (average).
    static let cycleMinutes: Int = 90
    
    /// Typical number of cycles per night (4–6).
    static let minCycles = 4
    static let maxCycles = 6
    
    /// Given a target wake time, returns recommended "fall asleep by" times
    /// so the user wakes at the end of a full cycle.
    /// - Parameter wakeTime: When the user wants to wake up.
    /// - Returns: Array of (bedtime, cycles, total sleep minutes).
    static func recommendedBedtimes(for wakeTime: Date) -> [(date: Date, cycles: Int, sleepMinutes: Int)] {
        let calendar = Calendar.current
        var results: [(Date, Int, Int)] = []
        
        for cycles in (minCycles...maxCycles).reversed() {
            let sleepMinutes = cycles * cycleMinutes
            guard let bedtime = calendar.date(byAdding: .minute, value: -sleepMinutes, to: wakeTime) else { continue }
            results.append((bedtime, cycles, sleepMinutes))
        }
        
        return results
    }
    
    /// Given a "fall asleep now" time, returns suggested wake-up times (end of full cycles).
    static func suggestedWakeTimes(from fallAsleepTime: Date) -> [(date: Date, cycles: Int)] {
        let calendar = Calendar.current
        var results: [(Date, Int)] = []
        
        for cycles in minCycles...maxCycles {
            let sleepMinutes = cycles * cycleMinutes
            guard let wakeTime = calendar.date(byAdding: .minute, value: sleepMinutes, to: fallAsleepTime) else { continue }
            results.append((wakeTime, cycles))
        }
        
        return results
    }
}
