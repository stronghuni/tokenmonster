import Foundation

enum Stage: Int, CaseIterable {
    case egg = 0, baby, child, teen, adult, ultimate

    var threshold: Int64 {
        switch self {
        case .egg:      return 0
        case .baby:     return 3_000_000      // few days
        case .child:    return 15_000_000     // ~1-2 weeks
        case .teen:     return 50_000_000     // ~1 month
        case .adult:    return 150_000_000    // ~2-3 months
        case .ultimate: return 400_000_000    // ~5-6 months
        }
    }

    var displayName: String {
        switch self {
        case .egg:      return "알"
        case .baby:     return "유년기"
        case .child:    return "성장기"
        case .teen:     return "성숙기"
        case .adult:    return "완전체"
        case .ultimate: return "궁극체"
        }
    }

    static func from(totalTokens: Int64) -> Stage {
        Stage.allCases.last { $0.threshold <= totalTokens } ?? .egg
    }
}
