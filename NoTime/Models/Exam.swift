import Foundation

struct Exam: Identifiable, Codable {
    let id: UUID
    var subject: String
    var date: Date
    var time: Date
    var topics: [Topic]
    
    init(id: UUID = UUID(), subject: String, date: Date, time: Date, topics: [Topic] = []) {
        self.id = id
        self.subject = subject
        self.date = date
        self.time = time
        self.topics = topics
    }
    
    var fullDateTime: Date {
        Calendar.current.combine(date: date, time: time) ?? date
    }
} 