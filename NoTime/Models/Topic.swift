import Foundation
import SwiftUI

struct Topic: Identifiable, Codable {
    let id: UUID
    var name: String
    var preparationLevel: PreparationLevel
    var estimatedMinutes: Int
    var notes: String
    
    init(id: UUID = UUID(), name: String, preparationLevel: PreparationLevel = .red, estimatedMinutes: Int = 60, notes: String = "") {
        self.id = id
        self.name = name
        self.preparationLevel = preparationLevel
        self.estimatedMinutes = estimatedMinutes
        self.notes = notes
    }
    
    var formattedEstimatedTime: String {
        if estimatedMinutes < 60 {
            return "\(estimatedMinutes) Min."
        } else {
            let hours = estimatedMinutes / 60
            let minutes = estimatedMinutes % 60
            if minutes == 0 {
                return "\(hours) Std."
            }
            return "\(hours) Std. \(minutes) Min."
        }
    }
}

enum PreparationLevel: String, Codable, CaseIterable {
    case red
    case yellow
    case green
    
    var color: Color {
        switch self {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        }
    }
    
    var description: String {
        switch self {
        case .red: return "Noch nicht gelernt"
        case .yellow: return "In Bearbeitung"
        case .green: return "Gut vorbereitet"
        }
    }
} 