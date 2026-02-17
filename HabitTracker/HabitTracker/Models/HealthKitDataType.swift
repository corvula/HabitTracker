import Foundation

enum HealthKitDataType: String, Codable, CaseIterable {
    case steps = "Кроки"
    case water = "Вода"
    case sleep = "Сон"
    case workout = "Тренування"
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .water: return "drop.fill"
        case .sleep: return "bed.double.fill"
        case .workout: return "figure.run"
        }
    }
}
