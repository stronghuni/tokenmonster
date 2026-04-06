import Foundation

enum Stage: Int, CaseIterable {
    case egg = 0, baby, child, teen, adult, ultimate

    var threshold: Int64 {
        switch self {
        case .egg:      return 0
        case .baby:     return 30_000_000
        case .child:    return 150_000_000
        case .teen:     return 500_000_000
        case .adult:    return 1_500_000_000
        case .ultimate: return 4_000_000_000
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
