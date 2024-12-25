import Foundation
import SwiftUI

class UserData: ObservableObject, Codable {
    @Published var name: String = ""
    @Published var exams: [Exam] = [] {
        didSet {
            saveData()
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case exams
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        exams = try container.decode([Exam].self, forKey: .exams)
    }
    
    init() {
        loadData()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(exams, forKey: .exams)
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "userData")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "userData"),
           let decoded = try? JSONDecoder().decode(UserData.self, from: data) {
            self.name = decoded.name
            self.exams = decoded.exams
        }
    }
} 