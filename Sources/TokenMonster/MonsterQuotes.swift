import Foundation

enum MonsterQuotes {
    static let all: [String] = [
        "꿈을 포기하지 않으면 언젠간 이루어질 거야",
        "혼자서는 이길 수 없지만, 우리 모두가 힘을 합치면 못 할 일이 없어",
        "용기는 무모하게 달려드는 게 아니야. 두려움을 이겨내고 친구를 위해 나서는 마음이야",
        "이 세상에 불필요한 존재는 없어",
        "지키고 싶은 것이 있다면, 그게 바로 너의 힘이 될 거야",
        "약하다는 건 부끄러운 게 아니야. 강해지기 위해 노력하는 게 중요해",
    ]

    static func random() -> String {
        all.randomElement() ?? all[0]
    }
}
