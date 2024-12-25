import Foundation
import SwiftUI

struct Topic: Identifiable, Codable {
    let id: UUID
    var name: String
    var preparationLevel: PreparationLevel
    
    init(id: UUID = UUID(), name: String, preparationLevel: PreparationLevel = .red) {
        self.id = id
        self.name = name
        self.preparationLevel = preparationLevel
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
} 