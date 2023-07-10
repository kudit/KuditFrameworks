/// Enables ++ on any enum to get the next enum value (if it's the last value, wraps around to first)
extension CaseIterable where Self: Equatable {
    /// Replaces the variable with the next enum value (if it's the last value, wraps around to first)
    static postfix func ++(e: inout Self) {
        let all = Self.allCases
        let idx = all.firstIndex(of: e)! // not possible to have it not be found
        let next = all.index(after: idx)
        e = all[next == all.endIndex ? all.startIndex : next]
    }
}
